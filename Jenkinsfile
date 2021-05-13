pipeline {
    environment {
        AWS_ACCESS_KEYS = credentials('aws-keys')
    }
    
    agent any
    
    stages {
        stage('init') {
            steps {
                sh 'terraform init'
            }
        }
        stage('plan') {
            steps {
                sh 'terraform plan'
            }
        }

        stage('Deploy') {
            steps {
                sh 'terraform apply --auto-approve'
            }
        }
    }
}
