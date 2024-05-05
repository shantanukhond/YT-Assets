### Embedding Superset Dashboard into private Website with authentication and RLS

> [!NOTE]  
> For this tutorial I will be using angular but I will add code for react js soon it should be fairly similar. 


[Superset Documentation for Public User](https://superset.apache.org/docs/security/#public)


### Steps to embed

1.  Go to superset config file i.e. `superset_config.py` and add following code.

    ```
        #Feature Flag FEATURE_FLAGS = 
            { 
                "EMBEDDED_SUPERSET": True
            }
        
        # CORS Enabling ENABLE_CORS = True 
        CORS_OPTIONS = 
            { 
                "supports_credentials": True, 
                "allow_headers": "*", 
                "expose_headers": "*", 
                "resources": "*", 
                "origins": ["http://localhost:4200"]  
            }
                
        
        # Dashboard embedding GUEST_ROLE_NAME = "Gamma" 
        GUEST_TOKEN_JWT_SECRET = "PASTE_GENERATED_SECRET_HERE" 
        GUEST_TOKEN_JWT_ALGO = "HS256" 
        GUEST_TOKEN_HEADER_NAME = "X-GuestToken" 
        GUEST_TOKEN_JWT_EXP_SECONDS = 300 # 5 minutes
    ```

    This will enable feature flag for embedding also cors be enabled with above configuration 

2. Create service in angular using following command

```
    ng g s superset-embed
```

3. Once service is created run following command to install dependencies `npm install --save @superset-ui/embedded-sdk`


4. Our environment is ready lets begin coding copy service file from [superset-embedding-service.ts]("Superset/Embedding Superset/With Authentication/assets/superset-embedding-service.ts")


4. copy component file only (constructor and imports) from [superset-component.ts]("Superset/Embedding Superset/With Authentication/assets/superset-component.ts")

5. Copy HTML code to following html file of component

```
    <div id="superset_embedding_div_class"></div>
```

6. Copy following css into css file

```
    iframe{
        min-height: 100vh;
        min-height: 100vw;
    }
```