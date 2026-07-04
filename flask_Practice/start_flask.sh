#!/bin/bash
cd ~/flask_Practice

# Create venv if not exists
if [ ! -d venv ]; then
    python3 -m venv venv
fi

# Activate venv
source venv/bin/activate

# Upgrade pip and install dependencies
sudo apt update
sudo apt install python3-pip -y 
sudo pip install --upgrade pip
sudo pip install -r requirements.txt black pylint bandit pytest pytest-html

# Ensure .env exists
echo -e "MONGO_URI=mongodb+srv://studentregadmin:Welcome123@studentregsys.akzmpnb.mongodb.net/student?retryWrites=true&w=majority\nSECRET_KEY=abasde3434marere" > .env

# Run app
nohup python3 app.py --host=0.0.0.0 --port=5000 > flask.log 2>&1 < /dev/null &
