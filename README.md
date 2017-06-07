# api_gw

Image for running nginx based openresty as api gateway for mesos based apis.

## Building and running the Image

Enter where the Dockerfile is and issue:

```sh
docker build .
  
  + result: <image id>

# 9090 -> api refresher rest endpoint
# 443,80 -> nginx lb 
docker run -p 9090:9090 -p 443:443 -p 80:80 --env-file=env.docker <image id>
```
