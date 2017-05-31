# api_gw

Image for running nginx based openresty as api gateway for mesos based apis.

## Building and running the Image

Enter where the Dockerfile is and issue:

```sh
docker build .
  
  + result: <image id>

docker run -p 443:443 -p 80:80 --env-file=env.sh <image id>
```
