pipeline {
  agent none   // không dùng agent global, mỗi stage chọn agent riêng

  environment {
    REGISTRY   = 'image-registry.openshift-image-registry.svc:5000'
    NAMESPACE  = 'ac-test'  // namespace của bạn
    IMAGE_NAME = 'test'
    IMAGE_TAG  = "${env.BUILD_NUMBER}"
  }

  stages {
    stage('Checkout') {
      agent { label 'nodejs18' }
      steps {
        checkout scm
        stash includes: '**', name: 'source'
      }
    }

    stage('Build Node.js') {
      agent { label 'nodejs18' }
      environment {
        NPM_CONFIG_PREFIX = '/tmp/.npm-global'
        PATH = "/tmp/.npm-global/bin:${env.PATH}"
      }
      steps {
        unstash 'source'
        container('node') {
          sh '''
            set -xe
            node -v && npm -v
            mkdir -p "$NPM_CONFIG_PREFIX"
            npm ci --no-audit --no-fund --prefer-offline
            npm run build || echo "No build script"
          '''
        }
        stash includes: '**', name: 'build'
      }
    }

    stage('Build & Push Image') {
      agent { label 'kaniko-build' }
      steps {
        unstash 'build'
        container('kaniko') {
          sh '''
            /kaniko/executor \
              --context="${WORKSPACE}" \
              --dockerfile="${WORKSPACE}/Dockerfile" \
              --destination="${REGISTRY}/${NAMESPACE}/${IMAGE_NAME}:${IMAGE_TAG}" \
              --verbosity=info
          '''
        }
      }
    }
  }

  post {
    success {
      echo " Image pushed: ${REGISTRY}/${NAMESPACE}/${IMAGE_NAME}:${IMAGE_TAG}"
    }
  }
}
