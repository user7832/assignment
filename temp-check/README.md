# Test Assigment

## Task
You need to provide the code to spin up a new server, install and configure Prometheus with
Grafana.

On the same server, you should write execute a task that would use public API to get current
temperature in Tallinn and store it in Prometheus.

Simple dashboard in Grafana must be provided to visualize temperature data.
Program to get current temperature should be written by you.

Required technology stack:
 * GitHub to store the code
 * Azure cloud for the new server
 * Ubuntu 20.04 (or later) for the server
 * Latest stable version of Docker and Docker-compose
 * Latest stable version of Prometheus and Grafana
 * Terraform 0.14.x
 * Any scripting language is ok for the program code
 * Feel free to use additional tools for the automation

## Requirements
In order to properly run current configuration, it's supposed that next resources are configured:
For AWS:
  * Terraform configuration is deployed into VPC and subnet with Internet access configured (used default)
  * API key for weatherapi.com service is required
For Azure:
  * Azure confiuration wasn't tested due to absent Azure access

## How to Run
```
cd terraform
terraform init
terraform apply -var="we_apikey=1234567890" -var="key_pair_name=key1"
```

Wait for a minute and access grafana URL which will be printed after terraform apply command
