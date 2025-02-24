pipeline {
    agent any
    
    environment {
        IMAGE_TAG = "${BUILD_NUMBER}"
        DEPLOY_PATH = "deploy/deploy.yaml"  // Path to your deployment manifest
        SERVICE_PATH = "deploy/service.yaml"  // Path to your service manifest
    }
    
    stages {
        stage('Checkout GitHub Repo') {
            steps {
                git credentialsId: '2df480f3-06f0-47c9-a9f6-e23bf635689a', 
                    url: 'https://github.com/andaj004/cicd-end-to-end', 
                    branch: 'main'
                echo 'Checked out GitHub Repo'
                sh 'ls -l deploy/'  // Verify manifests directory
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo 'Building Docker Image'
                    sh """
                        docker build -t andaj/cicd-e2e:${IMAGE_TAG} .
                        docker images
                    """
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', '340b7d3b-ae7b-4e22-8ed5-264393f66da4') {
                        echo 'Pushing Docker Image'
                        sh "docker push andaj/cicd-e2e:${IMAGE_TAG}"
                    }
                }
            }
        }

        stage('Update Kubernetes Manifest') {
            steps {
                script {
                    withCredentials([usernamePassword(
                        credentialsId: '2df480f3-06f0-47c9-a9f6-e23bf635689a',
                        usernameVariable: 'GIT_USER',
                        passwordVariable: 'GIT_PASS'
                    )]) {
                        sh """
                            echo 'Updating ${DEPLOY_PATH}'
                            sed -i "s/andaj\\/cicd-e2e:[0-9]*/andaj\\/cicd-e2e:${IMAGE_TAG}/g" ${DEPLOY_PATH}
                            git add ${DEPLOY_PATH}
                            git commit -m "Update image to ${IMAGE_TAG}"
                            git push https://${GIT_USER}:${GIT_PASS}@github.com/andaj004/cicd-end-to-end.git HEAD:main
                        """
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    withCredentials([file(credentialsId: 'minikube-jenkins', variable: 'K8S_CONFIG')]) {
                        sh """
                            export KUBECONFIG=${K8S_CONFIG}
                            echo 'Deploying Deployment'
                            kubectl apply -f ${DEPLOY_PATH}
                            echo 'Deploying Service'
                            kubectl apply -f ${SERVICE_PATH}
                            kubectl rollout status deployment/todo-app
                            kubectl get pods
                            kubectl get svc
                        """
                    }
                }
            }
        }
    }
}
