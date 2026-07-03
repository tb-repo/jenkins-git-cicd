# Student Registration System with Jenkins CI/CD

A simple **Flask** web application to manage student records with **MongoDB** as the backend database. Users can **add, view, update, and delete** student details.

The repository includes a Jenkins pipeline configuration to automatically build, test, and deploy the application to an **AWS EC2** staging server on every push to the `main` branch.

---

## Project Structure

```
project/
│
├── flask_Practice/
│   ├── templates/          # HTML templates (Bootstrap 5)
│   ├── app.py              # Main Flask application
│   ├── test_app.py         # Pytest unit tests
│   ├── requirements.txt    # Python dependencies
│   ├── start_flask.sh      # Staging deployment startup script
│   ├── Jenkinsfile         # Jenkins declarative pipeline
│   └── .env                # Local environment configuration
│
└── README.md               # Pipeline and documentation (this file)
```

---

## Local Setup Instructions

### 1. Clone the repository
```bash
git clone <your-repo-url>
cd git-jenkins-cicd/flask_Practice
```

### 2. Create and activate a virtual environment
```bash
python -m venv venv
# Activate venv
# Windows:
venv\Scripts\activate
# Linux / Mac:
source venv/bin/activate
```

### 3. Install dependencies
```bash
pip install -r requirements.txt
```

### 4. Configure environment variables
Create a `.env` file in the `flask_Practice/` directory:
```env
MONGO_URI=mongodb+srv://<username>:<password>@<cluster-address>/student?retryWrites=true&w=majority
SECRET_KEY=any_random_secret_string
```

### 5. Run the application
```bash
python app.py
```
Open your browser at [http://localhost:5000](http://localhost:5000)

---

## Jenkins CI/CD Pipeline (AWS EC2 Deployment)

The `Jenkinsfile` ([flask_Practice/Jenkinsfile](file:///d:/HeroVired/Assignments/git-jenkins-cicd/flask_Practice/Jenkinsfile)) automates the entire delivery process.

### Pipeline Stages
1. **Git Checkout:** Checks out the codebase from the specified GitHub repository on the `main` branch.
2. **Build:** Sets up a local Python virtual environment (`venv`) and installs the project's pip dependencies.
3. **Test:** Runs unit tests using the `pytest` framework and records the results using the Jenkins JUnit plugin.
4. **Deploy (AWS EC2):** 
   - Utilizes the `sshagent` block to access the remote EC2 instance via SSH.
   - Creates the deployment folder `~/flask_Practice` on EC2 if it does not exist.
   - Securely copies (`scp`) the project files to the target EC2 machine.
   - SSHs into the EC2 instance and triggers [start_flask.sh](file:///d:/HeroVired/Assignments/git-jenkins-cicd/flask_Practice/start_flask.sh) which installs Python dependencies and starts the Flask server in the background using `nohup`.

---

## AWS EC2 & Jenkins Prerequisites

To set up this pipeline successfully, you must complete the following configuration:

### 1. Jenkins SSH Credentials Setup
* Save your EC2 Private Key (`.pem` file) in Jenkins.
* Go to **Manage Jenkins** -> **Credentials** -> **System** -> **Global credentials**.
* Add a credential of type **"SSH Username with private key"**.
* Set **ID** as `HV-EC2-Key` (or whatever ID you prefer, updating the `EC2_SSH_CREDENTIALS_ID` parameter in the pipeline).
* Set **Username** as `ubuntu` (default EC2 username).
* Enter the private key directly.

### 2. Jenkins Plugins
* Install the **SSH Agent Plugin** in Jenkins.
* Install the **GitHub Integration Plugin** and **JUnit Plugin**.

### 3. AWS Security Group Config
* Navigate to your EC2 instance in the AWS Console.
* Go to the attached Security Group and add an **Inbound Rule**:
  * **Type:** Custom TCP
  * **Port Range:** `5000`
  * **Source:** `Anywhere-IPv4` (`0.0.0.0/0`) or limit to your IP for security.

### 4. Git Webhook
* Go to your repository settings on GitHub -> **Webhooks** -> **Add Webhook**.
* Set **Payload URL** to `http://<your-jenkins-url>/github-webhook/`.
* Set **Content type** to `application/json`.
* Trigger on `Just the push event`.

### 5. Email Notification (SMTP) Config
* In Jenkins, navigate to **Manage Jenkins** -> **System** -> **E-mail Notification**.
* Enter your SMTP server details, authentication credentials, and default sender address.
* You can change the recipient email at build-time using the `EMAIL_TO` parameter.

---

## License

MIT License
