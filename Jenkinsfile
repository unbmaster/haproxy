pipeline {
    environment {
        registry = "${IMAGE_NAME}"
        BUILD_NUMBER = "${BUILD_NUMBER}"
    }
    agent any

    options {
        skipDefaultCheckout(true)
    }
    stages {

        stage('Checkout GitHub') {
            steps{
                cleanWs()
                script {
                    try {
                        git([url: 'https://github.com/unbmaster/haproxy', branch: 'master'])
                    } catch (Exception e) {
                    sh "echo $e; exit 1"
                    }
                }

                configFileProvider([configFile(fileId: '889f81d4-8708-4f45-a7d4-6e2fb766ae17', variable: 'pem')]) {
                    sh 'cat $pem > /var/lib/jenkins/workspace/${JOB_NAME}/unbmaster.pem'
                }

            }
        }

        stage('Build imagem (Docker)') {
            steps{
                script {
                    sh 'docker service rm haproxy || true'
                    try {
                        dockerImage = docker.build registry + ":$BUILD_NUMBER"
                    } catch (Exception e) {
                        sh "echo $e; exit 1"
                    }
                }
            }
        }

        stage('Deploy Haproxy') {
            steps{

                script {
                    sh 'docker service rm haproxy || true'
                    try {
                        sh 'docker service create \
                            --mode replicated \
                            --replicas 1 \
                            --name haproxy \
                            --network app-net \
                            --publish published=80,target=80,protocol=tcp,mode=ingress \
                            --publish published=443,target=443,protocol=tcp,mode=ingress \
                            --mount type=volume,src=haproxy,dst=/usr/local/etc/haproxy/,ro=true \
                            --dns=127.0.0.11 \
                            haproxytech/haproxy-debian:2.0'
                    } catch (Exception e) {
                        sh "echo $e; exit 1"
                        currentBuild.result = 'ABORTED'
                        error('Erro')
                    }
                }
            }
        }


    }
}