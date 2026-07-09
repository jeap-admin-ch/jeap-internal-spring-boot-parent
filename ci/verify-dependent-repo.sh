#!/bin/bash
#
# Validates that a dependent jEAP library builds against a given version of the
# jeap-internal-spring-boot-parent: clones the library repository, points its
# <parent> at the given version and runs the library's full Maven build.
#
# Designed to be invoked once per repository, so multiple repositories can be
# validated in parallel.

set -euo pipefail

DEFAULT_GIT_BASE_URL="ssh://git@bitbucket.bit.admin.ch/jeap"
GIT_HOST="bitbucket.bit.admin.ch"
VERSIONS_PLUGIN="org.codehaus.mojo:versions-maven-plugin:2.21.0"

REPO_NAME=""
INTERNAL_PARENT_VERSION=""
BRANCH="master"
WORK_DIR="./dependent-repos"
SETTINGS_FILE=""
GIT_BASE_URL="${DEFAULT_GIT_BASE_URL}"

usage() {
    cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [options] <repo-name> <parent-version>

Clones the given repository, sets its jeap-internal-spring-boot-parent version
to <parent-version> and runs ./mvnw verify on it.

Arguments:
  repo-name                 Repository to validate (e.g. jeap-messaging)
  parent-version            jeap-internal-spring-boot-parent version to validate against

Options:
  -b, --branch <branch>       Branch to check out (default: ${BRANCH})
  -w, --work-dir <dir>        Directory to clone into (default: ${WORK_DIR})
  -s, --settings <file>       Maven settings.xml passed to mvnw (default: none)
  -g, --git-base-url <url>    Clone base URL (default: ${DEFAULT_GIT_BASE_URL})
  -h, --help                  Show this help
EOF
}

log() {
    echo "[${REPO_NAME:-verify-dependent-repo}] $*"
}

fail() {
    log "ERROR: $*" >&2
    exit 1
}

parse_args() {
    local positional=()
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -b|--branch)
                [[ $# -ge 2 ]] || fail "Option $1 requires an argument"
                BRANCH="$2"
                shift 2
                ;;
            -w|--work-dir)
                [[ $# -ge 2 ]] || fail "Option $1 requires an argument"
                WORK_DIR="$2"
                shift 2
                ;;
            -s|--settings)
                [[ $# -ge 2 ]] || fail "Option $1 requires an argument"
                SETTINGS_FILE="$2"
                shift 2
                ;;
            -g|--git-base-url)
                [[ $# -ge 2 ]] || fail "Option $1 requires an argument"
                GIT_BASE_URL="$2"
                shift 2
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            -*)
                usage >&2
                fail "Unknown option: $1"
                ;;
            *)
                positional+=("$1")
                shift
                ;;
        esac
    done

    if [[ ${#positional[@]} -ne 2 ]]; then
        usage >&2
        fail "Expected exactly 2 arguments (repo-name, parent-version), got ${#positional[@]}"
    fi
    REPO_NAME="${positional[0]}"
    INTERNAL_PARENT_VERSION="${positional[1]}"

    if [[ -n "${SETTINGS_FILE}" && ! -f "${SETTINGS_FILE}" ]]; then
        fail "Maven settings file not found: ${SETTINGS_FILE}"
    fi
}

# Trusts the git host's SSH key if it is not known yet (no-op for non-ssh URLs).
ensure_known_hosts() {
    [[ "${GIT_BASE_URL}" == ssh://* ]] || return 0
    mkdir -p ~/.ssh
    if ! grep -qs "${GIT_HOST}" ~/.ssh/known_hosts; then
        log "Adding ${GIT_HOST} to ~/.ssh/known_hosts"
        ssh-keyscan -t rsa "${GIT_HOST}" >> ~/.ssh/known_hosts
    fi
}

checkout_repo() {
    local repo_url="${GIT_BASE_URL}/${REPO_NAME}.git"
    local target_dir="${WORK_DIR}/${REPO_NAME}"
    [[ ! -e "${target_dir}" ]] || fail "Target directory already exists: ${target_dir}"
    log "Cloning ${repo_url} (branch ${BRANCH}) into ${target_dir}"
    git clone --depth 1 --branch "${BRANCH}" "${repo_url}" "${target_dir}"
}

mvnw() {
    local settings_args=()
    if [[ -n "${SETTINGS_FILE}" ]]; then
        settings_args=(-s "${SETTINGS_FILE}")
    fi
    ./mvnw -B "${settings_args[@]}" "$@"
}

set_parent_version() {
    log "Setting jeap-internal-spring-boot-parent version to ${INTERNAL_PARENT_VERSION}"
    mvnw "${VERSIONS_PLUGIN}:update-parent" \
        "-DparentVersion=${INTERNAL_PARENT_VERSION}" \
        -DskipResolution=true \
        -DgenerateBackupPoms=false
}

run_verify() {
    log "Running ./mvnw verify"
    mvnw verify
}

main() {
    parse_args "$@"

    # Absolute path, as it is used again after changing into the repo directory
    mkdir -p "${WORK_DIR}"
    WORK_DIR="$(cd "${WORK_DIR}" && pwd)"

    # Each repository gets its own Maven wrapper home so parallel invocations
    # do not race on the Maven distribution download.
    export MAVEN_USER_HOME="${WORK_DIR}/${REPO_NAME}/.m2"
    export MAVEN_OPTS="${MAVEN_OPTS:--Xms1G -Xmx2G -XX:MaxMetaspaceSize=1G -Dorg.slf4j.simpleLogger.log.org.apache.maven.cli.transfer.Slf4jMavenTransferListener=warn}"

    # Proxy env vars are inherited by the forked test JVMs (the AWS SDK reads them by default)
    # and would route Testcontainers traffic to the Docker bridge IP through the proxy, which
    # fails. The build needs no proxy: dependencies are resolved through the Nexus mirror.
    unset http_proxy HTTP_PROXY https_proxy HTTPS_PROXY

    ensure_known_hosts
    checkout_repo
    cd "${WORK_DIR}/${REPO_NAME}"
    set_parent_version
    run_verify
    log "Validation of ${REPO_NAME}@${BRANCH} against parent ${INTERNAL_PARENT_VERSION} succeeded"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
