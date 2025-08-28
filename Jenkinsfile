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
          sh 'npm install'
        }
      }
    }
  }
}
