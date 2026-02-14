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
                script {
                    def scannerHome = tool 'SonarScanner'
                    withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
                        sh """
                        ${scannerHome}/bin/sonar-scanner \
                        -Dsonar.projectKey=ocity-cicd \
                        -Dsonar.sources=. \
                        -Dsonar.projectName=ocity-cicd \
                        -Dsonar.host.url=http://13.50.110.69:9000 \
                        -Dsonar.login=$SONAR_TOKEN
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

        stage('Vlocity Validate (Feature Only)') {
            when {
                expression { env.BRANCH_NAME.startsWith("feature/") }
            }
            steps {
                sh '''
                    vlocity packDeploy -job deployJob.yaml -dryRun
                '''
            }
        }

        stage('Vlocity Deploy (Main Only)') {
            when {
                branch 'main'
            }
            steps {
                sh '''
                    vlocity packDeploy -job deployJob.yaml
                '''
            }
        }
    }

    post {
        always {
            script {
                sh '''
                    rm -f auth.txt || true
                '''
            }
        }
        success {
            echo "✅ Pipeline completed successfully."
        }
        failure {
            echo "❌ Pipeline failed."
        }
    }
}