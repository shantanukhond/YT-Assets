## SUPERSET PRODUCTION INSTALLATION


#### Set up environment

* Update Ubuntu

`sudo apt update -y & sudo apt upgrade -y`

* Create app directory for superset and dependencies 

```
mkdir /app
cd /app
```

* Create python environment 

```
mkdir superset
cd superset
python3 -m venv superset_env
. superset_env/bin/activate
pip install --upgrade setuptools pip
```

* Create superset config file and set environment variable 

```
touch superset_config.py
export SUPERSET_CONFIG_PATH=/app/superset-env/superset_config.py

```

* Edit and paste following code in it

```
# Superset specific config
ROW_LIMIT = 5000

# Flask App Builder configuration
# Your App secret key will be used for securely signing the session cookie
# and encrypting sensitive information on the database
# Make sure you are changing this key for your deployment with a strong key.
# Alternatively you can set it with `SUPERSET_SECRET_KEY` environment variable.
# You MUST set this for production environments or the server will not refuse
# to start and you will see an error in the logs accordingly.
SECRET_KEY = 'YOUR_OWN_RANDOM_GENERATED_SECRET_KEY'

# The SQLAlchemy connection string to your database backend
# This connection defines the path to the database that stores your
# superset metadata (slices, connections, tables, dashboards, ...).
# Note that the connection information to connect to the datasources
# you want to explore are managed directly in the web UI
# The check_same_thread=false property ensures the sqlite client does not attempt
# to enforce single-threaded access, which may be problematic in some edge cases
SQLALCHEMY_DATABASE_URI = 'sqlite:////app/superset-env/superset.db?check_same_thread=false'

TALISMAN_ENABLED = False
WTF_CSRF_ENABLED = False

# Set this API key to enable Mapbox visualizations
MAPBOX_API_KEY = ''
```

* Once Done let us inititlize database with following commands 

```
# Create an admin user in your metadata database (use `admin` as username to be able to load the examples)
export FLASK_APP=superset

superset db upgrade

superset fab create-admin

# As this is going to be production I have commented load example part but if you need you can run this
# superset load_examples

# Create default roles and permissions
superset init

```

* Now Our environment is ready lets try running it..
To run superset I have created a sh script that you can run in order to run the server. To create create script using following command.

```
nano run_superset.sh
```

and paste following code in it.

```
#!/bin/bash
export SUPERSET_CONFIG_PATH=/app/superset-env/superset_config.py
 . /app/superset-env/superset_env/bin/activate
gunicorn \
      -w 10 \
      -k gevent \
      --timeout 120 \
      -b  0.0.0.0:8088 \
      --limit-request-line 0 \
      --limit-request-field_size 0 \
      --statsd-host localhost:8125 \
      "superset.app:create_app()"
```


* In order to run it we need to grant it run permission. To do that lets run following command.
```
chmod +x run_superset.sh
```

 * Lets run and test if it works?

```
sh run_superset.sh
```

* check if you are able to login using admin creds on server-ip-address:8088. If everything is working fine then we can go ahead and create service that will start automatically as soon as server starts or in case it reboots.

Lets create service called superset using following command

```
sudo nano /etc/systemd/system/superset.service
```

paste following code in it 

```
[Unit]
Description = Apache Superset Webserver Daemon
After = network.target

[Service]
PIDFile = /app/superset-env/superset-webserver.PIDFile
Environment=SUPERSET_HOME=/app/superset-env
Environment=PYTHONPATH=/app/superset-env
WorkingDirectory = /app/superset-env
limit-re>
ExecStart = /app/superset-env/run_superset.sh
ExecStop = /bin/kill -s TERM $MAINPID


[Install]
WantedBy=multi-user.target

```

once copied run following command to enable and start service

```
systemctl daemon-reload
sudo systemctl enable superset.service
sudo systemctl start superset.service
```
