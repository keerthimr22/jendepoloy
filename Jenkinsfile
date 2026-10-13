pipeline {
    agent any

    environment {
        PYTHON = '.venv\\Scripts\\python.exe'
    }

    stages {
        stage('Prepare Python') {
            steps {
                bat '''
                    @echo off
                    python --version
                    if errorlevel 1 (
                        echo Python 3 is required on the Jenkins agent and must be available on PATH.
                        exit /b 1
                    )
                    if not exist "%PYTHON%" python -m venv .venv
                    if errorlevel 1 exit /b 1
                    "%PYTHON%" -m pip install --upgrade pip
                    if errorlevel 1 exit /b 1
                    "%PYTHON%" -m pip install -r requirements.txt
                '''
            }
        }

        stage('Build') {
            steps {
                bat '"%PYTHON%" -m compileall -q app.py'
            }
        }

        stage('Dev smoke check') {
            steps {
                bat '''
                    "%PYTHON%" -c "from app import app; response = app.test_client().get('/'); print(response.get_json()); assert response.status_code == 200 and response.get_json() == {'status': 'ok'}"
                '''
            }
        }

        stage('Test') {
            steps {
                bat '"%PYTHON%" -m unittest discover -v'
            }
        }
    }

    post {
        success { echo 'Finished: SUCCESS' }
        failure { echo 'Finished: FAILURE' }
    }
}
