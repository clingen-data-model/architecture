#!/bin/bash
#
# Maybe this should be two separate cronjobs - This is #1
# kubectl apply -f ~/dev/git/architecture/services/dev/genegraph-migration-stage-job.yml
#
# This is #2 that runs afterward
kubectl wait --for=condition=complete --timeout=11400s job/genegraph-migration-stage
RESULT=`kubectl logs job.batch/genegraph-migration-stage | grep ":create-migration"`
echo $RESULT | grep ":success"
if [ $? -eq 0 ]
then
    DATA_VERSION=`echo $RESULT | sed 's/.* :version "\([0-9T-]*\)".*/\1/'`
    kubectl set env deployment genegraph GENEGRAPH_DATA_VERSION=$DATA_VERSION
    echo "GENEGRAPH_DATA_VERSION=$DATA_VERSION propogation to genegraph instances successful!"
else
    echo "GENEGRAPH_DATA_VERSION=$DATA_VERSION propogation to genegraph instances failed!"
fi
kubectl delete job gengraph-migration-stage

