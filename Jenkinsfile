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
      agent { label 'docker-build' }
      steps {
        unstash 'build'
        container('kaniko') {
          sh """
    set -xe

    # 1) Lấy token của SA trong pod & tạo docker config tại chỗ
    mkdir -p /kaniko/.docker
    TOKEN=\$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
    # base64 'serviceaccount:<token>' (busybox/gnu base64 khác tham số -w, nên dùng cách tương thích)
    AUTH=\$(printf 'serviceaccount:%s' "\$TOKEN" | base64 | tr -d '\\n')

    cat > /kaniko/.docker/config.json <<'JSON'
    {
      "auths": {
        "image-registry.openshift-image-registry.svc:5000": {
          "auth": "REPLACE_AUTH"
        }
      }
    }
    JSON
    sed -i "s|REPLACE_AUTH|\$AUTH|g" /kaniko/.docker/config.json
    echo "==== /kaniko/.docker/config.json ===="
    cat /kaniko/.docker/config.json

    # 2) Dùng CA nội bộ cho internal registry (bạn đã mount svc-ca -> /kaniko/ssl/certs/service-ca.crt)
    test -s /kaniko/ssl/certs/service-ca.crt

    /kaniko/executor --force --context="${env.WORKSPACE}" --dockerfile="${env.WORKSPACE}/Dockerfile" \
                     --destination="${env.REGISTRY}/${env.NAMESPACE}/${env.IMAGE_NAME}:${env.IMAGE_TAG}" \
                     --registry-certificate="${env.REGISTRY}=/kaniko/ssl/certs/service-ca.crt" \
                     --verbosity=info
  """
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
