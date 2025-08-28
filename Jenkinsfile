pipeline {
  agent { label 'nodejs' }  // dùng Pod Template đã tạo ở trên
  environment {
    NPM_CONFIG_PREFIX = '/tmp/.npm-global'
    PATH = "/tmp/.npm-global/bin:${env.PATH}"
  }
  stages {
    stage('Build') {
      steps {
        container('node') {
          sh 'set -x; whoami; pwd; which sh'
          sh 'mkdir -p "$NPM_CONFIG_PREFIX"'
          sh 'node -v && npm -v'
          sh 'npm ci --no-audit --no-fund --prefer-offline'
          sh 'npm run build || echo "No build script"'
        }
      }
    }
  }
}