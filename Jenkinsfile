pipeline {
    agent {
        label 'dotnet'
    }

    environment {
        IMAGE_NAME = 'ghcr.io/hknyrmg/js-dotnet-demo'
        IMAGE_TAG = "${BUILD_NUMBER}"
        OPENSHIFT_SERVER = 'https://api.rm3.7wse.p1.openshiftapps.com:6443'
        OPENSHIFT_NAMESPACE = 'hknyrmg-dev'
        OPENSHIFT_DEPLOYMENT = 'js-dotnet-demo'
        OPENSHIFT_CONTAINER = 'js-dotnet-demo'
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
                    set -eu

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

        stage('Deploy to OpenShift') {
            steps {
                withCredentials([
                    string(
                        credentialsId: 'openshift-token',
                        variable: 'OPENSHIFT_TOKEN'
                    )
                ]) {
                    sh '''
                        set -eu

                        echo "OpenShift API bağlantısı kontrol ediliyor..."

                        oc login "$OPENSHIFT_SERVER" \
                            --token="$OPENSHIFT_TOKEN"

                        oc project "$OPENSHIFT_NAMESPACE"

                        echo "Deployment imajı güncelleniyor..."

                        oc set image \
                            "deployment/${OPENSHIFT_DEPLOYMENT}" \
                            "${OPENSHIFT_CONTAINER}=${IMAGE_NAME}:${IMAGE_TAG}"

                        echo "Yeni pod'un hazır olması bekleniyor..."

                        oc rollout status \
                            "deployment/${OPENSHIFT_DEPLOYMENT}" \
                            --timeout=180s

                        echo "OpenShift deployment başarılı."

                        oc logout
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline başarılı. Image: ${IMAGE_NAME}:${IMAGE_TAG}"
            echo "OpenShift deployment tamamlandı."
        }

        failure {
            echo 'Pipeline başarısız. Hata için ilgili stage loglarını kontrol et.'
        }

        always {
            echo 'Pipeline tamamlandı.'
        }
    }
}
