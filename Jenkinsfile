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
                    script {
                        def scannerHome = "${env.WORKSPACE}/tools/sonar-scanner"
                        
                        sh """
                            # Cache SonarScanner in workspace (persists across builds)
                            if [ ! -f "${scannerHome}/bin/sonar-scanner" ]; then
                                echo "📥 Downloading SonarScanner..."
                                mkdir -p ${scannerHome}/..
                                cd /tmp
                                wget -q -O sonar.zip \\
                                    https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip
                                unzip -o sonar.zip -d ${scannerHome}/..
                                chmod +x ${scannerHome}/bin/sonar-scanner
                                echo "✅ SonarScanner cached in workspace"
                            else
                                echo "✅ Using cached SonarScanner"
                            fi
                            
                            export PATH="\${PATH}:${scannerHome}/bin"
                            sonar-scanner \\
                                -Dsonar.projectKey=ocity-cicd \\
                                -Dsonar.sources=. \\
                                -Dsonar.host.url=http://13.51.249.69:9000/
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
