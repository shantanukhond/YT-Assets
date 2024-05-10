### Embedding Superset Dashboard into private Website with authentication and RLS

> [!NOTE]  
> For this tutorial I will be using angular but I will add code for react js soon it should be fairly similar. 


[Superset Documentation for Public User](https://superset.apache.org/docs/security/#public)


### Steps to embed 

1. Install CORS dependency  using `pip install apache-superset[cors]` Make Sure you are in Superset Python Environment.
2. Go to superset config file i.e. `superset_config.py` and add following code.

    ```
        #Feature Flag 
        FEATURE_FLAGS = 
            { 
                "EMBEDDED_SUPERSET": True
            }
        
        # CORS Enabling 
        ENABLE_CORS = True 
        CORS_OPTIONS = 
            { 
                "supports_credentials": True, 
                "allow_headers": "*", 
                "expose_headers": "*", 
                "resources": "*", 
                "origins": ["http://localhost:4200","http://localhost:3000"] //4200 for angular , 3000 for react  
            }
                
        
        # Dashboard embedding 
        GUEST_ROLE_NAME = "Gamma" 
        GUEST_TOKEN_JWT_SECRET = "PASTE_GENERATED_SECRET_HERE" 
        GUEST_TOKEN_JWT_ALGO = "HS256" 
        GUEST_TOKEN_HEADER_NAME = "X-GuestToken" 
        GUEST_TOKEN_JWT_EXP_SECONDS = 300 # 5 minutes
    ```

    This will enable feature flag for embedding also cors be enabled with above configuration 

## Now We will divide into two parts 
1. [Angular](#angular-part)
2. [React](#react-part)


### ANGULAR PART 

3. Create service in angular using following command

```
    ng g s superset-embed
```

4. Once service is created run following command to install dependencies `npm install --save @superset-ui/embedded-sdk`


5. Our environment is ready lets begin coding copy service file from 
[superset-embedding-service.ts]("Superset/Embedding Superset/With Authentication/assets/superset-embedding-service.ts")

OR 

You can use following code. Please make sure you divide following function into two. One part till you get guest token should be in backend and you should not add creds in here. So whenever you call backend it will return guest token with all filters, RLS pre implemented.

```
 private supersetUrl = 'http://SUPERSET_IP_ADDRESS'
  private supersetApiUrl = `${this.supersetUrl}/api/v1/security`
  private dashboardId = "YOUR_DASHBOARD_EMBEDDING_ID"


  getToken() {
    //calling login to get access token
    const body = {
      "password": "YOUR_PASSWORD_OF_USER_WITH_REPORT_N_EMBEDDING_PERMISSION",
      "provider": "db",
      "refresh": true,
      "username": "YOUR_USERNAME_OF_USER_WITH_REPORT_N_EMBEDDING_PERMISSION"
    };

    const headers = new HttpHeaders({
      "Content-Type": "application/json"
    });

    return this.http.post(`${this.supersetApiUrl}/login`, body, { headers }).pipe(
      catchError((error) => {
        console.error(error);
        return throwError(error);
      }),
      switchMap((accessToken: any) => {
        const body = {
          "resources": [
            {
              "type": "dashboard",
              "id": this.dashboardId,
            }
          ],
          "rls":[],
          "user": {
            "username": "report-viewer",
            "first_name": "report-viewer",
            "last_name": "report-viewer",
          }
        };

        const acc = accessToken["access_token"]; 
          const headers = new HttpHeaders({
          "Content-Type": "application/json",
          "Authorization": `Bearer ${acc}`,
        });

        return this.http.post<any>(`${this.supersetApiUrl}/guest_token/`, body, { headers });
      }));
  }

    // Above part should be implemented in backend and should only be called here to get guest token.

  embedDashboard() {
    return new Observable((observer) => {
      this.getToken().subscribe(
        (token) => {
          embedDashboard({
            id: this.dashboardId,
            supersetDomain: this.supersetUrl,
            mountPoint: document.getElementById('superset_embedding_div_class')!,
            fetchGuestToken: () => token["token"],
            dashboardUiConfig: {
              hideTitle: true,
              hideChartControls: true,
              hideTab: true,
              filters: {
                visible: false,
                expanded: false
              },
              urlParams: {
                standalone: "1",
                show_filters: "0",
                show_native_filters: "0"

              }
            },
          });
          observer.next();
          observer.complete();
        },
        (error) => {
          observer.error(error);
        }
      );
    });
  }
```




6. copy component file only (constructor and imports) from [superset-component.ts]("Superset/Embedding Superset/With Authentication/assets/superset-component.ts")

7. Copy HTML code to following html file of component

```
    <div id="superset_embedding_div_class"></div>
```

8. Copy following css into css file

```
    iframe{
        min-height: 100vh;
        min-height: 100vw;
    }
```

> [!WARNING]  
> Admin creds should not be used in Angular code directly! You should ideally create service say lambda where your creds are stored and then according to the user you should create Guest user Token using rls if needed.


### React Part

3. Lets start React part. Create function that will generate Token. Again I am repeating that this should not be here in front end should be in backend as we have our creds in here.

I am using axios so need to install axios and Superset sdk using

`npm install --save @superset-ui/embedded-sdk` & `npm install --save axios`


```

    import axios from 'axios';
    import { embedDashboard } from "@superset-ui/embedded-sdk";


    const supersetUrl = 'http://YOUR_DASHBOARD_URL_HERE'
    const supersetApiUrl = supersetUrl + '/api/v1/security'
    const dashboardId = "EMBED_ID_HERE"

    async function getToken() {
    
    //calling login to get access token
    const login_body = {
        "password": "YOUR_PASSWORD_WITH_EMBED_N_DASHBOARD_PERMISSION",
        "provider": "db",
        "refresh": true,
        "username": "YOUR_USERNAME_WITH_EMBED_N_DASHBOARD_PERMISSION"
    };

    const login_headers = {
        "headers": {
        "Content-Type": "application/json"
        }
    }

    console.log(supersetApiUrl + '/login')
    const { data } = await axios.post(supersetApiUrl + '/login', login_body, login_headers)
    const access_token = data['access_token']
    console.log(access_token)


    // Calling guest token
    const guest_token_body = JSON.stringify({
        "resources": [
        {
            "type": "dashboard",
            "id": dashboardId,
        }
        ],
        "rls": [],
        "user": {
        "username": "report-viewer",
        "first_name": "report-viewer",
        "last_name": "report-viewer",
        }
    });

    const guest_token_headers = {
        "headers": {
        "Content-Type": "application/json",
        "Authorization": 'Bearer ' + access_token
        }
    }


    console.log(supersetApiUrl + '/guest_token/')
    console.log(guest_token_body)
    console.log(guest_token_headers)
    await axios.post(supersetApiUrl + '/guest_token/', guest_token_body, guest_token_headers).then(dt=>{
        console.log(dt.data['token'])
        embedDashboard({
            id: dashboardId,  // given by the Superset embedding UI
            supersetDomain: supersetUrl,
            mountPoint: document.getElementById("superset-container"), // html element in which iframe render
            fetchGuestToken: () => dt.data['token'],
            dashboardUiConfig: { hideTitle: true }
        });
    })

    var iframe = document.querySelector("iframe")
    if (iframe) {
        iframe.style.width = '100%'; // Set the width as needed
        iframe.style.minHeight = '100vw'; // Set the height as needed
    }

    }


    function App() {

    getToken()

    return (
        <div className="App">
        <div id='superset-container'></div> // Here Superset is going to be embedded
        </div>
    );
    }

```



### Other

&nbsp;
&nbsp;
&nbsp;
&nbsp;

##### Let's Learn Together! 📖😊

&nbsp;
&nbsp;
&nbsp;
&nbsp;

Credits: For Angular Code this helped me-> https://medium.com/@chaudharypushpendra.11.10.2000/embedding-of-apache-superset-dashboard-in-the-mifos-initiative-angular-web-app-b9259f1f1f1b

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/shantanukhond)
