## Superset Configuration

We will be configuring the following (more will be added as I explore):

1. [App Name](#setting-up-app-name)
2. [Logo](#setting-up-logo)
3. [Favicon Icon](#setting-up-favicon-icon)
4. [Loading Animation GIF](#changing-loading-gif)
5. [Color Theme](#setting-up-custom-color-theme)

### Setting Up App Name
Setting up the app name is easy and can be done by adding the following constant in the `superset_config.py` file:

```python
APP_NAME = "My Reporting Application"
```

### Setting Up Logo
To change the logo, place your logo in the `/app/superset/superset_env/lib/python3.8/site-packages/superset/static/assets/images/your_app_name` path, and copy the URL from `static/assets/images/your_app_name`. Then, paste it below. Along with the logo, configure the route when clicked on the logo and the hover text. You can also add any subheading or branding if necessary.

```python
APP_ICON = "/static/assets/images/your_app_name/logo.png"

# Setting it to '/' would take the user to '/superset/welcome/'
LOGO_TARGET_PATH = '/'

# Specify tooltip that should appear when hovering over the App Icon/Logo
LOGO_TOOLTIP = "My App Name"

# Specify any text that should appear to the right of the logo
LOGO_RIGHT_TEXT = "My Department Name"
```

### Setting Up Favicon Icon
To set up the favicon, place the favicon icon in the `/app/superset/superset_env/lib/python3.8/site-packages/superset/static/assets/images/your_app_name/favicon/` folder, copy the path from `static/assets/images/your_app_name/favicon/favicon.png`, and put it in the configuration file as shown below:

```python
FAVICONS = [{"href": "static/assets/images/your_app_name/favicon/favicon.png"}]
```

### Changing Loading GIF
> **Note:** This method is not foolproof, and I do not support modifying files provided by Superset. Often, it shows the loading icon we provided, but at the end, it will again show the Superset loading icon. I am still trying to find from where it is coming. I found a thread regarding the same on GitHub but without any answers. [GitHub Issue #26458](https://github.com/apache/superset/issues/26458)

To change the loading icon, replace the original loading icon available at `superset/superset/static/assets/images/loading.gif`. Note the name should be the same as Superset expects the loading file to be here.

### Setting Up Custom Color Theme
`THEME_OVERRIDES` is used for adding a custom theme to Superset. Example code for "My theme" custom scheme:

The `index.tsx` file contains the default theme. You can refer to the `defaultTheme` variable in [superset-frontend index.tsx](https://github.com/apache/superset/blob/master/superset-frontend/packages/superset-ui-core/src/style/index.tsx).

One more thread I found for theming is [GitHub Issue #20159](https://github.com/apache/superset/issues/20159).

```python
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
        "error": {
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

[![Buy Me A Coffee](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/shantanukhond)
