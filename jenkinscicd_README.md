## Jenkins CI/CD Pipeline

This project includes a declarative `Jenkinsfile` located in the application root to automate build, testing, and deployment.

### Pipeline Stages
1. **Build:** Sets up a Python virtual environment (`venv`) and installs the dependencies specified in `requirements.txt`.
2. **Test:** Runs unit tests using the `pytest` framework and exports test reports to XML format (`test-reports/results.xml`).
3. **Deploy:** Executes the shell script `start_flask.sh` to update environment variables and run the Flask application in the background (using `nohup`) on the staging server.

### Pipeline Configuration & Features

#### 1. Automatic Triggers
The pipeline contains a `triggers` block configured for GitHub webhooks:
```groovy
triggers {
    githubPush()
}
```
Whenever a push is made to the repository on the `main` branch, GitHub sends a webhook payload to Jenkins, which automatically triggers a new pipeline run.

#### 2. Email Notifications
On pipeline completion (either `success` or `failure`), the pipeline sends an email alert to the configured recipient using the `mail` step:
* **Success:** Notifies the team that the build, testing, and deployment succeeded.
* **Failure:** Sends an alert containing details of the failure along with a direct link to the Jenkins build log.

### Prerequisites & Setup in Jenkins
To successfully run this pipeline, ensure your Jenkins server has the following configurations:

1. **System Tools & Plugins:**
   * Python 3 and `venv` module installed on the Jenkins agent machine.
   * **GitHub Integration Plugin** installed on Jenkins.
   * **JUnit Plugin** installed (to parse test reports).

2. **Mail (SMTP) Configuration:**
   * Configure your SMTP server details under **Manage Jenkins** -> **System** -> **E-mail Notification** (e.g., configuring SMTP server, port, and credentials for sending emails).
   * Customize the `EMAIL_TO` build parameter when running the pipeline to change the recipient address.

3. **Webhook Setup:**
   * In your GitHub Repository settings, add a webhook pointing to `http://<your-jenkins-url>/github-webhook/` with the Content type set to `application/json` and selecting the `Just the push event` option.

---

## License

MIT License

---
