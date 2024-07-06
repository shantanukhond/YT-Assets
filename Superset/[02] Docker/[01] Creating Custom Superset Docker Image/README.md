## Creating and deploying Apache Superset's customized docker image 

1. To create custom docker image lets clone superset's github Repo using following command. To reduce   time and resources we will only clone till depth 1 and for this tutorial I am selecting 4.0 branch.


    ```
    git clone --depth=1 -b 4.0 https://github.com/apache/superset.git
    ```

2. Let's move to directory 
    ```
    cd superset
    ```
3. Create a dir I am calling it to_be_copied and create following directory structure in it
    ```
    - to_be_copied_into_assets
        - {your_project_}images
            - logo.png
            - favicon.png  
    ```

4. Open `Dockerfile` find `WORKDIR /app` for me it is on line 65 (In future it might change). Add following code below it
    ```

    ```

5. Creating docker image using following command
    ```
    docker build -t shan-superset .
    ```

3. Need to do few changes to get our image running open `docker-compose-non-dev.yml` 
    and change image name to shan-superset