# jEAP Internal Spring Boot Parent

`jeap-internal-spring-boot-parent` is the internal Maven parent POM (packaging `pom`) used to build
the jEAP libraries. It inherits from `org.springframework.boot:spring-boot-dependencies` and
centralizes dependency management, plugin management and build configuration so that every jEAP
library shares the same Java baseline, Spring Boot version and build conventions. It deliberately
contains **no jEAP dependencies** to avoid circular dependencies between the jEAP libraries and their
own build parent.

* Inherits `spring-boot-dependencies` `4.1.0` and imports `spring-cloud-dependencies`, the AWS SDK
  BOM and the Testcontainers BOM
* Sets the Java / `maven.compiler.release` baseline to `25`
* Manages additional dependencies not covered by Spring Boot (ShedLock, Togglz, Pact, Bouncy Castle,
  rest-assured, Logstash, Amazon Corretto Crypto Provider) plus CVE-driven version overrides
* Manages build plugins (compiler, Surefire/Failsafe, JaCoCo, git-commit-id, Lombok delombok, source
  and Javadoc, Pact, license compliance, GPG and Maven Central publishing)
* Provides reusable profiles for version bumping, consumer-driven contract publishing and releasing

For the full jEAP usage documentation see **[https://jeap-admin-ch.github.io/docs/using-jeap](https://jeap-admin-ch.github.io/docs/using-jeap)**.

## Documentation

| Topic                                                      | File                                                   |
|------------------------------------------------------------|--------------------------------------------------------|
| Getting started (use this parent in a library/application) | [docs/getting-started.md](docs/getting-started.md)     |
| Dependency & plugin management overview                    | [docs/dependency-management.md](docs/dependency-management.md) |

## Changes
This library is versioned using [Semantic Versioning](http://semver.org/) and all changes are documented in 
[CHANGELOG.md](./CHANGELOG.md) following the format defined in [Keep a Changelog](http://keepachangelog.com/).

## Note

This repository is part the open source distribution of jEAP. See [github.com/jeap-admin-ch/jeap](https://github.com/jeap-admin-ch/jeap)
for more information.

## License

This repository is Open Source Software licensed under the [Apache License 2.0](./LICENSE).
