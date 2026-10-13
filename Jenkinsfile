pipeline {
    agent any

    stages {
        stage('Docker sanity check') {
            steps {
                script {
                    // Find Docker even when the Jenkins Windows service has a
                    // different PATH from the interactive user account.
                    def dockerExe = bat(
                        returnStdout: true,
                        script: '''@where docker 2>nul
@if exist "C:\\Program Files\\Docker\\Docker\\resources\\bin\\docker.exe" @echo C:\\Program Files\\Docker\\Docker\\resources\\bin\\docker.exe
@if exist "C:\\ProgramData\\DockerDesktop\\version-bin\\docker.exe" @echo C:\\ProgramData\\DockerDesktop\\version-bin\\docker.exe
@exit /b 0'''
                    ).trim().readLines().find { it?.trim() }

                    if (!dockerExe) {
                        error '''Docker is not installed or is not visible to the Jenkins service.
Install Docker Desktop or Docker Engine on this agent, add its CLI directory to the SYSTEM PATH,
restart the Jenkins service, and verify with: where docker && docker info'''
                    }

                    // Make the discovered CLI available to docker.build and dockerImage.inside.
                    def dockerDir = dockerExe.substring(0, dockerExe.lastIndexOf('\\'))
                    env.PATH = "${dockerDir};${env.PATH}"
                    bat 'docker --version'
                    bat 'docker info'
                }
            }
        }

        stage('Build') {
            steps {
                script {
                    // Build the Docker image using the Jenkins Docker DSL
                    dockerImage = docker.build('flaskapp')
                }
            }
        }

        stage('Dev') {
            steps {
                script {
                    // Run a development container, exposing port 5000
                    dockerImage.inside('-p 5000:5000') {
                        bat 'echo Dev container started'
                        // Optional: start your Flask app here
                        // bat 'python app.py &'
                    }
                }
            }
        }

        stage('Test') {
            steps {
                script {
                    // Run tests inside a fresh container
                    dockerImage.inside {
                        bat 'pip install -r requirements.txt'
                        bat 'python -m unittest discover -v'
                    }
                }
            }
        }
    }

    post {
        success { echo 'Finished: SUCCESS' }
        failure { echo 'Finished: FAILURE' }
    }
}
