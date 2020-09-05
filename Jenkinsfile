pipeline {
    environment {
        registry = "unbmaster/haproxy:1.0"
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
                        dockerImage = docker.build registry
                    } catch (Exception e) {
                        sh "echo $e; exit 1"
                    }
                }
            }
        }

        stage('Deploy imagem (DockerHub)') {
            steps{

                script {
                    try {
                        docker.withRegistry( '', 'dockerhub' ) {
                            dockerImage.push()
                        }
                    } catch (Exception e) {
                        ssh "echo $e; exit 1"
                    }
                }
            }
        }

        stage('Deploy Haproxy') {
            steps{

                script {
                    sh 'docker service rm haproxy || true'
                    sleep 5
                    try {
                        sh 'docker service create \
                            --mode replicated \
                            --replicas 1 \
                            --name haproxy \
                            --network app-net \
                            --publish published=80,target=80,protocol=tcp,mode=ingress \
                            --publish published=443,target=443,protocol=tcp,mode=ingress \
                            --mount type=bind,src=/home/taylor/master/services/haproxy,dst=/usr/local/etc/haproxy,ro=true \
                            --dns=127.0.0.11 \
                            unbmaster/haproxy:1.0'
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