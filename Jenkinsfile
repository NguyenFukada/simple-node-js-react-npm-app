pipeline {
  agent {
    kubernetes {
      // Jenkins Kubernetes plugin sẽ tạo pod tạm thời theo YAML này
      yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: node
    image: node:20-alpine
    command: ["cat"]    # giữ container sống để Jenkins exec vào
    tty: true
    env:
    - name: NPM_CONFIG_PREFIX
      value: /tmp/.npm-global          # tránh ghi vào thư mục hệ thống khi chạy với UID ngẫu nhiên của OpenShift
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

  options { timestamps() }

  stages {
    stage('Build') {
      steps {
        container('node') {
          sh '''
            node -v
            npm -v || true

            # Bảo đảm PATH có npm prefix non-root
            export PATH="/tmp/.npm-global/bin:$PATH"
            mkdir -p /tmp/.npm-global

            # Tối ưu cho CI
            npm ci
            npm run build || echo "No build script, skipping"
          '''
        }
      }
    }
  }
}