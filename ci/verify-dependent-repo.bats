#!/usr/bin/env bats
#
# Tests for verify-dependent-repo.sh. External commands (git, ssh-keyscan) and
# the Maven wrapper of the cloned repository are stubbed on the PATH, so the
# tests run without network access and without a real Maven installation.
#
# Run with: bats ci/verify-dependent-repo.bats

SCRIPT="${BATS_TEST_DIRNAME}/verify-dependent-repo.sh"

setup() {
    STUB_DIR="${BATS_TEST_TMPDIR}/stubs"
    WORK_DIR="${BATS_TEST_TMPDIR}/work"
    export HOME="${BATS_TEST_TMPDIR}/home"
    mkdir -p "${STUB_DIR}" "${HOME}"
    export PATH="${STUB_DIR}:${PATH}"
    export GIT_LOG="${BATS_TEST_TMPDIR}/git.log"
    export KEYSCAN_LOG="${BATS_TEST_TMPDIR}/keyscan.log"
    export MVNW_LOG="${BATS_TEST_TMPDIR}/mvnw.log"
    export MVNW_STUB="${BATS_TEST_TMPDIR}/mvnw-stub"
    unset MAVEN_OPTS MAVEN_USER_HOME http_proxy HTTP_PROXY https_proxy HTTPS_PROXY

    # git stub: records all arguments; on "clone" creates the target directory
    # (last argument) containing the recording mvnw stub. Fails when
    # GIT_STUB_FAIL is set.
    cat > "${STUB_DIR}/git" <<'EOF'
#!/bin/bash
echo "$@" >> "${GIT_LOG}"
[[ -z "${GIT_STUB_FAIL:-}" ]] || exit 128
if [[ "$1" == "clone" ]]; then
    target="${@: -1}"
    mkdir -p "${target}"
    cp "${MVNW_STUB}" "${target}/mvnw"
fi
EOF

    # ssh-keyscan stub: records the invocation and prints a fake host key.
    cat > "${STUB_DIR}/ssh-keyscan" <<'EOF'
#!/bin/bash
echo "$@" >> "${KEYSCAN_LOG}"
echo "${@: -1} ssh-rsa AAAAfakekey"
EOF

    # mvnw stub placed into "cloned" repositories: records arguments and
    # MAVEN_USER_HOME. Fails when the arguments match MVNW_FAIL_ON.
    cat > "${MVNW_STUB}" <<'EOF'
#!/bin/bash
echo "MAVEN_USER_HOME=${MAVEN_USER_HOME:-} proxies=${http_proxy:-}${HTTP_PROXY:-}${https_proxy:-}${HTTPS_PROXY:-} $*" >> "${MVNW_LOG}"
if [[ -n "${MVNW_FAIL_ON:-}" && "$*" == *"${MVNW_FAIL_ON}"* ]]; then
    exit 1
fi
EOF

    chmod +x "${STUB_DIR}/git" "${STUB_DIR}/ssh-keyscan" "${MVNW_STUB}"
}

run_script() {
    run "${SCRIPT}" "$@"
}

# --- Argument parsing ---------------------------------------------------------

@test "fails without arguments and prints usage" {
    run_script
    [ "$status" -ne 0 ]
    [[ "$output" == *"Usage:"* ]]
    [[ "$output" == *"Expected exactly 2 arguments"* ]]
}

@test "fails with only one positional argument" {
    run_script jeap-messaging
    [ "$status" -ne 0 ]
    [[ "$output" == *"Expected exactly 2 arguments"* ]]
}

@test "fails with three positional arguments" {
    run_script jeap-messaging 1.2.3 extra
    [ "$status" -ne 0 ]
    [[ "$output" == *"Expected exactly 2 arguments"* ]]
}

@test "rejects unknown options" {
    run_script --bogus jeap-messaging 1.2.3
    [ "$status" -ne 0 ]
    [[ "$output" == *"Unknown option: --bogus"* ]]
}

@test "fails when an option is missing its argument" {
    run_script jeap-messaging 1.2.3 --branch
    [ "$status" -ne 0 ]
    [[ "$output" == *"requires an argument"* ]]
}

@test "--help prints usage and exits successfully" {
    run_script --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"Usage:"* ]]
}

@test "fails when the given settings file does not exist" {
    run_script -w "${WORK_DIR}" -s /does/not/exist.xml jeap-messaging 1.2.3
    [ "$status" -ne 0 ]
    [[ "$output" == *"settings file not found"* ]]
    [ ! -f "${GIT_LOG}" ]
}

# --- Checkout -----------------------------------------------------------------

@test "clones the repository shallowly from the default base URL on master" {
    run_script -w "${WORK_DIR}" jeap-messaging 8.4.0-SNAPSHOT
    [ "$status" -eq 0 ]
    grep -q -- "clone --depth 1 --branch master ssh://git@bitbucket.bit.admin.ch/jeap/jeap-messaging.git ${WORK_DIR}/jeap-messaging" "${GIT_LOG}"
}

@test "honors --branch and --git-base-url" {
    run_script -w "${WORK_DIR}" -b my-branch -g https://example.com/scm/other jeap-crypto 1.2.3
    [ "$status" -eq 0 ]
    grep -q -- "clone --depth 1 --branch my-branch https://example.com/scm/other/jeap-crypto.git ${WORK_DIR}/jeap-crypto" "${GIT_LOG}"
}

@test "fails when the target directory already exists" {
    mkdir -p "${WORK_DIR}/jeap-messaging"
    run_script -w "${WORK_DIR}" jeap-messaging 1.2.3
    [ "$status" -ne 0 ]
    [[ "$output" == *"already exists"* ]]
    [ ! -f "${GIT_LOG}" ]
}

@test "fails when git clone fails" {
    export GIT_STUB_FAIL=1
    run_script -w "${WORK_DIR}" jeap-messaging 1.2.3
    [ "$status" -ne 0 ]
    [ ! -f "${MVNW_LOG}" ]
}

# --- known_hosts handling -----------------------------------------------------

@test "adds the git host to known_hosts for ssh URLs" {
    run_script -w "${WORK_DIR}" jeap-messaging 1.2.3
    [ "$status" -eq 0 ]
    grep -q "bitbucket.bit.admin.ch" "${KEYSCAN_LOG}"
    grep -q "bitbucket.bit.admin.ch" "${HOME}/.ssh/known_hosts"
}

@test "skips ssh-keyscan when the host is already known" {
    mkdir -p "${HOME}/.ssh"
    echo "bitbucket.bit.admin.ch ssh-rsa AAAAexisting" > "${HOME}/.ssh/known_hosts"
    run_script -w "${WORK_DIR}" jeap-messaging 1.2.3
    [ "$status" -eq 0 ]
    [ ! -f "${KEYSCAN_LOG}" ]
}

@test "skips ssh-keyscan for non-ssh clone URLs" {
    run_script -w "${WORK_DIR}" -g https://example.com/scm/jeap jeap-messaging 1.2.3
    [ "$status" -eq 0 ]
    [ ! -f "${KEYSCAN_LOG}" ]
}

# --- Maven invocations --------------------------------------------------------

@test "updates the parent version without resolution and without backup poms" {
    run_script -w "${WORK_DIR}" jeap-messaging 8.4.0-feature-renovate-x-SNAPSHOT
    [ "$status" -eq 0 ]
    local update_line
    update_line="$(grep "update-parent" "${MVNW_LOG}")"
    [[ "${update_line}" == *"-B"* ]]
    [[ "${update_line}" == *"org.codehaus.mojo:versions-maven-plugin:2.21.0:update-parent"* ]]
    [[ "${update_line}" == *"-DparentVersion=8.4.0-feature-renovate-x-SNAPSHOT"* ]]
    [[ "${update_line}" == *"-DskipResolution=true"* ]]
    [[ "${update_line}" == *"-DgenerateBackupPoms=false"* ]]
}

@test "runs verify after updating the parent version" {
    run_script -w "${WORK_DIR}" jeap-messaging 1.2.3
    [ "$status" -eq 0 ]
    [ "$(wc -l < "${MVNW_LOG}")" -eq 2 ]
    [[ "$(sed -n '1p' "${MVNW_LOG}")" == *"update-parent"* ]]
    [[ "$(sed -n '2p' "${MVNW_LOG}")" == *"-B verify"* ]]
}

@test "passes the settings file to all Maven invocations when given" {
    touch "${BATS_TEST_TMPDIR}/settings.xml"
    run_script -w "${WORK_DIR}" -s "${BATS_TEST_TMPDIR}/settings.xml" jeap-messaging 1.2.3
    [ "$status" -eq 0 ]
    [ "$(grep -c -- "-s ${BATS_TEST_TMPDIR}/settings.xml" "${MVNW_LOG}")" -eq 2 ]
}

@test "does not pass a settings option by default" {
    run_script -w "${WORK_DIR}" jeap-messaging 1.2.3
    [ "$status" -eq 0 ]
    ! grep -q -- " -s " "${MVNW_LOG}"
}

@test "uses a repository-specific MAVEN_USER_HOME" {
    run_script -w "${WORK_DIR}" jeap-messaging 1.2.3
    [ "$status" -eq 0 ]
    grep -q "MAVEN_USER_HOME=${WORK_DIR}/jeap-messaging/.m2" "${MVNW_LOG}"
}

@test "unsets proxy env vars for the Maven invocations" {
    export http_proxy="http://proxy.example.com:8080"
    export HTTP_PROXY="http://proxy.example.com:8080"
    export https_proxy="http://proxy.example.com:8080"
    export HTTPS_PROXY="http://proxy.example.com:8080"
    run_script -w "${WORK_DIR}" jeap-messaging 1.2.3
    [ "$status" -eq 0 ]
    [ "$(grep -c "proxies= " "${MVNW_LOG}")" -eq 2 ]
}

@test "fails and skips verify when the parent version update fails" {
    export MVNW_FAIL_ON="update-parent"
    run_script -w "${WORK_DIR}" jeap-messaging 1.2.3
    [ "$status" -ne 0 ]
    ! grep -q -- "-B verify" "${MVNW_LOG}"
}

@test "fails when verify fails" {
    export MVNW_FAIL_ON="verify"
    run_script -w "${WORK_DIR}" jeap-messaging 1.2.3
    [ "$status" -ne 0 ]
    [[ "$output" != *"succeeded"* ]]
}

# --- Logging ------------------------------------------------------------------

@test "prefixes log lines with the repository name" {
    run_script -w "${WORK_DIR}" jeap-messaging 1.2.3
    [ "$status" -eq 0 ]
    [[ "$output" == *"[jeap-messaging] Cloning"* ]]
    [[ "$output" == *"[jeap-messaging] Validation of jeap-messaging@master against parent 1.2.3 succeeded"* ]]
}
