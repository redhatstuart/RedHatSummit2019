# Deploy a CosmosDB instance and AKS cluster running microservices with Ansible
<p align="center">
</p>

1. Create an AKS cluster

    ```
    # Create an AKS cluster in the following Resource Group
    resourceGroupName=myaksrg
    aksName=myaks
    az aks create -g $resourceGroupName \
        -n $aksName \
        -l eastus \
        ... # additional params elided because we'll automate with Ansible
    ```

2. Connect to the AKS cluster

    ```
    # Install kubectl Kubernetes cli
    az aks install-cli
    
    # Connect kubectl to AKS
    az aks get-credentials -g $resourceGroupName -n $aksName
    ```

3. Create CosmosDB managed MongoDB instance for backing store and deploy app to AKS:

    ```
    # Create a CosmosDb instance in the Resource Group
    ./create-cosmosdb.sh $resourceGroupName
    ```
    This script will also apply a Kubernetes manifest `./init-web-api-sample.yaml` which does the following:
    * Create a Kubernetes secret to store the CosmosDB connection string
	* Deploy an init job in a container on AKS that populates CosmosDB with sample data
	* Create Kubernetes deployments for web and api microservice containers
    * Create a public load balancer backed by the web container instances
	* Create an internal service end point for the api container instances
	

Content created by: [Stuart Kirk](https://github.com/stuartatmicrosoft), [Jason De Lorme](https://github.com/ms-jasondel) and others.

<hr/>
All application images are pre-baked and referenced from dockerhub: https://cloud.docker.com/u/jjdelorme/repository/list 

Base implementation for superheros voting application comes from here: https://github.com/ms-jasondel/blackbelt-aks-hackfest

<hr/>

The content of this program can be re-delivered, on request, to any Microsoft customer seeking to deploy open source workloads on Azure.  Please contact stkirk@microsoft.com for additional details and to coordinate delivery of the program.
