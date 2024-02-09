----------------------Postgres--------------------------
1. Install sensu agent on Postgres server
# Add the Sensu repository
curl -s https://packagecloud.io/install/repositories/sensu/stable/script.deb.sh | sudo bash
# Install the sensu-go-agent package
sudo apt-get install sensu-go-agent

2. Configure the agent and start it as service
# Copy the config template from the docs
sudo curl -L https://docs.sensu.io/sensu-go/latest/files/agent.yml -o /etc/sensu/agent.yml
# open in an editor
vi /etc/sensu/agent.yml
# Remove hash (#) and modify the below lines in agent.yml
backend-url:
    - wss://sensu-go.vitalbook.com
subscriptions:
    - Postgres
# Save agent.yml and close it
# Start sensu-agent using a service manager
sudo systemctl start sensu-agent

3. Manually depoly shell check scripts onto postgres sensu agent
mkdir /etc/sensu/plugins
cd /etc/sensu/plugins
vi postgres-cpu.sh
# Copy the cpu check shell script and save the postgres-cpu.sh file
chmod 774 postgres-cpu.sh
# Similarly, do the above steps for memory, alive and connections checks

4. Deploy check configuration on sensu-backend server
vi postgres.yml
# Copy the check config yml and save the postgres.yml file (note: all the check config can be written in one yml file also)

5. Run sensuctl to add the check config into sensu-backend (eventually into sensu-dashboard)
# The configure command will set up the connection to sensu-backend. Run it and configure the environment accordingly
sensuctl configure
# The create command will deploy the checks as per check config yml into sensu-backend/sensu-dashboard
sensuctl create --file postgres.yml

6. Verify the checks on dashboard UI 
# Go to configuration > checks and search for postgres checks that are deployed.

Note: Since we are using custom checks written in shell for postgres monitoring, we deployed the check scripts directly onto the postgres server manually.
Asset resources are required to be stored on a publicly avalible repo (like github), hence you will find the sensu community's pre-made copyrighted check scripts on their github or bonsai publicly available on internet.
Sensu community's assets does not require the check scripts to be deployed on agents because an asset config yml will be created on sensu-backend and the same asset will be referred in the check config yml which in turn sensu-backend will suggest the sensu-agent to go download the check scripts from the referred asset (via internet) and run them on the agent and publish the result back to sensu-backend/dashboard.
For sensu-agent to skip the check scripts to be downloaded through asset via internet, we deployed the check scripts locally on the postgres server (within sensu-agent vicinity)
