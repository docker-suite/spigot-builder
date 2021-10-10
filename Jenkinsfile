pipeline {

    agent { label 'docker-agent' }

    stages {
        stage ( "Building spigot-builder 8") {
            steps {
                script {
                    docker.withRegistry('', 'docker-hub-credentials') {
                        sh "make build base=dsuite/maven:3.8-openjdk-8 name=8"
                        sh "make push n=8"
                    }
                }
            }
        }

        stage ( "Building spigot-builder 16") {
            steps {
                script {
                    docker.withRegistry('', 'docker-hub-credentials') {
                        sh "make build base=dsuite/maven:3.8-openjdk-16 name=16"
                        sh "make push n=16"
                    }
                }
            }
        }

        stage ( "Building spigot-builder latest") {
            steps {
                script {
                    docker.withRegistry('', 'docker-hub-credentials') {
                        sh "make push n=latest"
                    }
                }
            }
        }
    }

    post {
        always {
            script {
                sh 'make remove'
            }
        }
        cleanup {
            cleanWs()
        }
    }
}
