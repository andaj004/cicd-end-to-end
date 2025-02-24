pipeline {
    agent any
    
    environment {
        IMAGE_TAG = "${BUILD_NUMBER}"
    }
    
    stages {
        stage('Checkout GitHub Repo') {
            steps {
                git credentialsId: '2df480f3-06f0-47c9-a9f6-e23bf635689a', url: 'https://github.com/andaj004/cicd-end-to-end', branch: 'main'
                echo 'Checked out GitHub Repo'
                sh 'ls -l'  // List files in the workspace to confirm the repo content
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo 'Building Docker Image'
                    // Running the Docker build directly on the EC2 instance
                    sh """
                        docker build -t andaj/cicd-e2e:${IMAGE_TAG} .
                        docker images  # List the created images to verify build
                    """
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    docker.withCredentials([usernamePassword(credentialsId: '340b7d3b-ae7b-4e22-8ed5-264393f66da4', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASSWORD')]) {
                        echo 'Pushing Docker Image'
                        sh '''
                            docker login -u $DOCKER_USER -p $DOCKER_PASSWORD
                            docker push andaj/cicd-e2e:$IMAGE_TAG
                            docker images  # Confirm if the image is there before pushing
                        '''
                    }
                }
            }
        }

        stage('Checkout Kubernetes Manifests') {
            steps {
                git credentialsId: '2df480f3-06f0-47c9-a9f6-e23bf635689a', url: 'https://github.com/andaj004/cicd-demo-manifests-repo.git', branch: 'main'
                echo 'Checked out Kubernetes Manifests Repo'
                sh 'ls -l'  // List files in the workspace to confirm the presence of deploy.yaml
            }
        }

        stage('Update Kubernetes Manifest & Push to Repo') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: '2df480f3-06f0-47c9-a9f6-e23bf635689a', usernameVariable: 'GIT_USERNAME', passwordVariable: 'GIT_PASSWORD')]) {
                        sh '''
                            echo 'Updating deploy.yaml with Build Number'
                            cat deploy.yaml  # Check the original content of the file
                            sed -i "s/32/${BUILD_NUMBER}/g" deploy.yaml
                            cat deploy.yaml  # Verify the change after sed
                            git add deploy.yaml
                            git commit -m "Updated the deploy yaml | Jenkins Pipeline"
                            git push https://$GIT_USERNAME:$GIT_PASSWORD@github.com/andaj004/cicd-demo-manifests-repo.git HEAD:main
                        '''
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    withCredentials([file(credentialsId: 'k8s-credentials', variable: 'K8S_CONFIG')]) {
                        sh '''
                            export KUBECONFIG=$K8S_CONFIG
                            echo 'Deploying to Kubernetes'
                            kubectl apply -f deploy.yaml
                            kubectl rollout status deployment/cicd-e2e-deployment
                            kubectl get deployments  # Verify if the deployment is updated
                        '''
                    }
                }
            }
        }
    }
}
