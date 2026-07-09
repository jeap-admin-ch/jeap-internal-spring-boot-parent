# Dependent library validation

On every branch except `master` and `release/*` (those changes will already have been validated
on a feature branch), the CI build validates that a parent update does not break the main consumer
libraries. After the parent version has been built and published, a build against the snapshot is
started once per library in parallel, waits for the results, and fails the parent build if any validation 
fails. The validated libraries cover the main dependencies managed in the internal parent:

- `jeap-messaging` (Kafka, Avro, protobuf)
- `jeap-spring-boot-starters` (Spring Boot web/security, Togglz, springdoc, rest-assured)
- `jeap-crypto` (AWS KMS/S3, Vault)
- `jeap-spring-boot-config-aws-starter` (Spring Cloud, AWS SDK)
- `jeap-messaging-sequential-inbox` (JPA/Hibernate, PostgreSQL, Flyway, ShedLock)
- `jeap-spring-boot-jwe-starter` (JWE/Nimbus, BouncyCastle, Vault)

The validation job is defined in [verifyDependentRepo.groovy](../verifyDependentRepo.groovy)
and validates one repository per build: it runs
[ci/verify-dependent-repo.sh](../ci/verify-dependent-repo.sh), which clones the repository's
`master` branch, sets its `jeap-internal-spring-boot-parent` version to the freshly published
version and runs the library's full build including integration tests (`./mvnw verify`).

## Running the script manually

```
ci/verify-dependent-repo.sh [options] <repo-name> <parent-version>
```

For example, to validate `jeap-crypto` against a locally relevant parent version:

```
ci/verify-dependent-repo.sh --work-dir /tmp/validation jeap-crypto 8.3.4
```

See `ci/verify-dependent-repo.sh --help` for the available options (branch, work directory,
Maven settings file, clone base URL).

## Testing the script

The script is tested with [bats](https://github.com/bats-core/bats-core); git and Maven are
stubbed, so the tests run without network access:

```
bats ci/verify-dependent-repo.bats
```
