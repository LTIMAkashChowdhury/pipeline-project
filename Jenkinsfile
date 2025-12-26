
pipeline {
  agent none

  environment {
    REPO_URL    = 'https://github.com/LTIMAkashChowdhury/pipeline-project'
    REPO_BRANCH = 'main'
    AWS_REGION  = 'ap-south-1'
    AWS_ACCOUNT_ID = '775426683081'
    ECR_REPO    = 'mindtree'
    IMAGE_NAME  = 'mindtreerepo'
    IMAGE_TAG   = "${BUILD_NUMBER}"
    REGISTRY    = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
    CLUSTER_NAME= 'mindtree'
  }

  stages {
    stage('Checkout') {
      agent { label 'controller' }
      steps {
        git branch: "${REPO_BRANCH}", url: "${REPO_URL}"
      }
    }

    stage('Build') {
      agent { label 'build' }
      steps {
        git branch: "${REPO_BRANCH}", url: "${REPO_URL}"
        sh '''
          set -e
          mvn -B -ntp clean package
          [ -f target/ROOT.war ] && cp target/ROOT.war .
        '''
      }
    }

    stage('Docker Build & Push') {
      agent { label 'docker' }
      steps {
        git branch: "${REPO_BRANCH}", url: "${REPO_URL}"
        sh '''
          set -e
          aws ecr get-login-password --region "${AWS_REGION}" \
            | docker login --username AWS --password-stdin "${REGISTRY}"
          docker build --no-cache --pull -t "${IMAGE_NAME}:${IMAGE_TAG}" .
          docker tag "${IMAGE_NAME}:${IMAGE_TAG}" "${REGISTRY}/${ECR_REPO}:${IMAGE_TAG}"
          docker tag "${IMAGE_NAME}:${IMAGE_TAG}" "${REGISTRY}/${ECR_REPO}:latest"
          docker push "${REGISTRY}/${ECR_REPO}:${IMAGE_TAG}"
          docker push "${REGISTRY}/${ECR_REPO}:latest"
        '''
      }
    }

    stage('Deploy') {
      agent { label 'docker' }
      steps {
        sh '''
          set -e
          aws eks update-kubeconfig --region "${AWS_REGION}" --name "${CLUSTER_NAME}"
          kubectl apply -f deployment.yml -f svc.yml
          kubectl set image deployment/tomcat tomcat="${REGISTRY}/${ECR_REPO}:${IMAGE_TAG}" --record
          kubectl rollout status deployment/tomcat --timeout=180s
        '''
      }
    }
  }
}
