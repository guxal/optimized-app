pipeline {
    agent any

    environment {
        ACR_NAME = "myacrregistry"
        ACR_LOGIN_SERVER = "${ACR_NAME}.azurecr.io"
        IMAGE_NAME = "optimized-app"
        IMAGE_TAG = "v${BUILD_NUMBER}"

        AZURE_CREDENTIALS = credentials('azure-service-principal')
        KUBECONFIG = credentials('aks-kubeconfig')
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/<user>/optimized-app.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'npm install'
            }
        }

        stage('Run Tests') {
            steps {
                sh 'npm test'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                    docker build -t ${ACR_LOGIN_SERVER}/${IMAGE_NAME}:${IMAGE_TAG} .
                """
            }
        }

        stage('ACR Login') {
            steps {
                sh """
                    az login --service-principal \
                        -u ${AZURE_CREDENTIALS_USR} \
                        -p ${AZURE_CREDENTIALS_PSW} \
                        --tenant <tenant_id>

                    az acr login --name ${ACR_NAME}
                """
            }
        }

        stage('Push Image to ACR') {
            steps {
                sh """
                    docker push ${ACR_LOGIN_SERVER}/${IMAGE_NAME}:${IMAGE_TAG}
                """
            }
        }

        stage('Deploy to AKS') {
            steps {
                sh """
                    mkdir -p ~/.kube
                    echo "${KUBECONFIG}" > ~/.kube/config

                    kubectl set image deployment/optimized-app \
                        optimized-app=${ACR_LOGIN_SERVER}/${IMAGE_NAME}:${IMAGE_TAG} \
                        -n production
                """
            }
        }
    }

    post {
        success {
            echo 'Deployment completed successfully!'
        }
        failure {
            echo 'Deployment failed. Check logs.'
        }
    }
}
