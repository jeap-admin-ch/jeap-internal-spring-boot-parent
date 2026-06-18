# Getting started

`jeap-internal-spring-boot-parent` is the Maven parent POM used to build the jEAP libraries. Declare
it as your project's `<parent>` to inherit the Java baseline, the Spring Boot version and the shared
dependency, plugin and build configuration.

## Use it as your parent

```xml
<parent>
    <groupId>ch.admin.bit.jeap</groupId>
    <artifactId>jeap-internal-spring-boot-parent</artifactId>
    <version>8.3.2</version>
</parent>
```

## What you get

- **Spring Boot baseline** — inherited from `org.springframework.boot:spring-boot-dependencies`
  (`4.1.0`; the POM also keeps a `spring-boot.version` property for reference), so most dependency
  versions come straight from the Spring Boot BOM. See the
  [Spring Boot dependency versions](https://docs.spring.io/spring-boot/appendix/dependency-versions/index.html).
- **Java baseline** — `java.version` and `maven.compiler.release` set to `25`.
- **Extra managed dependencies and plugins** — see [Dependency & plugin management](dependency-management.md).
- **A `provided`-scoped Lombok dependency** added to every project, plus delombok/Javadoc/source-jar
  wiring for publishing.
- **Reusable profiles** — `bump-patch-version` / `bump-minor-version` / `bump-major-version` for
  version bumps, `cdct-enable-publishing-*` for consumer-driven contract tests, and
  `maven-central-publish` for releasing.

## Difference vs `jeap-spring-boot-parent`

This is the **internal** parent: it provides build infrastructure only and deliberately contains
**no jEAP dependencies**, so it can be used by the jEAP libraries themselves without creating circular
dependencies. The public `jeap-spring-boot-parent` builds on this and additionally pulls in jEAP
starters and BOMs for use by jEAP applications. Application services should use `jeap-spring-boot-parent`,
not this internal parent.

## Related

- [Dependency & plugin management](dependency-management.md)
- [jeap-internal-spring-boot-parent](../README.md)
- [jEAP usage documentation](https://jeap-admin-ch.github.io/docs/using-jeap)
