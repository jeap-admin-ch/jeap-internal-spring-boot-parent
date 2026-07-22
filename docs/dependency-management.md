# Dependency & plugin management

This parent centralizes the versions and build configuration shared by the jEAP libraries. The bulk
of dependency versions come from the inherited `spring-boot-dependencies` BOM; this page summarizes
what the parent adds **on top** of Spring Boot. It is an orientation, not a full BOM listing — consult
`pom.xml` for the authoritative versions.

## Key properties

| Property                 | Purpose                                           |
|--------------------------|---------------------------------------------------|
| `java.version`           | Java baseline (`25`)                              |
| `maven.compiler.release` | Compiler release level (`25`)                     |
| `spring-boot.version`    | Spring Boot version; keep in sync with `<parent>` |
| `spring-cloud.version`   | Spring Cloud BOM version                          |
| `aws.sdk.version`        | AWS SDK BOM version                               |
| `testcontainers.version` | Testcontainers BOM version                        |
| `pact-jvm.version`       | Pact (consumer-driven contracts) version          |

## Imported BOMs

The `<dependencyManagement>` section imports these BOMs (`type=pom`, `scope=import`):

- `org.springframework.cloud:spring-cloud-dependencies`
- `software.amazon.awssdk:bom`
- `org.testcontainers:testcontainers-bom`

## Additionally managed dependencies

Versions for libraries not covered (or pinned differently) by Spring Boot, including:

- ShedLock (`shedlock-spring`, `shedlock-provider-jdbc-template`)
- Togglz (`togglz-spring-boot-starter`, `togglz-spring-security`)
- Pact JUnit 5 (consumer and provider, `test` scope)
- Bouncy Castle (`bcpkix-jdk18on`, `bcprov-jdk18on`) and the Amazon Corretto Crypto Provider
- `rest-assured` (and its `spring-mock-mvc`, `json-path`, `xml-path` modules)
- `logstash-logback-encoder`, `commons-collections4`, `protobuf-java`
- Lombok (also added as a `provided` dependency to every project)

## Version overrides due to CVEs

CVE-driven version overrides are grouped at the bottom of the version properties in `pom.xml`, each
with a comment naming the CVE. How to pin depends on whether Spring Boot manages the artifact:

- **Managed by Spring Boot** (e.g. `org.postgresql:postgresql` via `postgresql.version`): override
  the version property only. The inherited `spring-boot-dependencies` entry references that
  property, so no `<dependencyManagement>` entry is needed.
- **Not managed by Spring Boot** (e.g. the transitive `org.lz4:lz4-java`): add both a version
  property and a `<dependencyManagement>` entry.

Revisit the overrides whenever the Spring Boot version is upgraded and remove any that the new
Spring Boot BOM already covers.

## Managed plugins

`<pluginManagement>` and the active `<build><plugins>` configure the shared build, including:

- `maven-compiler-plugin` (release `25`, full annotation processing, `-Xlint` flags)
- `maven-surefire-plugin` / `maven-failsafe-plugin` (incl. Pact provider verification system properties)
- `jacoco-maven-plugin` for coverage
- `git-commit-id-maven-plugin` for build/git metadata
- `lombok-maven-plugin` (delombok), `maven-source-plugin`, `maven-javadoc-plugin`
- `au.com.dius.pact.provider:maven` for contract publishing
- License compliance (`org.honton.chas:license-maven-plugin`) and third-party license generation
  (`org.codehaus.mojo:license-maven-plugin` with the `jeap-license-template`)
- `maven-gpg-plugin` and `jeap-central-publishing-maven-plugin` for Maven Central releases

## Profiles

- `bump-patch-version` / `bump-minor-version` / `bump-major-version` — bump the project version via
  the `versions-maven-plugin` (e.g. `mvn -Pbump-patch-version -N validate`).
- `cdct-enable-publishing-jenkins` / `cdct-enable-publishing-local` — enable publishing of
  consumer-driven contracts and verification results.
- `internal-parent-build-only` — license compliance/third-party generation for internal builds.
- `maven-central-publish` — GPG signing and publishing to Maven Central.

## Related

- [Getting started](getting-started.md)
- [jeap-internal-spring-boot-parent](../README.md)
- [jEAP usage documentation](https://jeap-admin-ch.github.io/docs/using-jeap)
