# api_gw

Image for running nginx based openresty as api gateway for mesos based apis.

## Scenario

You have your apps running on mesos, let's say py-gauth and py-docker. This apps
could have several endpoints and we need to map those endpoint to a single one.

Here is where apigw get into action. through the spin off project located at
"https://github.com/periket2000/py_apigw_refresher.git" and it's config.json mapping
file, it maps mesos app endpoints to unique hostname entry point.

This refresher is accesible for updating the mappings file at http://apigw-endpoint:9090/update.
You can update the mapping file with curl like:

> curl --upload-file my_config.json http://localhost:9090/update

Here you can see a snippet of the file (my_config.json):

```json
{
    "application_mapping": {
        "py-docker": {
            "appname": "app1.mesos.local",
            "upstream": "py_docker"
        },
        "py-gauth": {
            "appname": "app2.mesos.local",
            "upstream": "py_gauth"
        }
    }
}
```

The sample file above maps py-docker mesos endpoints to app1.mesos.local hostname under nginx py_docker upstream.
The sample file above maps py-gauth mesos endpoints to app2.mesos.local hostname under nginx py_gauth upstream.

## Building and running the Image

Clone the project, enter where the Dockerfile is and issue:

```sh
docker build . -t myapigw
  
# Edit the env.docker file for setting the MESOS_MASTERS environment variable and run the container:
# 9090 -> api refresher rest endpoint
# 443,80 -> nginx lb 
docker run -p 9090:9090 -p 443:443 -p 80:80 --env-file=env.docker myapigw
```

## Mesos deployment file

```json
        {
          "id": "apigw",
          "instances": 1,
          "cpus": 1,
          "mem": 1500,
          "constraints": [["hostname", "UNIQUE", ""]],
          "env": {
              "MESOS_MASTERS": "192.168.250.101,192.168.250.102,192.168.250.103",
              "PROJECT_DIR": "/usr/local/pyenv",
              "GIT_REPO": "https://github.com/periket2000/py_apigw_refresher.git",
              "SRC_DIR": "src",
              "APP_FILE": "app.py",
              "APIGW_CONFIG_DIR": "/etc/nginx/conf.d",
              "PYTHONPATH": "/usr/local/pyenv/py_apigw_refresher",
              "REFRESH_SECONDS": "60"
          },
          "container": {
            "type": "DOCKER",
            "docker": {
              "image": "periket2000/api_gw:v1.1",
              "network": "BRIDGE",
              "portMappings": [
                {
                  "containerPort": 9090,
                  "hostPort": 0,
                  "servicePort": 0,
                  "protocol": "tcp"
                },
                {
                  "containerPort": 80,
                  "hostPort": 0,
                  "servicePort": 0,
                  "protocol": "tcp"
                },
                {
                  "containerPort": 443,
                  "hostPort": 0,
                  "servicePort": 0,
                  "protocol": "tcp"
                }
              ]
            }
          },
          "healthChecks": [
              {
                "protocol": "HTTP",
                "portIndex": 1,
                "path": "/",
                "gracePeriodSeconds": 5,
                "intervalSeconds": 20,
                "maxConsecutiveFailures": 3
              }
            ]
        }

```
