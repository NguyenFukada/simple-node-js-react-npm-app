pipeline {
  agent none   

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
      agent { label 'docker-build' }
      steps {
        unstash 'build'
        container('buildah') {
          sh '''
          REGISTRY_HOST="image-registry.openshift-image-registry.svc:5000"
          TOKEN="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)"

          # login bằng SA token
          buildah login -u unused -p "$TOKEN" "$REGISTRY_HOST"

          buildah --storage-driver=vfs bud --layers \
            -f /gen-source/Dockerfile.gen \
            -t "${IMAGE}" .
            
          # push (OKD nội bộ có thể cần --tls-verify=false nếu dùng cert self-signed)
          buildah --storage-driver=vfs push \
            --tls-verify=${TLSVERIFY:-false} \
            "${IMAGE}" "docker://${IMAGE}"

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
