pipeline {
  agent any

  stages {

    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Branch Validation') {
      steps {
        script {
          if (!env.BRANCH_NAME.startsWith('feature/')) {
            error("Only feature/* branches allowed")
          }
        }
      }
    }

    stage('Salesforce Validate - Vlocity') {
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

    stage('Salesforce Deploy - Vlocity') {
      steps {
        sh 'vlocity -job deployJob.yaml deploy'
      }
    }
  }
}
