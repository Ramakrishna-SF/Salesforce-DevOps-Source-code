pipeline {
  agent any

  stages {

    stage('Branch Validation') {
      steps {
        script {
          def branch = env.BRANCH_NAME
          if (!branch.startsWith("feature/")) {
            error "❌ Branch '${branch}' is not allowed. Only feature/* branches are permitted."
          }
        }
      }
    }
