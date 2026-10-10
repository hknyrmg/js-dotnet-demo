
pipeline {
    agent {
        label 'dotnet'
    }

    environment {
        IMAGE_NAME = 'ghcr.io/hknyrmg/js-dotnet-demo'
        IMAGE_TAG = "${BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Restore') {
            steps {
                sh 'dotnet restore'
            }
        }

        stage('Build') {
            steps {
                sh 'dotnet build --configuration Release --no-restore'
            }
        }

        stage('Test') {
            steps {
                sh 'dotnet test --configuration Release --no-build'
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                    docker build \
                        -t ${IMAGE_NAME}:${IMAGE_TAG} \
                        -t ${IMAGE_NAME}:latest \
                        .
                '''
            }
        }

        stage('Docker Push') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'ghcr-credentials',
                        usernameVariable: 'GHCR_USER',
                        passwordVariable: 'GHCR_TOKEN'
                    )
                ]) {
                    sh '''
                        set -eu

                        echo "$GHCR_TOKEN" | docker login ghcr.io \
                            -u "$GHCR_USER" \
                            --password-stdin

                        docker push ${IMAGE_NAME}:${IMAGE_TAG}
                        docker push ${IMAGE_NAME}:latest

                        docker logout ghcr.io
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline başarılı. Image: ${IMAGE_NAME}:${IMAGE_TAG}"
        }

        failure {
            echo 'Pipeline başarısız. Hata için ilgili stage loglarını kontrol et.'
        }

        always {
            echo 'Pipeline tamamlandı.'
        }
    }
}
