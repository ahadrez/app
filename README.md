# Kubernetes blue-green deployments 

This report holds workflow that allows you to perform blue/green deployments on a Kubernetes cluster.

# Prerequisites/Infrastructure  
infrastructure setup is outside the scope of this demo. 

- Kubernetes cluster 
- Spinnaker 
- Drone CI
- Private Docker registry

1. Created Google Kubernetes Engine (GKE) cluster. 
Deployed the following on the GKE cluster. 
   - Deployed Nginx ingress controller
   - Deployed private docker registry
   - Deployed Drone server. http://drone.aljbali.com   (integrated with https://github.com/ahadrez
   - Deployed Spinnaker. http://spinnaker.aljbali.com  (  persisted with  GCS storage) 
   - Setup Custome domain/DNS ( www.aljbali.com ) 
   
 
# Deployment workflow. 

- Drone CI pipeline.
   *  [drone pipeline](.drone.yml) 
      -  using Drone pipeline to build the th3 application artifacts. ( simple drone pipeline as follow) 
      1. clone the th3 repo
      2. setup a local workspace
      3. build the application artifacts/ build docker image/ push the image to a local registry
      4. trigger webhook for spinnaker pipeline ( CD ) 
  
-  Spinnaker CD pipeline. 
   *  [spinnaker pipeline](resources/spinnaker-pipeline.json) 
      - created a simple spinnaker pipeline to deploy the th3 app using spinnaker native blue/green deployment.
      1. deploy stage.  create Kubernetes resources ( replicaset, service, ingress ) - (resources/deployment.yml) 
      2. disbale stage. this step is needed to disable the "second newest replicaset"  so it doesn't route requests to it. 
         more info: https://spinnaker.io/guides/user/kubernetes-v2/traffic-management/#caveats
    
# Example Scenario/Demo. 
We will start to develop the  “th3” app on our local computer. git post-receive hook configured to trigger drone pipeline so that we can deploy simply by issuing a git push.


      1. clone the repo 
             mkdir ~/th3 && cd ~/the
             git clone https://github.com/ahadrez/app.git
      2.  run the endpoint test script 
             ./demo/test_endpoint.sh app.aljbali.com
      3. change the app version from version 1 to version 2
             vim src/th3.py
         change the APP_VERSION to version 2
             APP_VERSION = os.getenv('APP_VERSION', '1')
      4. commit and push changes 
             git commit -am " th3 version 2 rollout "
             git push 
       
      5. drone server will build and push a docker image to a local registry running in my GKE cluster. 
      https://github.com/ahadrez/app/blob/master/.drone.yml#L16
      
      6. drone server will send webhook to spinnaker pipeline 
      https://github.com/ahadrez/app/blob/master/.drone.yml#L26
      
      7. spinnaker will start the blue/green deployment. 
          1. new replicaset e.g. app-v002
          2. disable old replicaset app-v001
          
      
     

         

