pipeline {
    agent any

    stages {
        stage('Docker sanity check') {
            steps {
                bat '''
                    @echo off
                    docker version
                    if errorlevel 1 (
                        echo Docker is unavailable to the Jenkins service. Start Docker Desktop and make sure this service account can use its Docker Engine.
                        exit /b 1
                    )
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                bat 'docker build -t flaskapp .'
            }
        }

        stage('Run Dev Container') {
            steps {
                bat '''
                    @echo off
                    docker rm -f dev-container 2>nul
                    docker run -d --name dev-container -p 5000:5000 flaskapp
                '''
            }
        }

        stage('Run Test Container') {
            steps {
                bat '''
                    @echo off
                    docker rm -f test-container 2>nul
                    docker run -d --name test-container -p 5001:5000 flaskapp
                '''
            }
        }

        stage('Verify Containers') {
            steps {
                bat 'powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File ci\\verify-containers.ps1'
            }
        }
    }

    post {
        success { echo 'Finished: SUCCESS' }
        failure { echo 'Finished: FAILURE' }
    }
}
