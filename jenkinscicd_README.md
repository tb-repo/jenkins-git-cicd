# Jenkins CI/CD Pipeline & AWS EC2 Deployment Guide

This document provides a comprehensive step-by-step guide for the automated CI/CD pipeline powered by **Jenkins**. It details the infrastructure setup on **AWS EC2**, configuration of credentials and plugins in Jenkins, webhook integration with **GitHub**, and the visual walkthrough of successful and failed pipeline executions.

---

## Pipeline Architecture & Flow

The declarative [Jenkinsfile](Jenkinsfile) is located at the root of the project. Whenever a developer pushes changes to the `main` branch, a GitHub Webhook triggers the Jenkins automation agent to run the following stages:

```mermaid
graph LR
    subgraph GitHub
        Push[Git Push to main]
    end
    subgraph Jenkins Server
        Trigger[GitHub Webhook] --> Checkout[1. Git Checkout]
        Checkout --> Build[2. Build & Setup venv]
        Build --> Test[3. Execute pytest]
        Test --> Deploy[4. SSH Agent EC2 Deploy]
    end
    subgraph AWS EC2
        Deploy --> RunApp[Run Flask on Port 5000]
    end
    subgraph Alerts
        Deploy --> SuccessEmail[Success Email Alert]
        Test -.->|On Fail| FailureEmail[Failure Email Alert]
    end
```

---

## Step 1: AWS EC2 Instance Provisioning

To host the staging deployment, we launch an Ubuntu EC2 virtual machine on AWS:

1. **Instance Launch & OS Selection:** Choose **Ubuntu Server** as the base AMI.
   ![AWS Instance OS Selection](images/EC2-create-1.png)
2. **Instance Sizing & Keys:** Select a `t2.micro` instance type and choose or create an RSA key pair (`.pem` file) for SSH login access.
   ![AWS Instance Sizing](images/EC2-create-2.png)
3. **Network Configuration:** Configure default subnet rules and enable public IP allocation.
   ![AWS Network configuration](images/EC2-create-3.png)
4. **Confirm Settings:** Review details and launch the instance.
   ![Review EC2 Launch Settings](images/EC2-create-4.png)
5. **Monitor EC2 State:** Verify the instance status goes from "Pending" to "Running" and note down its Public IPv4 address.
   ![EC2 Running Status](images/EC2-create-5.png)
6. **Inbound Firewall Rules:** Go to the EC2 security group rules and add **Inbound Rules** to allow:
   * **SSH (Port 22)** for deployment access.
   * **Custom TCP (Port 5000)** for Flask web server access from anywhere (`0.0.0.0/0`).
   ![Security Group Inbound Rules](images/EC2-create-6.png)

---

## Step 2: Jenkins Configuration & Credentials Setup

Before running the pipeline, Jenkins requires system dependencies, credentials, and notification configs.

### 1. Credentials Management
Navigate to **Manage Jenkins** -> **Credentials** -> **System** -> **Global credentials**. We add three essential credentials:
* **EC2 SSH Private Key (`HV-B16A-TB-EC2-Keypair`):** Add key as "SSH Username with private key" (`ubuntu` username + paste your `.pem` key content).
![Adding EC2 SSH Keypair](images/Jenkins-7.png)
* **EC2 Secrets:** Store `EC2-IP` and `EC2-USER` as "Secret text" credentials.
![Adding EC2 IP](images/Jenkins-4.png)
![Adding EC2 Username](images/Jenkins-5.png)
* **GitHub Checkout Key (`HV-B16A-TB-Git`):** Add GitHub private access tokens or SSH credentials for pulling code.
![Adding Git Creds](images/Jenkins-6.png)
* **MONGO_URI & Secret Key:** Store the values in secret text credentials.
![Adding MONGO_URI](images/Jenkins-7-1.png)
![Adding Secret Key](images/Jenkins-7-2.png)

### 2. Required Plugins Setup
Ensure the following plugins are installed under **Manage Jenkins** -> **Plugins**:
* **SSH Agent Plugin** (crucial for staging copy tasks).
* **GitHub Integration Plugin** (for webhook trigger management).
* **JUnit Plugin** (for parsing and visualizing Pytest `.xml` test results).

### 3. SMTP E-mail Server Integration
To enable automated status emails, configure your SMTP server under **Manage Jenkins** -> **System** -> **E-mail Notification**:
* **SMTP Server:** `smtp.gmail.com`
* **Port:** `587` (TLS enabled)
* **SMTP Authentication:** Configure and use Gmail App Passwords.
* **Default Sender Address:** e.g., your-email@gmail.com
![SMTP Email Setup](images/Jenkins-10.png)

---

## Step 3: Jenkins Pipeline Job Creation

1. In Jenkins Home, click **New Item**, enter a name (e.g. `HV-B16A-TB-CICD-Assignment`), and select **Pipeline**.
2. **General Setup:** Provide a description and configure general rules.
   ![Create Pipeline Item](images/Jenkins-1.png)
3. **Git Webhook Trigger:** Check **"GitHub hook trigger for GITScm polling"**.
   ![SCM Polling](images/Jenkins-2.png)
4. **Pipeline Configuration:**
   * Select **Pipeline script** or **Pipeline script from SCM**
   * If **Pipeline script from SCM** selected, then choose **Git** and supply repository URL `https://github.com/tb-repo/jenkins-git-cicd.git` and Git credentials.
   * Specify branch parameter as `*/main`.
   * Set **Script Path** to `Jenkinsfile`.
   ![Pipeline script Configuration](images/Jenkins-3.png)
5. Once configurations are done. Save it. Now, whenever you push changes to the Git repository, Jenkins will automatically trigger the pipeline and execute the stages.

### Scenario A: Successful Pipeline Execution (Happy Path)
Every stage runs perfectly. Tests pass and the code is successfully copied to EC2 and deployed:

1. **Stage View:** Visual grid showing Checkout, Build, Test, and Deploy steps as green.
   ![Stage View Green](images/Jenkins-Pipeline-Success.png)
2. **Console Output:** The console output shows the logs of each stage and the final result of the pipeline ([Jenkins_successful_exec_log.txt](Jenkins_successful_exec_log.txt))
2. **Staging App verification:** The staging application launches on port 5000 and is fully accessible.
   ![Staging Deployment Success](images/StdRegSys_working1.png)
3. **Email Notification:** Recipient gets a confirmation email with direct link to build details.
   ![Success Email Notification](images/Jenkins-SuccessCase-mail.png)

### Scenario B: Failed Pipeline Execution (Failing Test Case)
If a unit test fails, the pipeline aborts early to prevent deploying broken code:

1. **Stage View:** The **Test** stage turns red (Failed), and the **Deploy** stage is skipped (grey).
   ![Stage View Red](images/Jenkins-FailureCase.png)
2. **Staging Safety:** The EC2 server remains unaffected (the older successful deployment continues running).
3. **Email Notification:** Jenkins sends an ALERT email indicating failure and links to console output for debugging.
   ![Failure Email Notification](images/Jenkins-FailureCase-mail.png)

---

> [!TIP]
> ### 🔗 Useful Links
> * **[Root Jenkinsfile](Jenkinsfile)**
> * **[Main README.md Hub](README.md)**
> * **[GitHub Actions CI/CD Guide](gitcicd_README.md)**
