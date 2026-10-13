pipeline {
    agent any

    stages {
        stage('Docker sanity check') {
            steps {
                script {
                    // Verify Docker CLI is installed on the agent
                    def rc = bat(returnStatus: true, script: '"C:\\Program Files\\Docker\\Docker\\resources\\bin\\docker.exe" --version')
                    if (rc != 0) {
                        error 'Docker CLI not found on this Jenkins agent. Install Docker or configure a Docker‑enabled agent.'
                    }
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