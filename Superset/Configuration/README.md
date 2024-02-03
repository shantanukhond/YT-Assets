## Superset Configuration 


We will Be configuring following (More Will be added as I explore):
1.  [App Name](#setting-up-app-name)
1.  [Logo](#setting-up-logo)
1.  [Favicon Icon](#setting-up-favicon-icon)
1.  [Loading Animation GIF](#setting-up-favicon-icon)
1.  [Color Theme](#setting-up-custom-color-theme)


### Setting Up App Name
Setting Up app Name is easy and can be done by adding following constant in `superset_config.py` file

```
APP_NAME = "My Reporting Application"
```


### Setting Up Logo
To Change Logo Place your logo in `/app/superset/superset_env/lib/python3.8/site-packages/superset/static/assets/images/your_app_name` path and copy url from `static/assets/images/your_app_name` and paste below. Along with logo we will configure route when clicked on logo and on hover what should be visible. Also, we can add if any sub heading or branding if there is any.

```
APP_ICON = "/static/assets/images/your_app_name/logo.png"

# Setting it to '/' would take the user to '/superset/welcome/'
LOGO_TARGET_PATH = '/'

# Specify tooltip that should appear when hovering over the App Icon/Logo
LOGO_TOOLTIP = "My App Name"

# Specify any text that should appear to the right of the logo
LOGO_RIGHT_TEXT: Callable[[], str] | str = "My Department Name"


```


### Setting Up Favicon Icon
To Setup Favicon place favicon icon in `/app/superset/superset_env/lib/python3.8/site-packages/superset/static/assets/images/your_app_name/favicon/` folder and copy path from `static/assets/images/your_app_name/favicon/favicon.png` and put in configuration file as shown below
 
```
FAVICONS = [{"href": "static/assets/images/your_app_name/favicon/favicon.png"}]
```

### Changing Loading gif
> **Please note:**  This is not full proof method and I don't support to modifying files provided by superset. Many times it shows the loading icon we provided and at the end it will again show superset loading icon. I tried to find it but in configuration files only one file is there. I am still trying to find from where it is coming. I found a thread regarding same on github but without any answers. https://github.com/apache/superset/issues/26458

To Change loading icon replace the original loading icon available at `superset/superset/static/assets/images/loading.gif` note name should be same as superset knows the loading file is here.


### Setting Up Custom Color Theme

THEME_OVERRIDES is used for adding custom theme to superset. Example code for "My theme" custom scheme.
The `index.tsx` file contains default theme you can refer defaultTheme Variable in https://github.com/apache/superset/blob/master/superset-frontend/packages/superset-ui-core/src/style/index.tsx 

One more thread I found for theming is https://github.com/apache/superset/issues/20159

```    

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
```