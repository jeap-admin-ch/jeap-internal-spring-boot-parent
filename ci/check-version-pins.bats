#!/usr/bin/env bats
#
# Tests for check-version-pins.sh. Both POMs are written as fixtures and the
# Spring Boot BOM is passed with --boot-pom, so the tests run without network
# access and without a real Maven installation. The Maven wrapper is stubbed
# only for the test that exercises the fetch path.
#
# Run with: bats ci/check-version-pins.bats

SCRIPT="${BATS_TEST_DIRNAME}/check-version-pins.sh"

setup() {
    POM="${BATS_TEST_TMPDIR}/pom.xml"
    BOOT_POM="${BATS_TEST_TMPDIR}/spring-boot-dependencies-4.1.1.pom"
    EXCEPTIONS="${BATS_TEST_TMPDIR}/exceptions.txt"
    : > "${EXCEPTIONS}"

    # Spring Boot BOM fixture: netty 4.2.17.Final, tomcat 11.0.24, logback 1.5.38
    cat > "${BOOT_POM}" <<'EOF'
<project>
    <properties>
        <netty.version>4.2.17.Final</netty.version>
        <tomcat.version>11.0.24</tomcat.version>
        <logback.version>1.5.38</logback.version>
        <jackson-2-bom.version>2.21.5</jackson-2-bom.version>
        <java.version>17</java.version>
    </properties>
</project>
EOF
}

# Writes a project POM with the given version properties (one "<x.version>v</x.version>" per argument)
write_pom() {
    {
        echo '<project>'
        echo '    <properties>'
        echo '        <spring-boot.version>4.1.1</spring-boot.version>'
        local prop
        for prop in "$@"; do
            echo "        ${prop}"
        done
        echo '    </properties>'
        echo '</project>'
    } > "${POM}"
}

run_check() {
    run "${SCRIPT}" --pom "${POM}" --boot-pom "${BOOT_POM}" --exceptions "${EXCEPTIONS}" "$@"
}

@test "pin behind the BOM is an error" {
    write_pom '<netty.version>4.2.16.Final</netty.version>'
    run_check
    [ "${status}" -eq 1 ]
    [[ "${output}" == *"ERROR"*"netty.version"*"4.2.16.Final"*"4.2.17.Final"* ]]
    [[ "${output}" == *"suppresses the newer Spring Boot version"* ]]
    [[ "${output}" == *"1 error(s)"* ]]
}

@test "pin equal to the BOM is an error" {
    write_pom '<netty.version>4.2.17.Final</netty.version>'
    run_check
    [ "${status}" -eq 1 ]
    [[ "${output}" == *"ERROR"*"netty.version"* ]]
    [[ "${output}" == *"pin is redundant"* ]]
}

@test "pin ahead of the BOM is accepted" {
    write_pom '<tomcat.version>11.0.25</tomcat.version>'
    run_check
    [ "${status}" -eq 0 ]
    [[ "${output}" == *"OK"*"tomcat.version"*"11.0.25"*"11.0.24"* ]]
    [[ "${output}" == *"0 error(s)"* ]]
}

@test "property that Spring Boot does not manage is not compared" {
    write_pom '<shedlock.version>7.10.0</shedlock.version>'
    run_check
    [ "${status}" -eq 0 ]
    [[ "${output}" != *"shedlock"* ]]
    [[ "${output}" == *"0 pins compared"* ]]
}

@test "ignored properties are not compared" {
    write_pom '<java.version>25</java.version>'
    run_check
    [ "${status}" -eq 0 ]
    [[ "${output}" != *"java.version"* ]]
}

@test "property reference as value is skipped" {
    write_pom '<netty.version>${some.other.version}</netty.version>'
    run_check
    [ "${status}" -eq 0 ]
    [[ "${output}" != *"netty.version"* ]]
}

@test "pre-release qualifier is reported for review, not as an error" {
    write_pom '<netty.version>4.3.0-RC1</netty.version>'
    run_check
    [ "${status}" -eq 0 ]
    [[ "${output}" == *"REVIEW"*"netty.version"* ]]
    [[ "${output}" == *"pre-release qualifier"* ]]
    [[ "${output}" == *"1 review(s)"* ]]
}

@test "allowlisted pin is skipped with its reason" {
    write_pom '<netty.version>4.2.16.Final</netty.version>'
    echo 'netty.version=held back on purpose' > "${EXCEPTIONS}"
    run_check
    [ "${status}" -eq 0 ]
    [[ "${output}" == *"SKIP"*"netty.version"* ]]
    [[ "${output}" == *"held back on purpose"* ]]
    [[ "${output}" == *"1 allowed"* ]]
}

@test "comments and blank lines in the exceptions file are ignored" {
    write_pom '<netty.version>4.2.16.Final</netty.version>'
    printf '# a comment\n\nnetty.version=still allowed # trailing comment\n' > "${EXCEPTIONS}"
    run_check
    [ "${status}" -eq 0 ]
    [[ "${output}" == *"allowed: still allowed"* ]]
    [[ "${output}" != *"trailing comment"* ]]
}

@test "exception for a pin that is no longer a finding is reported as stale" {
    write_pom '<tomcat.version>11.0.25</tomcat.version>'
    echo 'tomcat.version=no longer needed' > "${EXCEPTIONS}"
    run_check
    [ "${status}" -eq 0 ]
    [[ "${output}" == *"STALE"*"tomcat.version"* ]]
    [[ "${output}" == *"1 stale exception(s)"* ]]
}

@test "several findings are all reported" {
    write_pom '<netty.version>4.2.16.Final</netty.version>' \
              '<logback.version>1.5.38</logback.version>' \
              '<tomcat.version>11.0.25</tomcat.version>'
    run_check
    [ "${status}" -eq 1 ]
    [[ "${output}" == *"2 error(s)"* ]]
    [[ "${output}" == *"OK"*"tomcat.version"* ]]
}

@test "--warn-only reports findings but exits 0" {
    write_pom '<netty.version>4.2.16.Final</netty.version>'
    run_check --warn-only
    [ "${status}" -eq 0 ]
    [[ "${output}" == *"ERROR"*"netty.version"* ]]
}

@test "--report writes the report to a file" {
    write_pom '<netty.version>4.2.16.Final</netty.version>'
    run_check --report "${BATS_TEST_TMPDIR}/report.txt"
    [ "${status}" -eq 1 ]
    [[ "$(cat "${BATS_TEST_TMPDIR}/report.txt")" == *"ERROR"*"netty.version"* ]]
}

@test "--print-spring-boot-version prints the pinned version only" {
    write_pom '<netty.version>4.2.16.Final</netty.version>'
    run_check --print-spring-boot-version
    [ "${status}" -eq 0 ]
    [ "${output}" = "4.1.1" ]
}

@test "missing spring-boot.version property fails" {
    printf '<project>\n    <properties>\n        <netty.version>4.2.16.Final</netty.version>\n    </properties>\n</project>\n' > "${POM}"
    run_check
    [ "${status}" -eq 2 ]
    [[ "${output}" == *"no <spring-boot.version> property"* ]]
}

@test "missing project POM fails" {
    run "${SCRIPT}" --pom "${BATS_TEST_TMPDIR}/absent.xml" --boot-pom "${BOOT_POM}"
    [ "${status}" -eq 2 ]
    [[ "${output}" == *"POM not found"* ]]
}

@test "missing Spring Boot BOM fails" {
    write_pom '<netty.version>4.2.16.Final</netty.version>'
    run "${SCRIPT}" --pom "${POM}" --boot-pom "${BATS_TEST_TMPDIR}/absent.pom"
    [ "${status}" -eq 2 ]
    [[ "${output}" == *"Spring Boot BOM not found"* ]]
}

@test "unknown argument fails with usage" {
    run "${SCRIPT}" --bogus
    [ "${status}" -eq 2 ]
    [[ "${output}" == *"unknown argument: --bogus"* ]]
    [[ "${output}" == *"Usage:"* ]]
}

@test "BOM is fetched with the Maven wrapper when --boot-pom is not given" {
    write_pom '<netty.version>4.2.16.Final</netty.version>'
    # mvnw stub: records its arguments and writes the BOM into the requested outputDirectory
    cat > "${BATS_TEST_TMPDIR}/mvnw" <<EOF
#!/bin/bash
echo "\$@" > "${BATS_TEST_TMPDIR}/mvnw.log"
for arg in "\$@"; do
    case "\${arg}" in
        -DoutputDirectory=*) out="\${arg#-DoutputDirectory=}" ;;
    esac
done
mkdir -p "\${out}"
cp "${BOOT_POM}" "\${out}/spring-boot-dependencies-4.1.1.pom"
EOF
    chmod +x "${BATS_TEST_TMPDIR}/mvnw"

    run "${SCRIPT}" --pom "${POM}" --exceptions "${EXCEPTIONS}" --settings "${BATS_TEST_TMPDIR}/settings.xml"
    [ "${status}" -eq 1 ]
    [[ "${output}" == *"ERROR"*"netty.version"* ]]
    local args="$(cat "${BATS_TEST_TMPDIR}/mvnw.log")"
    [[ "${args}" == *"dependency:copy"* ]]
    [[ "${args}" == *"-Dartifact=org.springframework.boot:spring-boot-dependencies:4.1.1:pom"* ]]
    [[ "${args}" == *"-s ${BATS_TEST_TMPDIR}/settings.xml"* ]]
}

@test "fetch failure is reported" {
    write_pom '<netty.version>4.2.16.Final</netty.version>'
    printf '#!/bin/bash\nexit 1\n' > "${BATS_TEST_TMPDIR}/mvnw"
    chmod +x "${BATS_TEST_TMPDIR}/mvnw"
    run "${SCRIPT}" --pom "${POM}" --exceptions "${EXCEPTIONS}"
    [ "${status}" -eq 2 ]
    [[ "${output}" == *"could not fetch"* ]]
}
