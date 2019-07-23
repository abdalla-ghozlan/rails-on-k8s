## Rails on K8S

For demo purposes I'm using [minikube]([https://kubernetes.io/docs/setup/learning-environment/minikube/](https://kubernetes.io/docs/setup/learning-environment/minikube/)) and [kubectl]([https://kubernetes.io/docs/tasks/tools/install-kubectl/](https://kubernetes.io/docs/tasks/tools/install-kubectl/)) for running kubernetes cluster on my local machine. 


### Application stack

- Rails 4.2 on ruby 2.2.3
- Unicorn for serving the static and dynamic resources 
- Sidekiq job worker
- Redis for cahce and job queues
- Postgres DB

### Architecture Diagram

![Server Setup Diagram](https://github.com/ghozln/rails-on-k8s/rails-on-k8s.jpg) This is a typical deployment strategy for rails on k8s thought I'm covering the Ingress part for now I'll update it later.

### Start now
#### Find all kubectl commands for deploying the pre-configured yaml files in the k8s/imperative-cmds directory or follow me here.
- Create a map configuration values to be referenced and passed to pods on run time.
```
$ kubectl create -f configmap_appconfigs.yml; 
```
- Create a base64-encrypted list for passwords and secrets to be referenced and passed to pods on run time.
```
$ kubectl create -f secret_appsecrets.yml; 
```
- Create persistent volume and persistent volume claim for the postgres database so that data can persist after and in-between pods.
```
$ kubectl create -f volume_postgres.yml; 
```
- Create persistent volume and persistent volume claim for the redis so that data can across restarts.
```
$ kubectl create -f volume_redis.yml; 
```
- Create a internal cluster service to direct postgres db requests for db pod/pods.
```
$ kubectl create -f service_postgres.yml;
```
- Create a internal cluster service to direct redis requests for redis pod/pods.
```
$ kubectl create -f service_redis.yml;
```
- Create a deployment for postgres with one initial replica .
```
$ kubectl create -f deployment_postgres.yml --record;
```
- Create a deployment for redis with one initial replica .
```
$ kubectl create -f deployment_redis.yml --record;
```
- Create a internal cluster service to direct app requests for application pod/pods.
```
$ kubectl create -f service_instarails.yml; 
```
- Create a job that runs a pod once to migrate the database.
```
$ kubectl create -f job_migratedb.yml; 
```
- Create a deployment for the rails app with one initial replica and pull image 1.0.0 from my docker hub registry.
```
$ kubectl create -f deployment_instarails.yml --record; 
```
- Create a deployment for the sidekiq job worker with one initial replica and pull image 1.0.0 from my docker hub registry.
```
$ kubectl create -f deployment_sidekiq.yml --record; 
```
- Create a service to expose the rails app on port 30008 (as configured in the service) to the external network so that it can be consumed from any external ip address
```
$ kubectl create -f service_instarails_nodeport.yml; 
```
- Create a service to expose the postgres db on port 30009 (as configured  in the service) to the external network (for dev purposes use credentials from .instademo.env) 
```
$ kubectl create -f service_postgres_nodeport.yml;
```
#### finally
- Get your worker node ip address and append :30008 to access the rails app. In case your are using minikube run
```
$ curl http://$(minikube ip):30008
```
- Deploy a new updates with new app images as easy as: 
```
$ kubectl set image deployments/instarails-deployment instarails=ghozlan/instarails:1.0.1 --record;
```