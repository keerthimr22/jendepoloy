pipeline {
    agent any

    stages {
        stage('Docker sanity check') {
            steps {
                script {
                    // Docker Desktop is installed per-user on this Windows machine,
                    // so its CLI may not be on the Jenkins service PATH.
                    def dockerExe = bat(
                        returnStdout: true,
                        script: '''@echo off
@where docker 2>nul
@for /d %%U in ("C:\\Users\\*") do @if exist "%%~fU\\AppData\\Local\\Programs\\DockerDesktop\\resources\\bin\\docker.exe" @echo %%~fU\\AppData\\Local\\Programs\\DockerDesktop\\resources\\bin\\docker.exe
@if exist "C:\\Program Files\\Docker\\Docker\\resources\\bin\\docker.exe" @echo C:\\Program Files\\Docker\\Docker\\resources\\bin\\docker.exe
@exit /b 0'''
                    ).trim().readLines().find { it?.trim()?.toLowerCase()?.endsWith('docker.exe') }

                    if (!dockerExe) {
                        error '''Docker Desktop CLI was not found. Install Docker Desktop on this agent and start it once.'''
                    }

                    def dockerDir = dockerExe.substring(0, dockerExe.lastIndexOf('\\'))
                    env.PATH = "${dockerDir};${env.PATH}"
                    bat 'docker --version'

                    def daemonStatus = bat(returnStatus: true, script: '@docker info >nul 2>&1')
                    if (daemonStatus != 0) {
                        error '''Docker CLI was found, but Jenkins cannot access Docker Engine. This Jenkins service runs as LocalSystem. In Windows Services, change Jenkins Log On to the same Windows account that runs Docker Desktop, restart Docker Desktop and Jenkins, then run this job again.'''
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                bat 'docker build -t flaskapp .'
            }
        }

        stage('Select available ports') {
            steps {
                script {
                    def ports = bat(
                        returnStdout: true,
                        script: '@powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File ci\\select-ports.ps1'
                    ).trim().readLines()

                    if (ports.size() != 2) {
                        error 'Could not select two available localhost ports.'
                    }

                    env.DEV_PORT = ports[0].trim()
                    env.TEST_PORT = ports[1].trim()
                    echo "Development container: http://localhost:${env.DEV_PORT}"
                    echo "Test container: http://localhost:${env.TEST_PORT}"
                }
            }
        }

        stage('Run Dev Container') {
            steps {
                bat '''
                    @echo off
                    docker rm -f dev-container 2>nul
                    docker run -d --name dev-container -p 127.0.0.1:%DEV_PORT%:5000 flaskapp
                '''
            }
        }

        stage('Run Test Container') {
            steps {
                bat '''
                    @echo off
                    docker rm -f test-container 2>nul
                    docker run -d --name test-container -p 127.0.0.1:%TEST_PORT%:5000 flaskapp
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
