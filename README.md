📌 Project Overview

This project demonstrates a Salesforce CI/CD DevOps pipeline designed to automate the build, code validation, and deployment workflow.

The objective is to simulate real-world Salesforce DevOps practices where code changes are automatically validated and processed through a CI/CD pipeline.

The pipeline integrates modern DevOps tools hosted on cloud infrastructure to improve deployment reliability and release efficiency.

🏗 DevOps Architecture
Developer
   │
   ▼
GitHub Repository
   │
   ▼
Jenkins CI/CD Pipeline
   │
   ├── Build Stage
   │
   ├── Static Code Analysis (SonarQube)
   │
   ▼
Deployment Workflow
⚙️ CI/CD Pipeline Workflow
1️⃣ Code Commit

Developers push Salesforce metadata changes to the GitHub repository.

2️⃣ Pipeline Trigger

The Jenkins pipeline automatically triggers when new code is pushed.

3️⃣ Build Stage

Jenkins pulls the repository and prepares the build process.

4️⃣ Code Quality Analysis

The pipeline runs static code analysis using SonarQube to detect:

Bugs

Code smells

Security vulnerabilities

5️⃣ Deployment Workflow

After validation, the code proceeds through the deployment workflow.

🛠 Technology Stack
Category	Tools
Version Control	Git, GitHub
CI/CD Pipeline	Jenkins
Code Quality	SonarQube
Cloud Infrastructure	AWS EC2
Development Tools	VS Code
Salesforce Development	Salesforce DX
☁ Infrastructure Setup

All DevOps services are hosted on AWS EC2 instances.

Servers Used
Server	Purpose
Jenkins Server	CI/CD Pipeline
SonarQube Server	Code Quality Analysis

LinkedIn Demo Video

Watch the working CI/CD pipeline here:

https://www.linkedin.com/posts/ramakrishna28_salesforce-vlocity-devops-activity-7434846039393824770-vDP8

💻 GitHub Repository

Repository

https://github.com/Ramakrishna-SF

👨‍💻 Author

Bharathala Ramakrishna

Salesforce DevOps Engineer
4+ Years Experience in Salesforce Deployments & Release Engineering

LinkedIn
https://www.linkedin.com/in/ramakrishna28/

GitHub
https://github.com/Ramakrishna-SF

🎯 Key Features

✔ Automated Salesforce CI/CD pipeline
✔ Static code analysis with SonarQube
✔ Cloud-based DevOps infrastructure on AWS
✔ CI/CD automation using Jenkins
✔ Demonstrates enterprise DevOps practices for Salesforce
