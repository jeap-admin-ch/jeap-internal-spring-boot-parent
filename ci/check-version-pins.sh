#!/bin/bash
#
# Detects version pins in pom.xml that Spring Boot has caught up with.
#
# A version property in this POM only overrides Spring Boot because it shares the
# name of the property that spring-boot-dependencies uses in its own dependency
# management. Comparing the two <properties> blocks therefore finds every pin that
# no longer raises a version:
#
#   BEHIND  the pin holds a dependency below the version Spring Boot manages - it
#           actively suppresses the newer version (this is how CVE-2026-75595
#           reached consumers of this parent)
#   EQUAL   the pin repeats what Spring Boot already manages - it does nothing
#           today and turns into a BEHIND pin at the next Spring Boot upgrade
#
# Both are reported as errors. Deliberate exceptions belong in the exceptions file.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOOT_BOM_GROUP_ARTIFACT="org.springframework.boot:spring-boot-dependencies"

POM_FILE="${SCRIPT_DIR}/../pom.xml"
BOOT_POM=""
SETTINGS_FILE=""
EXCEPTIONS_FILE="${SCRIPT_DIR}/version-pin-exceptions.txt"
REPORT_FILE=""
WARN_ONLY=""
PRINT_BOOT_VERSION=""
TMP_DIR=""

# Properties that are not dependency versions, or that must not be compared with
# the BOM even if Spring Boot happens to define a property of the same name.
IGNORED_PROPERTIES=(
    "spring-boot.version"
    "java.version"
    "maven.compiler.release"
)

usage() {
    cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [options]

Compares the version pins in pom.xml with the versions managed by the
spring-boot-dependencies BOM of the pinned Spring Boot version, and fails if a
pin is equal to or behind the BOM.

Options:
  -p, --pom <file>              Project POM (default: <repo>/pom.xml)
  -b, --boot-pom <file>         Pre-fetched spring-boot-dependencies POM. Without
                                this, the POM is fetched with 'mvnw dependency:copy'.
  -s, --settings <file>         Maven settings.xml used for the fetch (default: none)
  -e, --exceptions <file>       Exceptions file (default: ci/version-pin-exceptions.txt)
  -r, --report <file>           Write the report to this file as well
  -w, --warn-only               Report findings but exit 0
      --print-spring-boot-version
                                Print the Spring Boot version pinned in the POM and exit
  -h, --help                    Show this help

Exit codes: 0 = no findings, 1 = findings, 2 = usage or fetch error
EOF
}

fail() {
    echo "[version-pins] ERROR: $*" >&2
    exit 2
}

cleanup() {
    [[ -z "${TMP_DIR}" ]] || rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -p|--pom) POM_FILE="${2:-}"; shift 2 ;;
            -b|--boot-pom) BOOT_POM="${2:-}"; shift 2 ;;
            -s|--settings) SETTINGS_FILE="${2:-}"; shift 2 ;;
            -e|--exceptions) EXCEPTIONS_FILE="${2:-}"; shift 2 ;;
            -r|--report) REPORT_FILE="${2:-}"; shift 2 ;;
            -w|--warn-only) WARN_ONLY="true"; shift ;;
            --print-spring-boot-version) PRINT_BOOT_VERSION="true"; shift ;;
            -h|--help) usage; exit 0 ;;
            *) usage >&2; fail "unknown argument: $1" ;;
        esac
    done
    [[ -f "${POM_FILE}" ]] || fail "POM not found: ${POM_FILE}"
}

# Emits "name value" for every '<x.version>value</x.version>' line inside a
# <properties> block. Property references (${...}) are skipped, as they cannot be
# compared without resolving them.
extract_version_properties() {
    local pom="$1"
    sed -n '/<properties>/,/<\/properties>/p' "${pom}" \
        | sed -nE 's|^[[:space:]]*<([A-Za-z0-9._-]+\.version)>([^<$]+)</\1>[[:space:]]*$|\1 \2|p' \
        | sort -u
}

spring_boot_version() {
    local version
    version="$(extract_version_properties "${POM_FILE}" | awk '$1 == "spring-boot.version" { print $2 }')"
    [[ -n "${version}" ]] || fail "no <spring-boot.version> property in ${POM_FILE}"
    echo "${version}"
}

fetch_boot_pom() {
    local version="$1" pom_dir="$2"
    local mvnw="$(dirname "${POM_FILE}")/mvnw"
    [[ -x "${mvnw}" ]] || fail "Maven wrapper not found or not executable: ${mvnw} (use --boot-pom instead)"

    local -a settings_arg=()
    [[ -z "${SETTINGS_FILE}" ]] || settings_arg=("-s" "${SETTINGS_FILE}")

    echo "[version-pins] fetching ${BOOT_BOM_GROUP_ARTIFACT}:${version}:pom" >&2
    (cd "$(dirname "${POM_FILE}")" && "${mvnw}" -q "${settings_arg[@]}" dependency:copy \
        "-Dartifact=${BOOT_BOM_GROUP_ARTIFACT}:${version}:pom" \
        "-DoutputDirectory=${pom_dir}" >&2) \
        || fail "could not fetch ${BOOT_BOM_GROUP_ARTIFACT}:${version}:pom"

    echo "${pom_dir}/spring-boot-dependencies-${version}.pom"
}

is_ignored() {
    local name="$1" ignored
    for ignored in "${IGNORED_PROPERTIES[@]}"; do
        [[ "${name}" != "${ignored}" ]] || return 0
    done
    return 1
}

# A pre-release qualifier makes 'sort -V' unreliable (it ranks 1.0.0-RC1 above
# 1.0.0), so such pins are reported for manual review instead of being judged.
has_prerelease_qualifier() {
    [[ "$1" =~ -([Rr][Cc]|[Mm][0-9]|[Aa][Ll][Pp][Hh][Aa]|[Bb][Ee][Tt][Aa]|[Ss][Nn][Aa][Pp][Ss][Hh][Oo][Tt]) ]]
}

# Strips qualifiers that are not part of the version ordering, so that
# '4.2.16.Final' and '4.2.17.Final' compare as '4.2.16' and '4.2.17'.
comparable_version() {
    local version="$1"
    version="${version%.Final}"
    version="${version%.RELEASE}"
    version="${version%-jre}"
    echo "${version}"
}

# Prints BEHIND, EQUAL or AHEAD for our version ($1) relative to Spring Boot's ($2).
compare_versions() {
    local ours="$(comparable_version "$1")" theirs="$(comparable_version "$2")"
    if [[ "${ours}" == "${theirs}" ]]; then
        echo "EQUAL"
    elif [[ "$(printf '%s\n%s\n' "${ours}" "${theirs}" | sort -V | head -1)" == "${ours}" ]]; then
        echo "BEHIND"
    else
        echo "AHEAD"
    fi
}

exception_reason() {
    local name="$1"
    [[ -f "${EXCEPTIONS_FILE}" ]] || return 0
    sed -E 's/[[:space:]]*#.*$//' "${EXCEPTIONS_FILE}" \
        | awk -F= -v name="${name}" '$1 == name { sub(/^[^=]*=[[:space:]]*/, ""); print; exit }'
}

main() {
    parse_args "$@"

    local boot_version
    boot_version="$(spring_boot_version)"

    if [[ -n "${PRINT_BOOT_VERSION}" ]]; then
        echo "${boot_version}"
        exit 0
    fi

    if [[ -z "${BOOT_POM}" ]]; then
        TMP_DIR="$(mktemp -d)"
        BOOT_POM="$(fetch_boot_pom "${boot_version}" "${TMP_DIR}")"
    fi
    [[ -f "${BOOT_POM}" ]] || fail "Spring Boot BOM not found: ${BOOT_POM}"

    local boot_props="$(extract_version_properties "${BOOT_POM}")"
    [[ -n "${boot_props}" ]] || fail "no version properties found in ${BOOT_POM}"

    local -a errors=() reviews=() skips=() oks=()
    local -a matched_exceptions=()
    local name ours theirs verdict reason

    while read -r name ours; do
        [[ -n "${name}" ]] || continue
        is_ignored "${name}" && continue
        theirs="$(awk -v name="${name}" '$1 == name { print $2; exit }' <<<"${boot_props}")"
        [[ -n "${theirs}" ]] || continue  # not managed by Spring Boot, nothing to compare

        if has_prerelease_qualifier "${ours}" || has_prerelease_qualifier "${theirs}"; then
            reviews+=("$(printf 'REVIEW %-38s %-22s ? %-22s pre-release qualifier, compare manually' \
                "${name}" "${ours}" "${theirs}")")
            continue
        fi

        verdict="$(compare_versions "${ours}" "${theirs}")"
        if [[ "${verdict}" == "AHEAD" ]]; then
            oks+=("$(printf 'OK     %-38s %-22s > %s' "${name}" "${ours}" "${theirs}")")
            continue
        fi

        reason="$(exception_reason "${name}")"
        if [[ -n "${reason}" ]]; then
            matched_exceptions+=("${name}")
            skips+=("$(printf 'SKIP   %-38s %-22s %s %-22s allowed: %s' \
                "${name}" "${ours}" "$([[ "${verdict}" == "EQUAL" ]] && echo '=' || echo '<')" "${theirs}" "${reason}")")
        elif [[ "${verdict}" == "EQUAL" ]]; then
            errors+=("$(printf 'ERROR  %-38s %-22s = %-22s pin is redundant, Spring Boot provides it' \
                "${name}" "${ours}" "${theirs}")")
        else
            errors+=("$(printf 'ERROR  %-38s %-22s < %-22s pin suppresses the newer Spring Boot version' \
                "${name}" "${ours}" "${theirs}")")
        fi
    done < <(extract_version_properties "${POM_FILE}")

    # Exceptions for pins that are no longer equal to or behind Spring Boot have
    # become stale and should be removed from the exceptions file.
    local -a stale=()
    if [[ -f "${EXCEPTIONS_FILE}" ]]; then
        while read -r name; do
            [[ -n "${name}" ]] || continue
            local matched=""
            for matched_name in "${matched_exceptions[@]:-}"; do
                [[ "${name}" != "${matched_name}" ]] || matched="true"
            done
            [[ -n "${matched}" ]] || stale+=("$(printf 'STALE  %-38s exception no longer needed, remove it' "${name}")")
        done < <(sed -E 's/[[:space:]]*#.*$//' "${EXCEPTIONS_FILE}" | awk -F= 'NF > 1 { print $1 }')
    fi

    {
        local compared=$(( ${#errors[@]} + ${#reviews[@]} + ${#skips[@]} + ${#oks[@]} ))
        echo "[version-pins] Spring Boot ${boot_version} - ${compared} pins compared with the BOM"
        echo
        local line
        for line in "${errors[@]:-}" "${reviews[@]:-}" "${skips[@]:-}" "${stale[@]:-}" "${oks[@]:-}"; do
            [[ -z "${line}" ]] || echo "${line}"
        done
        echo
        echo "${#errors[@]} error(s), ${#reviews[@]} review(s), ${#skips[@]} allowed, ${#stale[@]} stale exception(s)"
        if [[ ${#errors[@]} -gt 0 ]]; then
            echo
            echo "A pin that is equal to or behind the Spring Boot BOM no longer raises the version"
            echo "and becomes a downgrade at the next Spring Boot upgrade. Remove it from pom.xml, or"
            echo "add it to $(basename "${EXCEPTIONS_FILE}") with a reason if the pin is deliberate."
            echo "See docs/dependency-management.md."
        fi
    } | tee "${REPORT_FILE:-/dev/null}"

    if [[ ${#errors[@]} -gt 0 && -z "${WARN_ONLY}" ]]; then
        exit 1
    fi
    exit 0
}

main "$@"
