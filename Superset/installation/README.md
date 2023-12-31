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