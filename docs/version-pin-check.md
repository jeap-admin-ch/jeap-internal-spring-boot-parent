# Version pin check

Every CI build verifies that the version pins in `pom.xml` are still ahead of the versions managed
by the inherited `spring-boot-dependencies` BOM, and fails if one is not.

A version property in this parent only overrides Spring Boot because it uses the same property name
that `spring-boot-dependencies` references in its own dependency management. That makes the pins
checkable by comparing the two `<properties>` blocks, which yields three cases:

| Case     | Meaning                                                                       | Build  |
|----------|-------------------------------------------------------------------------------|--------|
| `AHEAD`  | The pin raises the version above Spring Boot's — it does its job              | passes |
| `EQUAL`  | The pin repeats what Spring Boot already manages — it has no effect           | fails  |
| `BEHIND` | The pin holds the dependency *below* Spring Boot's version — it downgrades it | fails  |

`EQUAL` fails as well because such a pin silently becomes a `BEHIND` pin as soon as Spring Boot
moves ahead. That is how CVE-2026-75595 reached consumers of this parent: the `netty.version` pin
was introduced to fix earlier CVEs, Spring Boot caught up and moved past it, and the stale pin then
downgraded Netty back to the vulnerable version.

Versions with a pre-release qualifier (`-RC1`, `-M1`, `-SNAPSHOT`, …) cannot be ordered reliably and
are reported as `REVIEW` without failing the build.

## Running the script manually

```
ci/check-version-pins.sh [options]
```

Without options the script reads `pom.xml`, fetches the `spring-boot-dependencies` POM of the pinned
`spring-boot.version` with `./mvnw dependency:copy` and prints one line per compared pin:

```
[version-pins] Spring Boot 4.1.1 - 5 pins compared with the BOM

OK     git-commit-id-maven-plugin.version     10.0.1                 > 9.2.0
OK     jackson-2-bom.version                  2.22.1                 > 2.21.5
OK     maven-compiler-plugin.version          3.16.0                 > 3.15.0
OK     protobuf-java.version                  4.36.1                 > 4.35.1
OK     tomcat.version                         11.0.25                > 11.0.24

0 error(s), 0 review(s), 0 allowed, 0 stale exception(s)
```

See `ci/check-version-pins.sh --help` for the available options (POM, pre-fetched BOM, Maven
settings file, exceptions file, report file, warn-only mode). Exit codes are `0` for no findings,
`1` for findings and `2` for a usage or fetch error.

## Fixing a finding

Remove the reported property from `pom.xml` — Spring Boot then supplies the version. If the pin also
has a `<dependencyManagement>` entry that only repeats a version Spring Boot manages, remove that
entry too.

If a pin has to stay although it is equal to or behind Spring Boot — for example because the newer
version breaks a library — add it to
[ci/version-pin-exceptions.txt](../ci/version-pin-exceptions.txt) with a reason:

```
netty.version=held back, 4.3.x breaks the AWS SDK HTTP client
```

Exceptions are printed on every run as `SKIP`, and an exception whose pin is no longer a finding is
reported as `STALE` so the file does not rot.

## In the CI build

Every CI build runs the check before the Maven build and the dependent library validation, so a
stale pin fails the build early. Maven fetches the BOM so that the Nexus mirror, credentials and
proxy configuration of the build are used; the report is written to
`target/version-pin-check/report.txt`.

The check is most valuable on the Renovate branch that bumps `spring-boot.version`: that is exactly
where a pin that Spring Boot has caught up with first becomes visible.

## Testing the script

The script is tested with [bats](https://github.com/bats-core/bats-core); both POMs are fixtures and
Maven is stubbed, so the tests run without network access:

```
bats ci/check-version-pins.bats
```

## Related

- [Dependency & plugin management overview](dependency-management.md)
- [jeap-internal-spring-boot-parent](../README.md)
