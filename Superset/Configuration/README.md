## Superset Configuration 


We will Be configuring following (More Will be added as I explore):
1.  App Name
1.  Logo
1.  Favicon Icon
1.  Loading Animation GIF
1.  Color Theme


#### Setting Up App Name
Setting Up app Name is easy and can be done by adding following constant in `superset_config.py` file

```
    APP_NAME = "My Reporting Application"
```


#### Setting Up Logo
To Change Logo Place your logo in `static/assets/images/your_app_name` path and copy url from `static/assets/images/your_app_name` and paste below. Along with logo we will configure route when clicked on logo and on hover what should be visible. Also, we can add if any sub heading or branding if there is any.

```
    APP_ICON = "/static/assets/images/your_app_name/logo.png"
    
    # Setting it to '/' would take the user to '/superset/welcome/'
    LOGO_TARGET_PATH = '/'
    
    # Specify tooltip that should appear when hovering over the App Icon/Logo
    LOGO_TOOLTIP = "My App Name"

    # Specify any text that should appear to the right of the logo
    LOGO_RIGHT_TEXT: Callable[[], str] | str = "My Department Name"


```


#### Setting Up Favicon Icon
To Setup Favicon place favicon icon in `static/assets/images/your_app_name/favicon/` folder and copy path from `static/assets/images/your_app_name/favicon/favicon.png` and put in configuration file as shown below
 
```
    FAVICONS = [{"href": "static/assets/images/your_app_name/favicon/favicon.png"}]
```

#### Changing Loading gif
Please note: 
    this is not full proof method and I don't like to modify files provided by superset. Many times it shows the loading icon we provided and at the end it will again show superset loading icon. I tried to find it but in configuration files only one file is there. I am still trying to find from where it is coming. I found a thread regarding same on github but without any answers. (https://github.com/apache/superset/issues/26458)[https://github.com/apache/superset/issues/26458]

To Change loading icon replace the original loading icon available at `superset/superset/static/assets/images/loading.gif` note name should be same as superset knows the loading file is here.