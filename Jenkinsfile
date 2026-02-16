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

        stage('Deploy Salesforce Metadata') {
            when { branch 'main' }
            steps {
                sh 'sf project deploy start --source-dir force-app'
            }
        }
        stage('Vlocity Deploy (Main Only)') {
            when { branch 'main' }
            steps {
                sh 'vlocity -sfdx.username ci-org -job deployJob.yaml packDeploy'
            }
        }
    }
