pipeline {
    agent any

    tools {
        jdk 'jdk17' // 与你全局工具配置一致
        maven 'maven3.8.8'
    }

    environment {
        // 远程服务器信息（建议移至参数或凭据）
        REMOTE_USER = 'root'
        REMOTE_HOST = '192.168.9.228' // 远程服务器 IP
        REMOTE_PATH = '/opt/app/ruoyi-admin'
        JAR_PATH = 'ruoyi-admin-wms/target/ruoyi-admin.jar' //你的 Jar 包所在位置
        // 在 Jenkins 中创建的 SSH 凭据 ID
        SSH_CRED_ID = 'jenkins_ssh'
        SCRIPT_COMMAND = 'bash ry.sh restart'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean package -DskipTests=true'
            }
        }

        stage('Deploy to Remote Server') {
            steps {
                sshagent(credentials: [SSH_CRED_ID]) {
                    // 1. 确保远程目录存在
                    sh """
                        ssh -o StrictHostKeyChecking=no ${REMOTE_USER}@${REMOTE_HOST} \
                        "mkdir -p ${REMOTE_PATH}"
                    """

                    // 2. 上传 JAR 包（假设在 target 目录下）
                    sh """
                        scp -o StrictHostKeyChecking=no \
                        ${JAR_PATH} \
                        ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/
                    """

                    // 3. 远程执行重启脚本
                    sh """
                        ssh -o StrictHostKeyChecking=no ${REMOTE_USER}@${REMOTE_HOST} << 'EOF'
                            cd ${REMOTE_PATH}
                            ${SCRIPT_COMMAND}
                            echo "Deployment complete."
                        EOF
                    """
                }
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'target/*.jar', allowEmptyArchive: true
        }
    }
}
