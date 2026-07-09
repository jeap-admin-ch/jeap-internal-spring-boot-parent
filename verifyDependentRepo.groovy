// Validates that a dependent jEAP library builds against a given version of the
// jeap-internal-spring-boot-parent. Triggered once per library (in parallel).
//
// Jenkins job: BIT/jEAP/jeap.jeap-internal-spring-boot-parent.verify-dependent-library
// (Pipeline script from SCM, script path verifyDependentRepo.groovy — deliberately not named
// Jenkinsfile.* so the seed job does not auto-create a parameterless job for it)

@Library('jeap-microservice-pipeline@v2')
import ch.admin.bit.jeap.microservicePipeline.config.Config
import ch.admin.bit.jeap.microservicePipeline.helper.Docker
import ch.admin.bit.jeap.microservicePipeline.helper.Git
import ch.admin.bit.jeap.microservicePipeline.maven.Maven

pipeline {
    agent { node { label 'docker' } }

    options {
        buildDiscarder(logRotator(numToKeepStr: '20'))
        timeout(time: 30, unit: 'MINUTES')
        timestamps()
    }

    parameters {
        string(name: 'REPO_NAME', defaultValue: '', description: 'Library repository to validate (e.g. jeap-messaging)')
        string(name: 'INTERNAL_PARENT_VERSION', defaultValue: '', description: 'jeap-internal-spring-boot-parent version to validate against')
        string(name: 'REPO_BRANCH', defaultValue: 'master', description: 'Branch of the library repository to validate')
    }

    stages {
        stage('Verify library against internal parent') {
            steps {
                script {
                    if (!params.REPO_NAME || !params.INTERNAL_PARENT_VERSION) {
                        error 'Parameters REPO_NAME and INTERNAL_PARENT_VERSION are required'
                    }
                    currentBuild.description = "${params.REPO_NAME}@${params.REPO_BRANCH} vs parent ${params.INTERNAL_PARENT_VERSION}"
                    Docker docker = new Docker('bit/eclipse-temurin:25', this, 'jenkins')
                    // docker.sock is mounted because the libraries' integration tests use Testcontainers
                    docker.runInContainer('-v /var/run/docker.sock:/var/run/docker.sock', [:]) {
                        sshagent(['bitbucketCredentials']) {
                            Maven maven = new Maven(new Config([:]), new Git(this), this)
                            maven.setup() // writes ${WORKSPACE}/settings.xml (Nexus mirror + credentials)
                            sh label: "Verify ${params.REPO_NAME} with parent ${params.INTERNAL_PARENT_VERSION}",
                               script: "ci/verify-dependent-repo.sh " +
                                       "--work-dir '${WORKSPACE}/dependent-repos' " +
                                       "--settings '${WORKSPACE}/settings.xml' " +
                                       "--branch '${params.REPO_BRANCH}' " +
                                       "'${params.REPO_NAME}' '${params.INTERNAL_PARENT_VERSION}'"
                        }
                    }
                }
            }
        }
    }

    post { always { cleanWs() } }
}
