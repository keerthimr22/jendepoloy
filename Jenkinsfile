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
                    powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File ci\\bootstrap-python.ps1
                    if errorlevel 1 exit /b 1
                    if not exist "%PYTHON%" "%WORKSPACE%\\.python\\python.exe" -m venv .venv
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
