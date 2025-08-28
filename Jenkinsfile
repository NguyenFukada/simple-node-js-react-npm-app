pipeline {
  agent {
    kubernetes {
      yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
    - name: node
      image: registry.access.redhat.com/ubi9/nodejs-20   # <-- thay vì docker.io/library/node
      command: ["sleep","infinity"]
      tty: true
      env:
        - name: NPM_CONFIG_PREFIX
          value: /tmp/.npm-global
      volumeMounts:
        - name: npm-tmp
          mountPath: /tmp
  volumes:
    - name: npm-tmp
      emptyDir: {}
"""
      defaultContainer 'node'
    }
  }
  stages {
    stage('Build') {
      steps {
        container('node') {
          sh '''
            export PATH="/tmp/.npm-global/bin:$PATH"
            mkdir -p /tmp/.npm-global
            node -v && npm -v
            npm ci
            npm run build || echo "No build script"
          '''
        }
      }
    }
  }
}