## Apache Superset Enterprise Auto-Scaling architecture with Caching (With Redis) and Celery


Apache superset can be scaled horizontally to be used by thousands of users if needed. The architecture also allows us to run big queries and to cache them in Cache such as Redis to be reused and for faster results. 

I have created an Architectural diagram to explain how superset leverage Redis or similar tools such as rabbit mq, Celery to provide truly asynchronous execution of queries.

Link to Draw.io file can be found here [Apache Superset Enterprise Architecture](https://drive.google.com/file/d/1dz3VOtkgWqidVGy_3bEpsylyq_gUOb4G/view?usp=sharing)

![Apache Superset Enterprise level Architecture](<Assets/Superset Enterprise Architecture.png>)


Let me quickly explain why I am calling it enterprise level architecture.

Consider above diagram. We have a load balancer that can distribute traffic to n number of servers. If we leverage like auto scaling group that will automatically spin vms with image that we have then you can imagine we can handle huge number of traffic.

For storing metadata we already have created one database that is separate from vm and also here as well we can leverage RDS that can scale up and scale down.

Now this part is a bit surprising if you are new to asynchronous tasks. I guess writing here is going to be difficult but I will try.

When any query will run in superset and async execution is enabled for database. Superset will inform redis about task and it will add this task into queue to be picked up by worker. Celery worker will pickup task from queue and perform all the operations on it. Once executed it will put result back into redis result backend to be picked-up by superset.

This part is actually needs to be clear when we implement usually I get questions like- How superset knows there is any worker running and ans is it does not have even a slight clue if there is any worker. If there are no workers it will just wait and wait and wait.
