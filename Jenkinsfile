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

        stage('Branch Validation') {
            steps {
                script {
                    if (!(env.BRANCH_NAME.startsWith("feature/") || env.BRANCH_NAME == "main")) {
                        error("❌ Only feature/* or main branches are allowed.")
                    }
                }
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
                withSonarQubeEnv('SonarQube') {
                    sh '''
                        sonar-scanner \
                        -Dsonar.projectKey=ocity-cicd \
                        -Dsonar.sources=. \
                        -Dsonar.host.url=$SONAR_HOST_URL
                    '''
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

        stage('Vlocity Validate (Feature Only)') {
            when {
                expression { env.BRANCH_NAME.startsWith("feature/") }
            }
            steps {
                sh 'vlocity packDeploy -job deployJob.yaml -dryRun'
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

    post {
        success {
            echo "✅ Pipeline completed successfully."
        }
        failure {
            echo "❌ Pipeline failed."
        }
    }
}