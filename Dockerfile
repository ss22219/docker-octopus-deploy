FROM octopusdeploy/octopusdeploy:latest

RUN curl -o /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/amd64/kubectl && \
    chmod +x /usr/local/bin/kubectl && \
    curl -o /usr/local/bin/aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.16.8/2020-04-16/bin/linux/amd64/aws-iam-authenticator && \
    chmod +x /usr/local/bin/aws-iam-authenticator && \
    curl -o helm.tar.gz https://get.helm.sh/helm-v3.5.4-linux-amd64.tar.gz && \
    tar -xvf helm.tar.gz && \
    mv linux-amd64/helm /usr/local/bin && \
    chmod +x /usr/local/bin/helm && \
    rm -rf linux-amd64 && \
    rm helm.tar.gz
