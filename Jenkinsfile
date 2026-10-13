pipeline {
    agent any

    environment {
        PYTHON = '.python\\python.exe'
    }

    stages {
        stage('Prepare Python') {
            steps {
                bat '''
                    @echo off
                    powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File ci\\bootstrap-python.ps1
                    if errorlevel 1 exit /b 1
                    "%PYTHON%" -m pip --version
                    if errorlevel 1 exit /b 1
                    "%PYTHON%" -m pip install --disable-pip-version-check --target .python\\packages -r requirements.txt
                    if errorlevel 1 exit /b 1
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
