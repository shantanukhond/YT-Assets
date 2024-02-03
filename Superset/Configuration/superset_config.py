# Superset specific config
ROW_LIMIT = 5000

# Flask App Builder configuration
# Your App secret key will be used for securely signing the session cookie
# and encrypting sensitive information on the database
# Make sure you are changing this key for your deployment with a strong key.
# Alternatively you can set it with `SUPERSET_SECRET_KEY` environment variable.
# You MUST set this for production environments or the server will not refuse
# to start and you will see an error in the logs accordingly.
SECRET_KEY = 'CcT5cttbffwqCaz2noct0GjC908gMx9K4N9KhAFM1xA+UarqwoCKOEFg'

# The SQLAlchemy connection string to your database backend
# This connection defines the path to the database that stores your
# superset metadata (slices, connections, tables, dashboards, ...).
# Note that the connection information to connect to the datasources
# you want to explore are managed directly in the web UI
# The check_same_thread=false property ensures the sqlite client does not attempt
# to enforce single-threaded access, which may be problematic in some edge cases
SQLALCHEMY_DATABASE_URI = 'sqlite:////app/superset/superset.db?check_same_thread=false'

TALISMAN_ENABLED = False
WTF_CSRF_ENABLED = False

# Set this API key to enable Mapbox visualizations
MAPBOX_API_KEY = ''

APP_NAME = "My Reporting Application"


APP_ICON = "/static/assets/images/my_company_images/my_company_logo.png"

# Setting it to '/' would take the user to '/superset/welcome/'
LOGO_TARGET_PATH = '/'

# Specify tooltip that should appear when hovering over the App Icon/Logo
LOGO_TOOLTIP = "My App Name"

# Specify any text that should appear to the right of the logo
LOGO_RIGHT_TEXT = "My Department Name"


FAVICONS = [{"href": "static/assets/images/my_company_images/favicon.png"}]


THEME_OVERRIDES = {
    
    "colors": {

        "text": {
            "label": '#879399',
            "help": '#737373'
        },

        "primary": {
            "base": 'red',
        },
        "secondary": {
            "base": 'green',
        },
        "grayscale": {
            "base": 'orange',
        },
        "error":{
            "base": 'Pink'
        }
    },


    "typography": {
        "families": {
        "sansSerif": 'Inter',
        "serif": 'Georgia',
        "monospace": 'Fira Code',
        },
        "weights": {
            "light": 200,
            "normal": 400,
            "medium": 500,
            "bold": 600
        }
	}
}
