pipeline {
  agent any

  environment {
    BRANCH_ALLOWED = "feature/"
  }

  stages {

    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Branch Validation') {
      steps {
        script {
          if (!env.BRANCH_NAME.startsWith(BRANCH_ALLOWED)) {
            error("❌ Only feature/* branches are allowed")
          }
        }
      }
    }

    stage('Salesforce Auth') {
      steps {
        withCredentials([string(credentialsId: 'sf-auth-url', variable: 'SF_AUTH_URL')]) {
          sh '''
            echo "$SF_AUTH_URL" > authfile
            sf org login sfdx-url --sfdx-url-file authfile --alias devhub
          '''
        }
      }
    }

    stage('Vlocity Validate (CI)') {
      steps {
        sh 'vlocity -job validateJob.yaml validate'
      }
    }

    stage('SonarQube Analysis') {
      steps {
        withSonarQubeEnv('sonarqube-server') {
          sh 'sonar-scanner'
        }
      }
    }

    stage('Vlocity Deploy (CD)') {
      steps {
        sh 'vlocity -job deployJob.yaml deploy'
      }
    }
  }
}
