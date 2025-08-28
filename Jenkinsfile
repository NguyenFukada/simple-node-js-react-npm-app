pipeline {
  agent { label 'nodejs' }   // dùng Pod Template có label nodejs
  stages {
    stage('Build') {
      steps {
        container('node') {
          sh '''
            export PATH="/tmp/.npm-global/bin:$PATH"
            mkdir -p "$NPM_CONFIG_PREFIX"
            node -v && npm -v
            npm ci
            npm run build || echo "No build script"
          '''
        }
      }
    }
  }
}
