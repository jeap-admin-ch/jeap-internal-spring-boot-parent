# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres
to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [5.15.0] - 2025-10-02

### Changed

- Updated maven-compiler-plugin from 3.14.0 to 3.14.1
- Updated maven-javadoc-plugin from 3.11.2 to 3.12.0
- Updated shedlock from 6.9.2 to 6.10.0
- Updated exec-maven-plugin from 3.5.1 to 3.6.0
- Updated aws.sdk from 2.32.14 to 2.34.6
- Updated bcpkix-jdk18on fom 1.81 to 1.82
- Updated bcprov-jdk18on fom 1.81 to 1.82
- Updated org.codehaus.mojo-license-maven-plugin from 2.6.0 to 2.7.0


## [5.14.0] - 2025-09-18

### Changed

- Upgraded to Spring Boot 3.5.6.

## [5.13.0] - 2025-08-25

### Changed

- Upgraded to Spring Boot 3.5.5.

## [5.12.1] - 2025-08-14

### Changed

- Added netty with version 4.1.124.Final (replace 4.1.123.Final) to fix CVE-2025-55163

## [5.12.0] - 2025-08-04

### Changed

- Updated Spring Boot from 3.5.3 to 3.5.4
- Updated maven-enforcer-plugin from 3.6.0 to 3.6.1
- Updated shedlock from 6.9.0 to 6.9.2
- Updated exec-maven-plugin from 3.5.0 to 3.5.1
- Updated aws.sdk from 2.31.76 to 2.32.14

## [5.11.0] - 2025-07-04

### Changed

- Updated Spring Boot from 3.4.6 to 3.5.3
- Updated Spring Cloud from 2024.0.1 to 2025.0.0
- Updated spring-security-oauth2-authorization-server from 1.4.3 to 1.5.1
- Updated maven-enforcer-plugin from 3.5.0 to 3.6.0
- Updated build-helper-maven-plugin from 3.6.0 to 3.6.1
- Updated shedlock from 6.8.0 to 6.9.0
- Updated aws.sdk from 2.31.54 to 2.31.76
- Updated bcpkix-jdk18on from 1.80 to 1.81
- Updated bcprov-jdk18on from 1.80 to 1.81
- Updated org.codehaus.mojo-license-maven-plugin from 2.5.0 to 2.6.0
- Updated maven-gpg-plugin from 3.2.7 to 3.2.8
- Updated com.google.protobuf:protobuf-java (managed dependency) from 3.25.5 to 3.25.8
- Removed postgresql as managed dependency
- Removed tomcat-embed-core as managed dependency

## [5.10.2] - 2025-06-18

### Added

- Added com.google.protobuf:protobuf-java as managed dependency with version 3.25.5 (replace 3.25.3) to fix CVE-2024-7254

## [5.10.1] - 2025-06-17

### Added

- Added org.apache.tomcat.embed:tomcat-embed-core as managed dependency with version 10.1.42 (replace 10.1.41) to fix CVE-2025-48988

## [5.10.0] - 2025-06-13

### Added

- Added org.postgresql:postgresql as managed dependency with version 42.7.7 to fix CVE-2025-49146

## [5.9.0] - 2025-06-03

### Changed

- Updated Spring Boot from 3.4.5 to 3.4.6
- Updated git-commit-id-maven-plugin from 9.0.1 to 9.0.2
- Updated shedlock from 6.4.0 to 6.8.0
- Updated exec-maven-plugin from 3.5.0 to 3.5.1
- Updated aws.sdk from 2.31.31 to 2.31.54

## [5.8.1] - 2025-05-26

### Changed

- Automation of jeap maven parent version bump

## [5.8.0] - 2025-04-30

### Changed

- Updated Spring Boot from 3.4.4 to 3.4.5
- Updated spring-security-oauth2-authorization-server from 1.4.2 to 1.4.3
- Updated shedlock from 6.3.0 to 6.4.0
- Updated commons-collections4 from 4.4 to 4.5.0
- Updated jacoco-maven-plugin from 0.8.12 to 0.8.13
- Updated aws.sdk from 2.31.8 to 2.31.31

## [5.7.1] - 2025-04-02

### Changed

- Add EPL 2.0 as acceptable license with different URL

## [5.7.0] - 2025-03-27

### Changed

- Updated Spring Boot from 3.4.3 to 3.4.4
- Updated Spring Cloud from 2024.0.0 to 2024.0.1
- Updated spring-security-oauth2-authorization-server from 1.4.0 to 1.4.2
- Updated maven-compiler-plugin from 3.13.0 to 3.14.0
- Updated maven-javadoc-plugin from 3.11.0 to 3.11.1
- Updated shedlock from 6.0.2 to 6.3.0
- Updated pact-jvm from 4.6.15 to 4.6.17
- Updated aws sdk from 2.30.32 to 2.31.8
- Updated bcpkix-jdk18on from 1.79 to 1.80
- Updated bcprov-jdk18on from 1.79 to 1.80
- Updated org.codehaus.mojo-license-maven-plugin from 2.4.0 to 2.5.0
- Updated jeap-license-template from 1.0.2 to 1.0.3
- Updated AmazonCorrettoCryptoProvider from 2.4.1 to 2.5.0
- Updated commit-id plugin to io.github.git-commit-id:git-commit-id-maven-plugin 9.0.1
- Removed Lombok version (included with Spring Boot)

## [5.6.1] - 2025-03-06

### Fixed

- Fixed license whitelist regexp for URL with + character

## [5.6.0] - 2025-03-06

### Changed

- Updated AWS SDK version from 2.20.91 to 2.30.32

## [5.5.5] - 2025-03-04

### Changed

- Updated Spring Boot to 3.4.3

## [5.5.4] - 2025-02-12

### Changed

- Consume GPG passphrase from env var MAVEN_GPG_PASSPHRASE as recommended by the maven-gpg-plugin
- Update maven-gpg-plugin to latest version 3.2.7

## [5.5.3] - 2025-02-12

### Changed

- Extended the regular expression for matching the 'Eclipse Public License v2.0' to also match
  if the license version is written as "v. 2.0".

## [5.5.2] - 2025-02-11

### Changed

- Include artifact version in maven central deployment name
- Generate git.commit.id property
- Manage dependency AmazonCorrettoCryptoProvider

## [5.5.1] - 2025-02-10

### Changed

- Validate maven central publish first, then deploy to repository

## [5.5.0] - 2025-02-07

### Changed

- Added maven central publish profile
- Updated Spring Boot to 3.4.2

## [5.4.1] - 2024-12-31

### Changed

- Updated Spring Boot to 3.4.1

## [5.4.0] - 2024-12-18

### Changed

- Updated Spring Boot to 3.4.0

## [5.3.0] - 2024-12-06

### Changed

- Prepare repository for Open Source distribution

## [5.2.5] - 2024-11-14

### Changed

- Updated license template to 1.0.2

## [5.2.4] - 2024-11-13

### Changed

- Added profile to run license compliance plugin during the build

## [5.2.3] - 2024-11-13

### Changed

- Added urls / developers information to pom.xml

## [5.2.2] - 2024-11-12

### Changed

- Run aggregate goal for license maven plugin in default (generate-resources) phase to avoid running it in phases
  where dependencies are not yet resolved, and to avoid running it event for CLI invocations of plugins   

## [5.2.1] - 2024-11-07

### Changed

- set release java version instead of source and target for maven compiler plugin

## [5.2.0] - 2024-11-05

### Changed

- Add version/configuration management for license plugins

## [5.1.1] - 2024-10-31

### Changed

- Upgraded spring boot from 3.3.4 to 3.3.5

## [5.1.0] - 2024-09-19

### Changed

- Upgraded spring boot from 3.3.3 to 3.3.4


## [5.0.0] - 2024-09-06

### Changed

- Upgraded Java version from 17 to 21
- Upgraded spring boot from 3.3.2 to 3.3.3
- Upgraded spring-security-oauth2-authorization-server from 1.1.3 to 1.3.2
- Upgraded third party library versions

## [4.11.1] - 2024-08-21

### Changed

- Generate manifest entries including the artifact version in jar files

## [4.11.0] - 2024-08-06

### Changed

- Use project.version as app version for Pacts (removed project.version.without.snapshot)
- Spring Boot 3.3.1 --> 3.3.2 upgrade

## [4.10.0] - 2024-07-12

### Changed

- Upgraded Spring boot version to 3.3.1

## [4.9.0] - 2024-07-03

### Changed

- Set deployAtEnd=true by default for the maven deploy plugin to avoid issues with incomplete publication

## [4.8.3] - 2024-05-02

### Changed

- Spring boot patch version upgrade to 3.2.5

## [4.8.2] - 2024-03-27

### Changed

- Spring boot patch version upgrade to 3.2.4

## [4.8.1] - 2024-03-11
### Added
- Added a pre-configuration for the pact mockserver to add the close header by default to fix failing pact consumer tests that are using cached connections.

## [4.8.0] - 2024-03-04
### Added
- Upgraded from Spring Boot 3.2.2 to 3.2.3.
- Upgraded Pact JVM from 4.6.6 to 4.6.7
- Added dependency management for bcprov-jdk18on (used by the legacy jEAP message encryption feature)

## [4.7.0] - 2024-02-16
### Added
- Added Maven Enforcer Plugin: Checks the use of Reactive and shows a Deprecation-Warning

## [4.6.1] - 2024-02-07
### Changed
- Upgraded pact jvm version to latest fix version 4.6.6.

## [4.6.0] - 2024-02-01
### Changed
- Started to manage the bouncycastle bcpkix-jdk18on version.

## [4.5.0] - 2024-01-25
### Changed
- Upgraded spring boot from 3.2.1 to 3.2.2

## [4.4.1] - 2024-01-22

### Fixed

- Use correct parameter format for the maven-compiler-plugin to fix metadata generation for reflection on method
  parameters

## [4.4.0] - 2024-01-16
### Changed
- Upgraded spring boot from 3.2.0 to 3.2.1

## [4.3.2] - 2024-01-04
### Changed
- Upgraded maven-compiler-plugin from 3.10.1 to 3.12.1

## [4.3.1] - 2023-12-20
### Changed
- Upgraded lombok from 1.18.28 to 1.18.30
- Upgraded jacoco maven plugin from 0.8.8 to 0.8.9

## [4.3.0] - 2023-12-13
### Changed
- Upgraded spring boot from 3.1.2 to 3.2.0
- Upgraded spring cloud from 2022.0.4 to 2023.0.0

## [4.2.0] - 2023-10-09
### Changed
- Add dependency management for Spring Cloud AWS

## [4.1.0] - 2023-09-18
### Changed
- Removed pact branch tagging and WiP pact verification.

## [4.0.1] - 2023-09-08
### Changed
- Fix profile bump-patch-version not marked as inherited

## [4.0.0] - 2023-08-16
### Changed
- Upgraded spring boot from 2.7 to 3.1
- Upgraded spring cloud from 2021.0.5 to 2022.0.4
- Upgraded Togglz from 3.3.3 to 4.0.1 for spring boot 3 compatibility
- Upgraded pact-jvm from 4.3.19 to 4.6.1
- Upgraded Lombok from 1.18.26 to 1.18.28 
- Remove maven-test-plugins.version (use managed version from spring)

## [3.6.0] - 2023-08-09
### Changed
- Upgrade spring boot from 2.7.12 to 2.7.14 

## [3.5.0] - 2023-06-23
### Changed
- Add dependency management for AWS SDK

## [3.4.2] - 2023-06-07
### Changed
- Upgrade spring boot from 2.7.11 to 2.7.12
  - Fixes https://github.com/spring-projects/spring-boot/issues/35163 (health probes not available on CF)

## [3.4.1] - 2023-04-20
### Changed
- Upgraded spring boot from 2.7.8 to 2.7.11

## [3.4.0] - 2023-02-21
### Changed
- Upgraded Java version from 11 to 17
- Upgraded spring boot from 2.7.4 to 2.7.8 and spring cloud from 2021.0.4 to 2021.0.5.
- Upgraded third party library versions

## [3.3.0] - 2022-09-26
### Changed
- Upgraded spring boot from 2.6.6 to 2.7.4 and spring cloud from 2021.0 to 2021.0.4.

## [3.2.0] - 2022-09-09
### Changed
- add version bump profiles

## [3.1.0] - 2022-07-12
### Changed
- add -parameters to Java compiler arguments

## [3.0.0] - 2022-07-11
### Changed
- Upgraded to pact jvm version 4.3.9, will break existing pact tests
- Added pacticipant branch declarations
- Replaced the computed branch tag based verification selection of {master,[develop],[feature]} with a consumer version selector
  selecting feature and main branches as well as deployments and releases.

## [2.4.6] - 2022-06-28
### Changed
- The javadoc generation is per default disabled. To enable the generation set the property `maven.javadoc.skip` to `false` in the pom.xml of your project.

## [2.4.5] - 2022-06-16
### Fixed
- Fixed the length of the short git commit id hash in pact versions to length 12. The configurable default length (7) has been used before.

## [2.4.4] - 2022-06-03
### Changed
- Changed goal of maven-source-plugin from jar to jar-no-fork to avoid duplicate code generation

## [2.3.4] - 2022-05-31
### Changed
- Upgraded spring-cloud-config-server to fix version 3.1.3 in order to get support for hyphens in profile names.

## [2.3.3] - 2022-03-31
### Changed
- Upgraded spring boot from 2.6.5 to 2.6.6 (https://tanzu.vmware.com/security/cve-2022-22965)

## [2.3.2] - 2022-03-31
### Changed
- Pin dependency to spring-cloud-function.version to 3.2.3 due to https://tanzu.vmware.com/security/cve-2022-22963

## [2.3.1] - 2022-03-29
### Changed
- Upgraded spring boot from 2.6.4 to 2.6.5 

## [2.3.0] - 2022-03-09
### Changed
- Upgraded spring boot from 2.6.3 to 2.6.4 and spring cloud from 2021.0.0 to 2021.0.1 

## [2.2.3] - 2022-02-08
### Changed
- Set property spring-boot.version to current spring boot version

## [2.2.2] - 2022-02-08
### Changed
- Spring Boot 2.6.3

## [2.2.1] - 2022-02-03
### Changed
- Remove jvm.config in .mvn Folder 

## [2.2.0] - 2021-12-22
### Changed
- Spring Boot 2.6.2
- Spring Cloud 2021.0.0

## [2.1.6] - 2021-12-10
### Added
- togglz-spring-security

## [2.1.5] - 2021-11-19
### Changed
- Lombok 1.18.22
- Spring Boot 2.5.7

## [2.1.4] - 2021-11-12
### Changed
- Spring Boot 2.5.6
- Spring Cloud 2020.0.4

## [2.1.3] - 2021-11-09
### Fixed
- Bringing back the spring-boot.version maven property.

## [2.1.2] - 2021-10-25
### Changed
- Use spring-boot-dependencies as parent pom instead of pom-type dependency

## [2.1.1] - 2021-10-14
### Changed
- togglz 3.0.0

## [2.1.0] - 2021-09-21
### Added
- Added Togglz v2.9.9 dependency

## [2.0.3]- 2021-08-17

### Fixed

- Fixed misconfiguration of source directories for the Javadoc maven plugin (see JEAP-2445).


## [2.0.2]- 2021-06-22

### Changed

- Spring Boot 2.5.1

## [2.0.1]- 2021-06-04

### Changed

- Pinned nimbus-jose-jwt to 9.9.3 in dependency management to make sure child modules use this version

## [2.0.0] - 2021-06-01

### Changed

* Spring Boot 2.5.0
* Spring Cloud 2020.0.3
* git-commit-id-plugin 4.0.4
* Shedlock 4.23.0
* jacoco-maven-plugin 0.8.7
* pact-jvm 4.2.5

## [1.3.4] - 2021-03-03

### Fixed

* Configuration of git commit ID plugin for dirty check during local CDC test execution

## [1.3.3] - 2021-03-02

### Changed

* Reverting git-commit-id style to the default ('flat').

## [1.3.2] - 2021-02-24

### Changed
* Speed up git-commit-id-plugin by using native git + offline mode

## [1.3.1] - 2020-11-25
### Fixed
* Problem with Javadoc generation for Avro-Classes

## [1.3.0] - 2020-11-24
### Added
* Generate Javadoc and Sources

## [1.2.1] - 2020-09-17
### Changed
* Add goal prepare-agent-integration to jacoco-maven-plugin by default
  
## [1.2.0] - 2020-08-25
### Added
* Adding build-helper-maven-plugin and configurations for consumer driven contract testing with PACT
  using the latest PACT JVM version 4.1.7.

## [1.1.0] - 2020-08-05
### Changed
* Updated to Spring Boot 2.3 and Spring Cloud SR7

## [1.0.0] - 2020-06-16
### Added
* Initial revision
