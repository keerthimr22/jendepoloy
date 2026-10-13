pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                bat 'docker build -t flaskapp '
            }
        }

        stage('Dev') {
            steps {
                bat 'docker run -d --name dev -p 5000:5000 flaskapp'
            }
        }

        stage('Test') {
            steps {
                bat 'docker run -d --name test -p 5001:5000 flaskapp'
            }
        }
    }
}