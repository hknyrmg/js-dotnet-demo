pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build') {
            steps {
                echo 'Kod GitHub üzerinden çekildi!'
                sh 'ls -la'
            }
        }
    }
}
