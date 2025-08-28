pipeline {
  agent none   // không dùng agent global, mỗi stage chọn agent riêng

  environment {
    DOCKER_CONFIG = '/kaniko/.docker'
    REGISTRY   = 'image-registry.openshift-image-registry.svc:5000'
    NAMESPACE  = 'ac-test'  // namespace của bạn
    IMAGE_NAME = 'test'
    IMAGE_TAG  = 'latest'
  }

  stages {
    stage('Checkout') {
      agent { label 'nodejs-build' }
      steps {
        checkout scm
        stash includes: '**', name: 'source'
      }
    }

    stage('Build Node.js') {
      agent { label 'nodejs-build' }
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
          sh '/kaniko/executor --context=`pwd` --dockerfile=`pwd`/Dockerfile  --destination=default-route-openshift-image-registry.apps.staging.xplat.online/ac-test/test:latest'
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
