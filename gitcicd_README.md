# GitHub Actions CI/CD Staging & Production Pipeline
This repository includes a fully automated CI/CD pipeline built using **GitHub Actions** to test and deploy the Python Flask application.
---
## Workflow Workflow Logic
```mermaid
graph TD
    A[Code Push / Tag Created] --> B[Job 1: Test & Lint]
    B -->|Passed| C{Branch / Tag Target?}
    C -->|Push to staging branch| D[Job 2: Deploy to Staging EC2]
    C -->|Push tag matching v*| E[Job 3: Deploy to Production EC2]
    C -->|Pull Request / main push| F[Run Verification Tests Only]
Setup & Secrets Configuration
To run this pipeline successfully, the following repository secrets must be configured under Settings -> Secrets and variables -> Actions:

STAGING_EC2_IP: Staging Server Public IP
STAGING_EC2_USER: Staging SSH User (e.g., ubuntu)
STAGING_EC2_SSH_KEY: Private SSH Key used to access the staging EC2 instance
PROD_EC2_IP: Production Server Public IP
PROD_EC2_USER: Production SSH User
PROD_EC2_SSH_KEY: Private SSH Key used to access the production EC2 instance
MONGO_URI: MongoDB Atlas connection string
FLASK_SECRET_KEY: Flask Session Secret Key
Triggering the Pipelines
1. Verification Test
The pipeline runs unit tests on every push or pull request targeting main or staging.

2. Deploy to Staging
When you push commits to the staging branch, the pipeline builds, tests, and deploys directly to the Staging EC2 environment:

bash
git checkout staging
git add .
git commit -m "Deploy update to staging"
git push origin staging
3. Deploy to Production (Release Tag)
To deploy to the Production EC2 environment, tag a commit with a version tag matching v* and push it:

bash
git tag v1.0.0
git push origin v1.0.0
---
### Step 5: Execute & Test the Workflow
1. Commit the workflow configuration and push it to GitHub:
   ```bash
   git add .github/workflows/ci-cd.yml gitcicd_README.md
   git commit -m "Add GitHub Actions workflow and documentation"
   git push origin main
Navigate to the Actions tab on your GitHub repository. You will see your pipeline running the test suite automatically!