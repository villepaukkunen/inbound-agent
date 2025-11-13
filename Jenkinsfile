pipeline {
    agent {
        kubernetes {
            yaml '''
            apiVersion: v1
            kind: Pod
            spec:
              containers:
              - name: buildah
                image: quay.io/buildah/stable
                command:
                - cat
                tty: true
                securityContext:
                  privileged: true
            '''
        }
    }
    environment {
        DH_CREDS = credentials('docker-hub-credentials')
    }
    triggers {
        pollSCM 'H/5 * * * *'
    }
    stages {
        stage('Set image tag') {
            steps {
                script{
                    env.IMAGE_TAG = sh(
                        script: ''' curl -sX GET https://raw.githubusercontent.com/villepaukkunen/inbound-agent/refs/heads/main/Dockerfile | grep FROM | awk -F ':' '/inbound-agent/{print $2;exit}' ''',
                        returnStdout: true).trim()
                }
            }
        }
        stage('Build image') {
            steps {
                container('buildah') {
                    sh '''
                    buildah build -t villepaukkunen/inbound-agent:$IMAGE_TAG .
                    '''
                }
            }
        }
        stage('Tag image') {
            steps {
                container('buildah') {
                    sh '''
                    buildah tag villepaukkunen/inbound-agent:$IMAGE_TAG villepaukkunen/inbound-agent:latest
                    '''
                }
            }
        }
        stage('Login to Docker Hub') {
            steps {
                container('buildah') {
                    sh '''
                    buildah login -u $DH_CREDS_USR -p $DH_CREDS_PSW docker.io
                    '''
                }
            }
        }
        stage('Push image') {
            steps {
                container('buildah') {
                    sh '''
                    buildah push villepaukkunen/inbound-agent:$IMAGE_TAG
                    buildah push villepaukkunen/inbound-agent:latest
                    '''
                }
            }
        }
    }
    post {
        always {
            container('buildah') {
                sh '''
                buildah logout docker.io
                '''
            }
        }
    }
}