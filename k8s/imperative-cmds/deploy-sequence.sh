#!/bin/bash

#first make sure to have kubectl and minikube installed and running use "minikube start" 
#also make sure your shell working directory is where declarative-yamls reside on your machine.

#create a map configuration values to be referenced and passed to pods on run time
kubectl create -f configmap_appconfigs.yml; 
#create a base64 encrypted values for passwords and secrets to be referenced and passed to pods on run time 
kubectl create -f secret_appsecrets.yml;


#create persistent volume and persistent volume claim for the postgres database so that data can persist after and inbetween pods
kubectl create -f volume_postgres.yml;
#create persistent volume and persistent volume claim for the redis so that data can across restarts
kubectl create -f volume_redis.yml;

#create a internal cluster service to direct postgres db requests for db pod/pods
kubectl create -f service_postgres.yml;
#create a internal cluster service to direct redis requests for redis pod/pods
kubectl create -f service_redis.yml;

#create a deployment for postgres with one initial replica 
kubectl create -f deployment_postgres.yml --record;
#create a deployment for redis with one initial replica 
kubectl create -f deployment_redis.yml --record;

#create a internal cluster service to direct app requests for application pod/pods
kubectl create -f service_instarails.yml;
#create a job that runs a pod once to migrate the database
kubectl create -f job_migratedb.yml;

#create a deployment for the rails app with one initial replica and pull image 1.0.0 from my docker hub registry
kubectl create -f deployment_instarails.yml --record;
#create a deployment for the sidekiq job worker with one initial replica and pull image 1.0.0 from my docker hub registry
kubectl create -f deployment_sidekiq.yml --record;

#create a service to expose the rails app on port 30008 (as configured  in the service) to the external network so that it can be consumed from any external ip address 
kubectl create -f service_instarails_nodeport.yml;
#create a service to expose the postgres db on port 30009 (as configured  in the service) to the external network (for dev purposes)
kubectl create -f service_postgres_nodeport.yml;

#get your worker node ip address and append :30008 to access the rails app. In case your are using minikube run
curl http://$(minikube ip):30008

#deploy a new updates with new app images as easy as: 
kubectl set image deployments/instarails-deployment instarails=ghozlan/instarails:1.0.1;