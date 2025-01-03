# Atlas Deployment on Kubernetes

The document outlines the architecture and the containerised deployment instructions for OHDSIs tool called [ATLAS](https://www.ohdsi.org/software-tools/). To make this deployment ready for demonstration it includes a sample CDM database from Broadsea. This implementation builds on existing containers of various components including [ATLAS](https://hub.docker.com/r/ohdsi/atlas), [WebAPI](https://hub.docker.com/r/ohdsi/webapi), [Postgres DB](https://hub.docker.com/_/postgres) and [a sample Broadsea CDM](https://hub.docker.com/r/ohdsi/broadsea-atlasdb). Finally for practicality the implementation outlines a method of adding a real world CDM using a Kubernetes job. 

Note: This document assumes someone with basic knowledge of kubernetes is deploying it. A helpful [Kuberenetes reference](https://kubernetes.io/docs/home/). 

# Architecture

The architecture is derived from the [Atlas architecture](https://github.com/OHDSI/WebAPI/wiki) with some terminologies relevant to Kubernetes implementation. Figure 1 shows the  architecture diagram and it serves as reference for K8s implementation.

![image info](working-blocks/Atlas-Deployment.png)

Figure 1: ATLAS Architecture

# Kubernetes cluster dimensioning

To deploy this implementation a Kubernetes cluster is needed. The suggested dimensions of the cluster are that it contains a minimum 2 medium sized worker nodes (e.g. 2x 4 VCPUs and 8G RAM) and a minimum of 5GB persistent storage volume for application database. While the CDM database requirements are not outlined here. Additionally, if deployed in a cloud environment a load balancer and an ingress with domain name is recommended with HTTPS setup. 

# Deploying Helm chart

Helm chart is the preferred way of deployment as it simplifies the deployment. The relevant Atlas files are in the “Helm-chart” directory on the [Github repository](https://github.com/Aleem2/Atlas-OHDSI-ARDC/tree/main).The deployment process is outlined below:

* **Create a namespace using the following command.**  
  * kubectl create ns demo1  
* **Create application DB passwords**  
  * Edit / verify passwords for various atlas services. Follow the instructions inside the atlas-secrets.yaml if you are updating passwords. Next create kubernetes secrets. All secrets are managed through this file. Recommend keeping this file at a safe place.   
  * kubectl \-n demo1 create \-f atlas-secrets.yaml  
* **Install Helm chart**  
  * helm \-n demo1 install atlas-demo1 .\\atlas-ohdsi-ardc\\  
* **Restart the Web API register the sample DB**  
  * kubectl \-n demo1 rollout restart deployment.apps/webapi  
* **Ingress for the application access over internet**  
  * This is an important step because it allows traffic to both ATLAS and WebAPI. A test setup is outlined below. While for practical implementation consider using a domain name with HTTPS setup. Nectar tutorials has an excellent example of this [https://tutorials.rc.nectar.org.au/kubernetes/06-ingress](https://tutorials.rc.nectar.org.au/kubernetes/06-ingress). A simple test setup is outlined below.   
  * For the test ingress setup, load balancer IP is being used along with nip.io for traffic fan out. The nip.io allows use of an IP address appended by .nip.io to serve as a web host.   
  * The helm chart installs an ingress but it needs to be configured in run time.   
  * Execute the following command to get the ip address of the ingress, we will call it the ingress ip. Ingress might take a while to get created and assign an IP address, so if the IP address is not assigned re-execute the command after a while.   
    * kubectl \-n demo1 get ingress  
    * Use this ip address to live update the ingress “- host: 203.101.238.248.nip.io” by executing the following command.   
    *  kubectl \-n demo1 edit ingress atlas  
  * Update the atlas config file with host details (203.101.238.248.nip.io) using the following command.  
    * kubectl \-n demo1 edit configmap/atlas-configmap  
    * kubectl \-n demo1 rollout restart deployment.apps/atlas 
* **The application can be accessed on [https://203.101.238.248.nip.io/atlas](https://203.101.238.248.nip.io/atlas)**

# Deploying Kubernetes Yamls (if you prefer not to use Helm chart)

This deployment is a collection of yaml files which translates the deployment instructions into infrastructure as code yaml files. The relevant Atlas files are in the working-blocks directory on the [Github repository](https://github.com/Aleem2/Atlas-OHDSI-ARDC/tree/main). The instructions are meant to be followed sequentially. 

* Create a namespace using the following command.  
  * kubectl create \-f ns-ohdsi.yaml  
* Edit / verify passwords for various atlas services. Follow the instructions inside the atlas-secrets.yaml if you are updating passwords. Next create kubernetes secrets. All secrets are managed through this file. Recommend keeping this file at a safe place.   
  * kubectl \-n ohdsi create \-f atlas-secrets.yaml  
* **Deploy Postgres application db**  
  * kubectl \-n ohdsi apply \-f postgres-pvc.yaml, postgres-init-script-configmap.yaml, postgres-deployment.yaml, postgres-service.yaml  
* **Deploy WebAPI with relevant configurations**  
  * kubectl \-n ohdsi apply \-f webapi-deployment.yaml, webapi-service.yaml  
* **Ingress for the application access over internet**  
* This is an important step because it allows traffic to both ATLAS and WebAPI. A test setup is outlined below. While for practical implementation consider using a domain name with HTTPS setup. Nectar tutorials has an excellent example of this [https://tutorials.rc.nectar.org.au/kubernetes/06-ingress](https://tutorials.rc.nectar.org.au/kubernetes/06-ingress). A simple test setup is outlined below.   
  * For the test ingress setup, load balancer IP is being used along with nip.io for traffic fan out. The nip.io allows use of an IP address appended by .nip.io to serve as a web host.   
  * kubectl \-n ohdsi create \-f atlas-ingress.yaml  
  * Execute the following command to get the ip address of the ingress, we will call it the ingress ip. Ingress might take a while to get created and assign an IP address, so if the IP address is not assigned re-execute the command after a while.   
    * kubectl \-n ohdsi get ingress  
    * Use this ip address to live update the ingress “- host: 203.101.238.248.nip.io” by executing the following command.   
    *  kubectl \-n ohdsi edit ingress atlas  
* **Creating ATLAS deployment with configuration.**  
* Updating the Atlas configuration file  
  * Use the ingress ip from previous step and update the “atlas-configmap.yaml”  
    * The given yaml has 203.101.238.240.nip.io. So change the ip address preceding  “.nip.io”.   
      * kubectl \-n ohdsi create \-f atlas-configmap.yaml  
  * kubectl \-n ohdsi apply create \-f atlas-deployment-v0.3.yaml, atlas-service.yaml

* **Setup Sample CDM (Broadsea sample db) and the required configurations for WebAPI**  
  * The setup of a CDM is delayed to last as WebAPI manipulates the db by creating some tables. These tables are populated with sample CDM settings by creating a one off job.   
  * kubectl \-n ohdsi create \-f broadsea-db-deploy.yaml, broadsea-db-service.yaml, cdm-setup-script-cm.yaml  
    * If you want to add another CDM edit cdm-setup-script-cm.yaml with relevant details. Followed by delete and create the job below.  
  * kubectl \-n ohdsi create \-f broadsea-db-setup-job.yaml  
  * Finally refresh the WebAPI to start serving the new CDM.  
  * kubectl \-n ohdsi rollout restart deploy/webapi

# Setting up a real world CDM (Optional)

* Make sure the sql database is up and running.   
  * Update the “Adding new CDM/new-CDM-setup-job.yaml” file with relevant details. Execute the following command to set up the CMD setup script as a configmap.   
  * kubectl \-n ohdsi create \-f new-CDM-setup-job.yaml  
  * Finally refresh the WebAPI to start serving the new CDM.  
  * kubectl \-n ohdsi rollout restart deploy/webapi
  


  

