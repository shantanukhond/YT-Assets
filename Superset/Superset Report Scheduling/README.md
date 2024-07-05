## Alerts and Reports With Superset

> [!IMPORTANT]  
> Celery Redis Should be installed and configured in order to get Alerts and Reports Ready. If you are not sure how to do that please refer [Installing Apache Superset with Redis and Celery](./Superset/Superset%20with%20Redis%20and%20Celery/README.md)[![YouTube Video](https://img.shields.io/badge/Watch-Video-red?logo=youtube)](https://youtu.be/zL7_5EQ88IU). Thank you!


To get Alerts and reports working. We need SMTP creds, and chrome or firefox should be installed. For this tutorial I am using chrome. 


To install headless Chrome on Ubuntu, you can use the following steps:

1. Install Dependencies:
    ```
    sudo apt update
    sudo apt install -y wget apt-transport-https ca-certificates curl gnupg
    ```    

2. Download and Install Google Chrome:

    First, download the Google Chrome package and add the Google Chrome repository to your system:

    ```
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo dpkg -i google-chrome-stable_current_amd64.deb
    ```

    If you encounter any dependency issues, you can run the following command to resolve them:

    ```
    sudo apt -f install
    ```    

3. Install the ChromeDriver:

    The ChromeDriver is a separate executable that WebDriver uses to control Chrome. You need to install it separately:

    ```
    sudo apt install -y chromium-chromedriver
    ```    

4. Verify Installation:

    You can verify that Chrome and ChromeDriver are installed correctly by checking their versions:

    ```
    google-chrome --version
    chromedriver --version
    ```    

    The output should display the installed versions of Chrome and ChromeDriver.

5. Set ChromeDriver Path in Superset Configuration (if necessary):

    If you're using Superset and need to specify the path to ChromeDriver in the configuration file, you can set it like this:


    ```
    CHROME_DRIVER_PATH = '/usr/lib/chromium-browser/chromedriver'
    ``` 

    Adjust the path as necessary based on where ChromeDriver is installed on your system.

6. Configure Chrome for Headless Mode:


    ```
    google-chrome --headless
    ```

7. In Superset Config file i.e. `superset_config.py` if you already have `FEATURE_FLAGS` then add `"ALERT_REPORTS": True` it should look something like shown below. If you don't have just copy entire thing and put it in `superset_config.py`

    ```
    FEATURE_FLAGS = {
        "ALERT_REPORTS": True
    }
    ``` 

8. Your config file should look something like this

    ```
    from celery.schedules import crontab

    FEATURE_FLAGS = {
        "ALERT_REPORTS": True
    }

    REDIS_HOST = "superset_cache"
    REDIS_PORT = "6379"

    class CeleryConfig:
        broker_url = f"redis://{REDIS_HOST}:{REDIS_PORT}/0"
        imports = (
            "superset.sql_lab",
            "superset.tasks.scheduler",
        )
        result_backend = f"redis://{REDIS_HOST}:{REDIS_PORT}/0"
        worker_prefetch_multiplier = 10
        task_acks_late = True
        task_annotations = {
            "sql_lab.get_sql_results": {
                "rate_limit": "100/s",
            },
        }
        beat_schedule = {
            "reports.scheduler": {
                "task": "reports.scheduler",
                "schedule": crontab(minute="*", hour="*"),
            },
            "reports.prune_log": {
                "task": "reports.prune_log",
                "schedule": crontab(minute=0, hour=0),
            },
        }
    CELERY_CONFIG = CeleryConfig

    SCREENSHOT_LOCATE_WAIT = 100
    SCREENSHOT_LOAD_WAIT = 600

    # Slack configuration
    SLACK_API_TOKEN = "xoxb-"

    # Email configuration
    SMTP_HOST = "smtp.sendgrid.net" # change to your host
    SMTP_PORT = 2525 # your port, e.g. 587
    SMTP_STARTTLS = True
    SMTP_SSL_SERVER_AUTH = True # If your using an SMTP server with a valid certificate
    SMTP_SSL = False
    SMTP_USER = "your_user" # use the empty string "" if using an unauthenticated SMTP server
    SMTP_PASSWORD = "your_password" # use the empty string "" if using an unauthenticated SMTP server
    SMTP_MAIL_FROM = "noreply@youremail.com"
    EMAIL_REPORTS_SUBJECT_PREFIX = "[Superset] " # optional - overwrites default value in config.py of "[Report] "

    # WebDriver configuration
    # If you use Firefox, you can stick with default values
    # If you use Chrome, then add the following WEBDRIVER_TYPE and WEBDRIVER_OPTION_ARGS
    WEBDRIVER_TYPE = "chrome"
    WEBDRIVER_OPTION_ARGS = [
        "--force-device-scale-factor=2.0",
        "--high-dpi-support=2.0",
        "--headless",
        "--disable-gpu",
        "--disable-dev-shm-usage",
        "--no-sandbox",
        "--disable-setuid-sandbox",
        "--disable-extensions",
    ]

    # This is for internal use, you can keep http
    WEBDRIVER_BASEURL = "http://superset:8088" # When running using docker compose use "http://superset_app:8088'
    # This is the link sent to the recipient. Change to your domain, e.g. https://superset.mydomain.com
    WEBDRIVER_BASEURL_USER_FRIENDLY = "http://localhost:8088"
    ```

9.  Restart Superset using (assuming you have service and has same name as mine i.e. superset)

    ```
    sudo systemctl restart superset
    ```

&nbsp;
&nbsp;
#### Any Question? Feel free to mail me on [contact@shantanukhond.me](mailto://contact@shantanukhond.me)
&nbsp;
&nbsp;
&nbsp;
&nbsp;


### Let's Learn Together! 📖😊

[![Buy Me A Coffee](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/shantanukhond)
