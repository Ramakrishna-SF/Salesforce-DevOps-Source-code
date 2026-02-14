pipeline {
    agent any

    environment {
        SF_AUTH_URL = credentials('sf-auth-url')
    }

    stages {

        stage('Branch Validation') {
            steps {
                script {
                    if (!env.BRANCH_NAME.startsWith("feature/") && env.BRANCH_NAME != "main") {
                        error("❌ Only feature/* or main branches are allowed!")
                    }
                }
            }
        }

        stage('Salesforce Auth') {
            steps {
                sh '''
                    echo "$SF_AUTH_URL" > auth.txt
                    sf org login sfdx-url --sfdx-url-file auth.txt --alias ci-org
                '''
            }
        }

        stage('Vlocity Validate (Feature Branch Only)') {
            when {
                expression { env.BRANCH_NAME.startsWith("feature/") }
            }
            steps {
                sh 'vlocity packDeploy -job deployJob.yaml -dryRun'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                sh 'sonar-scanner'
            }
        }

        stage('Vlocity Deploy (Main Only)') {
            when {
                branch 'main'
            }
            steps {
                sh 'vlocity packDeploy -job deployJob.yaml'
            }
        }
    }
}
