# Gene Dosage Reader

This service reads from the gene-dosage curation topic on JIRA (ISCA) and translates issues of a curation type (ISCA Gene Curation and ISCA Region Curation) to a specified kafka topic (gene_dosage_raw). The above configuration is set via enivromnment variables, passed to the jira-reader application. Authentication to both Jira and Kafka are stored as secrets in Kubernetes.
