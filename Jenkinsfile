pipeline {
    agent any
    
    environment {
        IMAGE_TAG = "${BUILD_NUMBER}"
        DEPLOY_PATH = "deploy/deploy.yaml"
        SERVICE_PATH = "deploy/service.yaml"
    }
    
    stages {
        stage('Checkout GitHub Repo') {
            steps {
                git credentialsId: '2df480f3-06f0-47c9-a9f6-e23bf635689a', 
                    url: 'https://github.com/andaj004/cicd-end-to-end.git', 
                    branch: 'main'
                echo 'Checked out GitHub Repo'
                sh 'ls -l deploy/'
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

        stage('Checkout K8S manifest SCM') {
            steps {
                git credentialsId: '2df480f3-06f0-47c9-a9f6-e23bf635689a', 
                    url: 'https://github.com/andaj004/cicd-end-to-end.git', 
                    branch: 'main'
            }
        }
        
        stage('Update K8S manifest & push to Repo') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: '2df480f3-06f0-47c9-a9f6-e23bf635689a', 
                                                     passwordVariable: 'GIT_PASSWORD', 
                                                     usernameVariable: 'GIT_USERNAME')]) {
                        sh '''
                            echo "Current directory: $(pwd)"  
                            ls -l  
                            ls -l deploy/  
                            cat deploy/deploy.yaml  
                            sed -i "s/andaj\\/cicd-e2e:[0-9]*/andaj\\/cicd-e2e:${IMAGE_TAG}/g" deploy/deploy.yaml  
                            cat deploy/deploy.yaml  
                            git add deploy/deploy.yaml
                            git commit -m 'Updated the deploy yaml | Jenkins Pipeline'
                            git remote -v
                            
                            # Set up Git credentials
                            git config --global user.name "$GIT_USERNAME"
                            git config --global user.email "${GIT_USERNAME}@gmail.com"
                            
                            # Push to GitHub using HTTPS and stored credentials
                            git push https://$GIT_USERNAME:$GIT_PASSWORD@github.com/andaj004/cicd-end-to-end.git HEAD:main
                        '''
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
