pipeline {
    agent any
    
    environment {
        SF_AUTH_URL = credentials('sf-auth-url')
    }

    options {
        skipDefaultCheckout(true)
        timestamps()
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Salesforce Auth') {
            steps {
                sh '''
                    echo "$SF_AUTH_URL" > auth.txt
                    sf org login sfdx-url --sfdx-url-file auth.txt --alias ci-org --set-default
                '''
            }
        }
        stage('SonarQube Analysis') {
            steps {
                script {
                    def scannerHome = tool 'SonarScanner'
                    withSonarQubeEnv('SonarQube') {
                        sh """
                        ${scannerHome}/bin/sonar-scanner \
                        -Dsonar.projectKey=ocity-cicd \
                        -Dsonar.sources=. \
                        -Dsonar.projectName=ocity-cicd
                        """
                    }
                }
            }
        }


        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Salesforce Validation'){
            steps {
                sh '''
                    if [-d "force-app"]; then
                        sf project deploy start --source-dir force-app --dry-run
                    else
                        echo"No salesforce components found"
                    fi
                    '''
            }
        }

        stage('Deploy Salesforce Metadata') {
            when { branch 'main' }
            steps {
                sh '''
                    if [ -d "force-app" ]; then
                        sf project deploy start --source-dir force-app
                    else
                        echo "✅ No Salesforce metadata to deploy - Vlocity only pipeline"
                    fi
                    '''
            }
        }
        stage('Vlocity Deploy (Main Only)') {
            when { branch 'main' }
            steps {
                sh 'vlocity -sfdx.username ci-org -job deployJob.yaml packDeploy'
            }
        }
    }
     post {
        success {
            script {
                if (env.BRANCH_NAME == 'main') {
                    slackSend(
                        channel: '#devops',
                        message: """
    🚀 *Deployment Successful*

    *Branch:* ${env.BRANCH_NAME}
    *Status:* SUCCESS ✅
    *PR:* ${env.CHANGE_ID}
    *View Pipeline:* ${env.BUILD_URL}    
    """
                    )
                }
            }
        }
        failure {
            script {
                if (env.BRANCH_NAME == 'main') {
                    slackSend(
                        channel: '#devops',
                        message: """
    🔴 *Deployment Failed*

    *Branch:* ${env.BRANCH_NAME}
    *Status:* FAILED ❌
    *PR:* ${env.CHANGE_ID}
    *View Pipeline:* ${env.BUILD_URL} 
    """
                    )
                }
            }
        }
    }
    


}
