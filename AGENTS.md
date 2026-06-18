# AGENTS.md

Guidance for AI coding agents working **in this repository**. For how jEAP is used in a service, see
the jEAP usage docs at <https://jeap-admin-ch.github.io/docs/using-jeap>.

## Project

`jeap-internal-spring-boot-parent` is a single-module Maven **parent POM** (packaging `pom`, no Java
code). It is the internal build parent for the jEAP libraries: it inherits from
`org.springframework.boot:spring-boot-dependencies` and centralizes dependency management, plugin
management and build configuration. It intentionally declares **no jEAP dependencies** to avoid
circular dependencies with the libraries that use it.

## Repository layout

```
pom.xml            # The parent POM: parent, properties, dependencyManagement, pluginManagement, profiles
CHANGELOG.md       # Keep a Changelog format
publiccode.yml     # Open-source metadata (softwareVersion / releaseDate)
Jenkinsfile        # CI pipeline
docs/              # Focused, one-topic-per-file documentation
```

## What lives where in the POM

- `<parent>` — `spring-boot-dependencies` (keep `<version>` in sync with the `spring-boot.version` property).
- `<properties>` — the Java baseline (`java.version`, `maven.compiler.release`), framework versions
  (`spring-boot.version`, `spring-cloud.version`) and plugin/library versions. CVE-driven overrides
  are grouped near the bottom with a comment.
- `<dependencyManagement>` — versions for dependencies not managed by Spring Boot, plus overrides.
- `<build><pluginManagement>` and `<build><plugins>` — shared plugin configuration.
- `<profiles>` — version bumping (`bump-patch/minor/major-version`), consumer-driven contract
  publishing (`cdct-enable-publishing-*`) and release/Maven-Central publishing.

## Conventions

- When changing the Spring Boot version, update **both** the `<parent><version>` and the
  `spring-boot.version` property (the POM has comments reminding of this).
- When bumping the Spring Boot version, check whether any "Version overrides due to CVEs" can be removed.
- Keep additions minimal: prefer relying on the inherited Spring Boot BOM over adding explicit
  managed versions.

## Docs

When changing managed dependencies/plugins or build behaviour, keep the focused files under
[docs/](docs/) and the README index in sync. Keep them short — the parent only needs orientation,
not an exhaustive BOM dump.

## Versioning

- Semantic Versioning; all changes documented in [CHANGELOG.md](./CHANGELOG.md) (Keep a Changelog format).
- This is a single-module repo: bump the project `<version>` directly in `pom.xml`, keeping the
  `-SNAPSHOT` suffix on feature branches (CI removes it when releasing).
- When bumping the version, also update [CHANGELOG.md](./CHANGELOG.md) and the `softwareVersion` /
  `releaseDate` in `publiccode.yml`.
- Use the JIRA ID from the branch name as the commit message prefix (e.g. `JEAP-1234 Short summary`);
  do not use conventional commits.
