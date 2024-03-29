# get aks credentials and save them to kubeconfig file in the current directory
 az aks get-credentials --public-fqdn --name myaks --resource-group rgmyaks -a -f

# set context
 export KUBECONFIG=kubeconfig
 kubectl config set-context myaks --namespace default
 kubectl config use-context myaks

exit 0
