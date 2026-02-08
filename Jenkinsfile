stage('Salesforce Auth Test') {
  steps {
    withCredentials([string(credentialsId: 'sf-auth-url', variable: 'SF_AUTH_URL')]) {
      sh '''
        echo "$SF_AUTH_URL" > authfile
        sf org login sfdx-url --sfdx-url-file authfile --alias devhub
        sf org display --target-org devhub
      '''
    }
  }
}
