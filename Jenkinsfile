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
                        # Robust SonarScanner caching with dynamic folder detection
                        SONAR_CACHE="${WORKSPACE}/tools/sonar-scanner"
                        
                        if [ ! -f "$SONAR_CACHE/bin/sonar-scanner" ]; then
                            echo "📥 Downloading SonarScanner..."
                            mkdir -p "$(dirname "$SONAR_CACHE")"
                            
                            # Download to temp and find actual unzipped folder
                            cd /tmp
                            wget -q -O sonar.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip
                            unzip -o sonar.zip
                            
                            # Find the actual sonar-scanner folder (handles any version folder name)
                            SONAR_FOLDER=$(find . -type d -name "sonar-scanner*" -maxdepth 1 | head -1)
                            if [ -n "$SONAR_FOLDER" ]; then
                                mv "$SONAR_FOLDER" "$SONAR_CACHE"
                                chmod +x "$SONAR_CACHE/bin/sonar-scanner"
                                echo "✅ SonarScanner installed to $SONAR_CACHE"
                            else
                                echo "❌ Failed to find sonar-scanner folder after unzip"
                                exit 1
                            fi
                        else
                            echo "✅ Using cached SonarScanner at $SONAR_CACHE"
                        fi
                        
                        export PATH="$SONAR_CACHE/bin:$PATH"
                        sonar-scanner \\
                            -Dsonar.projectKey=ocity-cicd \\
                            -Dsonar.sources=. \\
                            -Dsonar.host.url=http://13.51.249.69:9000/
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
