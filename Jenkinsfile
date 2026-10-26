pipeline {
    agent any

    environment {
        IMAGE_NAME    = "anujdbhure/mindease-ai"
        IMAGE_TAG     = "v${BUILD_NUMBER}"
        REGISTRY_CRED = "dockerhub-credentials"   // Jenkins credential ID
        KUBECONFIG    = "/var/lib/jenkins/.kube/config"
    }

    stages {

        stage("Checkout") {
            steps {
                echo "Pulling latest code from GitHub..."
                checkout scm
            }
        }

        stage("Build & Test") {
            steps {
                echo "Installing dependencies and running tests..."
                sh """
                  
stage("Build & Test") {
    steps {
        echo "Installing dependencies and running tests..."
        sh '''
            python3 -m venv .venv
            . .venv/bin/activate
            python -m pip install --upgrade pip
            python -m pip install --quiet -r requirements.txt
            python -m pytest tests/ -v
        '''
    }
}

                """
            }
        }

        stage("Docker Build") {
            steps {
                echo "Building Docker image: ${IMAGE_NAME}:${IMAGE_TAG}"
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
                sh "docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest"
            }
        }

        stage("Push Image") {
            steps {
                echo "Pushing image to Docker Hub..."
                withCredentials([usernamePassword(
                    credentialsId: "${REGISTRY_CRED}",
                    usernameVariable: "DOCKER_USER",
                    passwordVariable: "DOCKER_PASS"
                )]) {
                    sh """
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push ${IMAGE_NAME}:${IMAGE_TAG}
                        docker push ${IMAGE_NAME}:latest
                    """
                }
            }
        }

        stage("Deploy to Minikube") {
            steps {
                echo "Applying Kubernetes manifests to Minikube..."
                sh """
                    sed -i 's|IMAGE_PLACEHOLDER|${IMAGE_NAME}:${IMAGE_TAG}|g' k8s/deployment.yaml
                    kubectl apply -f k8s/deployment.yaml
                    kubectl apply -f k8s/service.yaml
                    kubectl rollout status deployment/mindease-deployment --timeout=60s
                """
            }
        }

        stage("Verify") {
            steps {
                echo "Verifying deployment..."
                sh """
                    kubectl get pods -l app=mindease
                    kubectl get deployment mindease-deployment
                    kubectl get service mindease-service
                    echo "App URL: \$(minikube service mindease-service --url)"
                """
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully. MindEase AI is live on Minikube."
        }
        failure {
            echo "Pipeline failed. Check the logs above for details."
        }
    }
}
