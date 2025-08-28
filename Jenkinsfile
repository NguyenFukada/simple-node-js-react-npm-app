pipeline {
  agent { label 'nodejs' } // dùng PodTemplate label 'nodejs'
  environment {
    NPM_CONFIG_PREFIX = '/tmp/.npm-global'
    PATH = "/tmp/.npm-global/bin:${env.PATH}"
  }
  stages {
    stage('Build') {
      steps {
        container('node') {
          sh 'set -x; node -v; npm -v'
          sh 'set -x; mkdir -p "$NPM_CONFIG_PREFIX"; ls -ld "$NPM_CONFIG_PREFIX"'

          sh 'set -x; echo "Ping npm registry:"; curl -I https://registry.npmjs.org/ --max-time 10 || true'

          timeout(time: 10, unit: 'MINUTES') {
            retry(1) {
              sh 'set -x; npm ci --no-audit --no-fund --prefer-offline --loglevel=verbose'
            }
          }

          sh 'npm run build || echo "No build script"'
        }
      }
    }
  }
}
