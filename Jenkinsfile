
pipeline {
    agent any

    environment {
        IMAGE_NAME    = "anujdbhure/mindease-ai"
        IMAGE_TAG     = "v${BUILD_NUMBER}"
        REGISTRY_CRED = "dockerhub-credentials"
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

                sh '''
                    set -e

                    python3 -m venv .venv
                    . .venv/bin/activate

                    python -m pip install --upgrade pip
                    python -m pip install --quiet -r requirements.txt
                    python -m pytest tests/ -v
                '''
            }
        }

        stage("Docker Build") {
            steps {
                echo "Building Docker image: ${IMAGE_NAME}:${IMAGE_TAG}"

                sh '''
                    docker build -t "$IMAGE_NAME:$IMAGE_TAG" .
                    docker tag "$IMAGE_NAME:$IMAGE_TAG" "$IMAGE_NAME:latest"
                '''
            }
        }

        stage("Push Image") {
            steps {
                echo "Pushing image to Docker Hub..."

                withCredentials([
                    usernamePassword(
                        credentialsId: "${REGISTRY_CRED}",
                        usernameVariable: "DOCKER_USER",
                        passwordVariable: "DOCKER_PASS"
                    )
                ]) {
                    sh '''
                        set -e

                        echo "$DOCKER_PASS" | docker login \
                            -u "$DOCKER_USER" \
                            --password-stdin

                        docker push "$IMAGE_NAME:$IMAGE_TAG"
                        docker push "$IMAGE_NAME:latest"

                        docker logout
                    '''
                }
            }
        }

        stage("Deploy to Minikube") {
            steps {
                echo "Applying Kubernetes manifests to Minikube..."

                sh '''
                    set -e

                    sed "s|IMAGE_PLACEHOLDER|$IMAGE_NAME:$IMAGE_TAG|g" \
                        k8s/deployment.yaml > deployment-rendered.yaml

                    kubectl apply -f deployment-rendered.yaml
                    kubectl apply -f k8s/service.yaml

                    kubectl rollout status \
                        deployment/mindease-deployment \
                        --timeout=120s
                '''
            }
        }

        stage("Verify") {
            steps {
                echo "Verifying deployment..."

                sh '''
                    set -e

                    kubectl get pods -l app=mindease
                    kubectl get deployment mindease-deployment
                    kubectl get service mindease-service

                    echo "Checking Minikube service URL..."
                    minikube service mindease-service --url
                '''
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully. MindEase AI is deployed on Minikube."
        }

        failure {
            echo "Pipeline failed. Check the Console Output for details."
        }

        always {
            echo "MindEase pipeline execution finished."
        }
    }
}
