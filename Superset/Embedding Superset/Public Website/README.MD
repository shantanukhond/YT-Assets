### Embedding Superset Dashboard into Public Website using Simple iFrame

[![Superset Documentation](https://img.shields.io/badge/Superset-Documentation-blue)](https://superset.apache.org/docs/security/#public)

To enable public access, add the following to your `superset_config.py` file:

```python
PUBLIC_ROLE_LIKE = "Gamma"
```

OR

```python
PUBLIC_ROLE_LIKE_GAMMA = True
```

Both of these variables will create a `Public` role with the same permissions as the `Gamma` role. However, if this doesn't work, you might need to create it manually. 

To copy any other role's permissions, change the code as follows:

```python
PUBLIC_ROLE_LIKE = "ENTER_YOUR_ROLE_NAME_HERE"
```

Once added, restart Superset. You should find a role named `Public` in the list of roles.

> **Note:**  
> If the `Public` role is created without any permissions, delete this role, copy the `Gamma` role, and rename it to `Public`.

### Adding Dataset Permissions

To add dashboard permissions, you need to add dataset permissions to the public role. Type `id` in the search bar in permissions to get a list of all datasets. See the screenshot below:

<p align="center">
<img src="./resources/DatasetPermissions.png" align="center" height="200">
</p>

Once the permissions are added, open the dashboard, click on the three horizontal dots adjacent to "Edit Dashboard", click on "Share", and "Copy permalink to clipboard".

### Embedding the Dashboard

Create an `index.html` file in a folder and copy the following code, replacing the URL with the one copied in the previous step:

```html
<iframe src="REPLACE_YOUR_URL_HERE" height="90%" width="90%" title="Iframe Example"></iframe>
```

Adjust the height and width as needed. Open the HTML page in a browser, and you should see Superset loading. If you encounter any issues, feel free to contact me on LinkedIn, via email, or any other means you find comfortable.

##### Let's Learn Together! 📖😊

[![Buy Me A Coffee](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/shantanukhond)
