
pipeline {
    agent {
        label 'dotnet'
    }

    environment {
        IMAGE_NAME = 'js-dotnet-demo'
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
    }

    post {
        success {
            echo 'Pipeline başarılı. Docker image oluşturuldu.'
        }
        failure {
            echo 'Pipeline başarısız. Önceki stage loglarını kontrol et.'
        }
    }
}
