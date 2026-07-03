# Student Registration System

A simple **Flask** web application to manage student records with **MongoDB** as the backend database. Users can **add, view, update, and delete** student details.

---

## Features

* List all students on the home page
* Add a new student
* Update existing student details
* Delete a student with confirmation
* Simple and responsive UI using Bootstrap

---

## Tech Stack

* **Backend:** Python, Flask
* **Database:** MongoDB (via Flask-PyMongo)
* **Frontend:** HTML, Jinja2 templates, Bootstrap 5
* **Environment Variables:** Managed via `.env` file

---

## Setup Instructions

### 1. Clone the repository

```bash
git clone <your-repo-url>
cd <repo-folder>
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

**`requirements.txt` example:**

```
Flask
Flask-PyMongo
python-dotenv
bson
```

### 4. Configure environment variables

Create a `.env` file in the project root:

```
MONGO_URI=<your-mongodb-connection-string>
SECRET_KEY=<your-secret-key>
```

### 5. Run the application

```bash
python app.py
```

Open your browser at: [http://localhost:8000](http://localhost:8000)

---

## Project Structure

```
project/
│
├── templates/
│   ├── base.html
│   ├── index.html
│   ├── add_student.html
│   ├── update_student.html
│
├── app.py
├── requirements.txt
└── .env
```

---

## Screenshots

**Home Page**
Lists all students with Edit/Delete buttons.
- <img width="1902" height="607" alt="image" src="https://github.com/user-attachments/assets/a58a6a6d-4978-4769-8074-232e4d31e69d" />


**Add Student**
Form to add a new student.
- <img width="1897" height="801" alt="image" src="https://github.com/user-attachments/assets/d65d25c3-ebb5-410a-adb1-e130ad7c5878" />



---


## Notes

* Make sure MongoDB is running and accessible via the URI in `.env`
* Delete action includes a confirmation page to prevent accidental deletion
* Uses `ObjectId` from `bson` to work with MongoDB document IDs

---

## Jenkins CI/CD Pipeline

This project includes a declarative `Jenkinsfile` located in the application root ([Jenkinsfile](file:///d:/HeroVired/Assignments/git-jenkins-cicd/flask_Practice/Jenkinsfile)) to automate build, testing, and deployment.

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
