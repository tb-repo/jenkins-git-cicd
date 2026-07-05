# GitHub Actions CI/CD Pipeline & Dual Environment Deployment Guide 🚀

This document details the multi-environment CI/CD pipeline automated using **GitHub Actions**. It guides you through the repository configuration, environment secrets management, pipeline workflow logic defined in [.github/workflows/cicd.yml](.github/workflows/cicd.yml), and a visual step-by-step trace of staging and production deployments.

---

## Pipeline Architecture & Branch Routing

The GitHub Actions workflow manages testing and dual-environment deployments onto the **AWS EC2** instance:

```mermaid
graph TD
    A[Code Commit / Pull Request] --> B{Branch or Tag?}
    B -->|Push / PR to main/staging| C[1. Run pytest Suite]
    B -->|Push tag v*| C
    
    C --> D{Pipeline Trigger Type?}
    D -->|Push to staging branch| E[2. Deploy Staging App]
    D -->|Push Tag v*| F[2. Deploy Production App]
    D -->|Push to main / PR| G[Deploy Steps Skipped - Test Only]
    
    E --> H[AWS EC2 Port 5100 - /stage]
    F --> I[AWS EC2 Port 5000 - /prod]
```

---

## Step 1: Environment & Secret Management in GitHub

To keep Staging and Production settings secure and isolated, we leverage GitHub **Environments**:

1. Go to repository **Settings** -> **Environments** and configure two environments named `staging` and `production`.
   ![GitHub Environments Config 1](images/Git_CICD_4.png)
2. Add the following **Environment Secrets** specifically to each environment:
   * `EC2_IP`: The public IP of the target AWS EC2 instance.
   * `EC2_USER`: `ubuntu` (default SSH username).
   * `EC2_SSH_KEY`: The contents of the SSH private key (`.pem`) used to authenticate with EC2.
   * `MONGO_URI`: The MongoDB Atlas connection string.
   ![GitHub Environment Creation](images/Git_CICD_5.png)
   ![GitHub Secrets Config 1](images/Git_CICD_6.png)
3. Add the following **Repository Secrets** in the repository settings:
   * `FLASK_SECRET_KEY`: A secure random cryptographic key for session management.
   ![GitHub Secrets Config 2](images/Git_CICD_7.png)
4. Make sure the EC2 port 5000 and 5100 are allowed to connect from the GitHub Actions runner. For that go to the EC2 instance -> Security Groups -> Inbound Rules and add the following rules:
   * **SSH (Port 22)** for deployment access.
   * **Custom TCP (Port 5000)** for Flask web server access.
   * **Custom TCP (Port 5100)** for Flask web server access.
   ![Security Group Inbound Rules](images/Git_CICD_staging_branch_deployment-2.png)
   
---

## Step 2: Pipeline Execution Walkthroughs

The pipeline acts differently based on git triggers:

### Pathway A: Push to `staging` Branch (Staging Deployment to Port 5100)
When code is pushed directly to the `staging` branch, GitHub Actions executes tests and deploys the updates to the staging server on **Port 5100**.

1. **Commit & Push:** Push commits to the `staging` branch.
   ![Pushing to staging](images/Git_CICD_staging_branch_deployment-1.png)
2. **Workflow Triggered:** The workflow checkouts the code and starts running the steps.
   ![Workflow running list](images/Git_CICD_main_branch_deployment-2.png)
   ![Workflow running status](images/Git_CICD_staging_branch_deployment-4.png)  
   ![Workflow running Steps](images/Git_CICD_main_branch_deployment-3.png)
3. **Running Pytest:** dependencies are configured, and Python unit tests are executed.
   ![Pytest Execution logs](images/Git_CICD_main_branch_deployment-4.png)
   ![Pytest execution success](images/Git_CICD_main_branch_deployment-5.png)
4. **SCP Transfer:** The staging deployment job downloads secrets and copies Flask application files using secure SCP.
5. **EC2 Activation:** The runner connects via SSH, installs virtual environment dependencies, creates the staging `.env` file, and executes the server on Port `5100` via `nohup`.
6. **Execution Complete:** Both `test` and `deploy-staging` jobs finish successfully.
   ![SCP Transfer logs](images/Git_CICD_staging_branch_deployment-5.png)
   ![SSH Remote commands](images/Git_CICD_staging_branch_deployment-6.png)
7. **Verification Logs:** Logs confirm the background Flask server is running on the EC2 server.   
8. **Browser Verification:** Staging application is fully responsive at `http://<EC2-IP>:5100`.
   ![Deployment validation logs](images/Git_CICD_staging_branch_deployment-7.png)
   ![Pip dependencies install on EC2](images/Git_CICD_staging_branch_deployment-8.png)
   ![Staging deploy complete checkmarks](images/Git_CICD_staging_branch_deployment-9.png)
   ![Staging Page browser view 1](images/Git_CICD_staging_branch_deployment-10.png)
   ![Staging Page browser view 2](images/Git_CICD_staging_branch_deployment-11.png)

---

### Pathway B: Push / Pull Request to `main` Branch (Test Only, Deploys Skipped)
When code is pushed to the `main` branch or a PR is raised against it, the pipeline acts as a Gatekeeper: it installs dependencies and runs tests, but skips all deployment jobs.

1. **Main Branch Run:** GitHub detects a push to `main` and launches the pipeline.
   ![Main Branch execution entry](images/Git_CICD_main_branch_deployment.png)
2. **Testing Pipeline Stage:** The pipeline initializes and tests.
   ![Main Branch Run test job initialization](images/Git_CICD_main_branch_deployment-2.png)
   ![Main Branch Run python setup](images/Git_CICD_main_branch_deployment-3.png)
3. **Successful Tests:** Pytest passes successfully.
   ![Main Branch Pytest execution logs](images/Git_CICD_main_branch_deployment-4.png)
   ![Main Branch tes t job finished](images/Git_CICD_main_branch_deployment-5.png)
4. **Skipped Deploys:** The `deploy-staging` and `deploy-production` jobs are bypassed, remaining unexecuted.
   ![Staging and Production deploy stages skipped](images/Git_CICD_main_branch_deployment-skipped-6.png)

---

### Pathway C: Git Tag Push `v*` (Production Deployment to Port 5000)
To run a deployment to the production environment on **Port 5000**, the developer creates a tag starting with `v` (e.g. `v1.0.0`) and pushes it.

1. **Pushing Release Tag:** Run the following commands locally:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
   ![Pushing v1.0.0 tag to GitHub](images/gitcicd_main_branch_tag_deployment-1.png)
2. **Workflow Triggered:** GitHub Actions identifies the tag and launches the workflow.
   ![Workflow running list](images/Git_CICD_main_branch_deployment-2.png)
3. **Execution of Tests:** Running tests under the tag pipeline context.
   ![Pytest Execution logs](images/Git_CICD_main_branch_deployment-4.png)
   ![Pytest execution success](images/Git_CICD_main_branch_deployment-5.png)
4. **Deploying Production:** The `deploy-production` job triggers and completes automatically.
5. **Production SCP Transfer:** Files are copied to the production location `~/git_cicd/prod_temp` on EC2. Code is deployed to `~/git_cicd/prod`, dependencies installed, `.env` file generated, and Flask launched on Port `5000`.
   ![Copying files to EC2 production directory](images/gitcicd_main_branch_tag_deployment-3.png)
6. **Pipeline Success:** Workflow logs display clean green checkmarks.
   ![Production pipeline completion](images/gitcicd_main_branch_tag_deployment-2.png)
7. **Browser Verification:** Production application is running at `http://<EC2-IP>:5000`.
   ![Production live verification page1](images/gitcicd_main_branch_tag_deployment-5.png)
   ![Production live verification page2](images/gitcicd_main_branch_tag_deployment-6.png)
   ![Production live verification page3](images/gitcicd_main_branch_tag_deployment-7.png)
   ![MongoDB Data verification](images/gitcicd_main_branch_tag_deployment-8.png)
---

> [!TIP]
> ### 🔗 Useful Links
> * **[GitHub Actions Workflow YAML](.github/workflows/cicd.yml)**
> * **[Main README.md Hub](README.md)**
> * **[Jenkins CI/CD Pipeline Guide](jenkinscicd_README.md)**