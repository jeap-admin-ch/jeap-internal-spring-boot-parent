# Pact broker configuration

Note: This internal parent retains the existing default of `https://pactbroker.bit.admin.ch/` for the Pact broker URL.
This is transitional. The default will be removed in a follow-up major release.

## Select the default Pact broker for all your Maven projects 

Merge this fragment into your existing Maven settings:

```xml
<profiles>
    <profile>
        <id>jeap-pact-broker</id>
        <properties>
            <jeap.pact.broker.default-url>https://broker.example.org/pact/</jeap.pact.broker.default-url>
        </properties>
    </profile>
</profiles>
<activeProfiles>
    <activeProfile>jeap-pact-broker</activeProfile>
</activeProfiles>
```

## Override the default Pact broker selection in a specific project

For a project or active project profile, set:

```xml
<properties>
    <pactbroker.url>https://broker.example.org/pact/</pactbroker.url>
</properties>
```

For one invocation, use `mvn -Dpactbroker.url=https://broker.example.org/pact/ test`.
