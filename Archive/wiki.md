How to deploy
1. The kubernetes yamls have to be applied in the following sequence. All kubernetes manifests are under the directory /working-blocks.
1.1 Create a namespace by executing kubectl create -f ns-ohdsi.yamls
1.2 Create secrets for databases by executing kubectl create -f atlas-secrets.yaml. Refer to the file for instructions on creating password or lookup kubernetes documentation.
1.3 Create application databases by executing 