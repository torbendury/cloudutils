FROM registry.access.redhat.com/ubi8/ubi

LABEL maintainer="torbendury.de"
LABEL base_image="ubi8/ubi"
LABEL purpose="cloudutils"

# renovate: datasource=github-releases depName=infracost/infracost
ENV INFRACOST_VERSION="v0.10.40"
# renovate: datasource=github-releases depName=tmccombs/hcl2json
ENV HCL2JSON_VERSION="v0.6.5"
# renovate: datasource=github-releases depName=tfutils/tfenv
ENV TFENV_VERSION="3.0.0"
# renovate: datasource=github-releases depName=cloudskiff/driftctl
ENV DRIFTCTL_VERSION="v0.40.0"
# renovate: datasource=github-releases depName=helm/helm
ENV HELM_VERSION="v3.16.4"
# renovate: datasource=github-releases depName=mikefarah/yq
ENV YQ_VERSION="v4.44.6"
# renovate: datasource=github-releases depName=jqlang/jq
ENV JQ_VERSION="jq-1.7"
# renovate: datasource=github-releases depName=oras-project/oras
ENV ORAS_VERSION="v1.2.2"

# Add EPEL
RUN cd /tmp && \
    curl https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm -o epel-release-latest-8.noarch.rpm && \
    yum install -y ./epel-release-latest-8.noarch.rpm


# Add custom repos
ENV REPO_DIR=/etc/yum.repos.d
COPY repos/azure-cli.repo ${REPO_DIR}/azure-cli.repo
COPY repos/google-cloud-sdk.repo ${REPO_DIR}/google-cloud-sdk.repo
COPY repos/kubernetes.repo ${REPO_DIR}/kubernetes.repo


# Install base packages
RUN yum update -y \
    && yum install -y \
    azure-cli \
    bind-utils \
    ca-certificates \
    curl \
    diffutils \
    git \
    golang \
    google-cloud-cli \
    google-cloud-cli-gke-gcloud-auth-plugin \
    jo \
    kubectl \
    openssh \
    openssh-clients \
    python3.12 \
    python3.12-devel \
    python3.12-pip \
    sudo \
    tar \
    unzip \
    && yum clean all

# Configure Python
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 2 && \
    update-alternatives --set python3 /usr/bin/python3.12 && \
    ln -s /usr/bin/pip3.12 /usr/bin/pip

# Install Python packages
RUN pip install -U \
    setuptools \
    pip-system-certs \
    pip_system_certs \
    certifi \
    pre-commit \
    checkov

# Install Azure CLI addons
RUN az aks install-cli

# Download binary releases from GitHub
RUN curl -Lo helm.tar.gz https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz && \
    tar -xf helm.tar.gz && mv linux-amd64/helm /usr/local/bin/helm && rm helm.tar.gz && rm -rf linux-amd64/ && \
    curl -Lo yq.tar.gz https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64.tar.gz && \
    tar -xf yq.tar.gz && chmod +x yq_linux_amd64 && mv yq_linux_amd64 /usr/bin/yq && rm yq.tar.gz && \
    curl -Lo hcl2json https://github.com/tmccombs/hcl2json/releases/download/${HCL2JSON_VERSION}/hcl2json_linux_amd64 && \
    chmod +x hcl2json && mv hcl2json /usr/local/bin/hcl2json && \
    curl -Lo infracost.tar.gz https://github.com/infracost/infracost/releases/download/${INFRACOST_VERSION}/infracost-linux-amd64.tar.gz && \
    tar -xf infracost.tar.gz infracost-linux-amd64 && rm infracost.tar.gz && chmod +x infracost-linux-amd64 && mv infracost-linux-amd64 /usr/local/bin/infracost && \
    curl -sL --fail https://github.com/snyk/driftctl/releases/download/${DRIFTCTL_VERSION}/driftctl_linux_amd64 -o driftctl && \
    chmod +x driftctl && mv driftctl /usr/local/bin/driftctl && \
    curl -sL --fail https://github.com/jqlang/jq/releases/download/${JQ_VERSION}/jq-linux-amd64 -o jq && \
    chmod +x jq && mv jq /usr/local/bin/jq && \
    curl -LO https://github.com/oras-project/oras/releases/download/${ORAS_VERSION}/oras_${ORAS_VERSION:1}_linux_amd64.tar.gz && \
    tar -zxf oras_${ORAS_VERSION:1}_linux_amd64.tar.gz && chmod +x oras && mv oras /usr/local/bin/

# Use tfenv
RUN mkdir -m 777 -p /.tfenv && curl -sLo /tmp/tfenv.tar.gz https://github.com/tfutils/tfenv/archive/refs/tags/v${TFENV_VERSION}.tar.gz && \
    tar -xf /tmp/tfenv.tar.gz -C /.tfenv && rm /tmp/tfenv.tar.gz && mv /.tfenv/tfenv-${TFENV_VERSION}/* /.tfenv && ln -s /.tfenv/bin/* /usr/local/bin

# Install Helm Extensions
RUN helm plugin install https://github.com/databus23/helm-diff

# Prepare User
RUN groupadd -g 1000 -r ci && \
    useradd ci --create-home -u 1000 -r -g ci && \
    echo "ci ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    chown -R ci:ci /.tfenv && \
    chown -R ci:ci /usr/local/bin/ && \
    mkdir /home/ci/.ssh

USER ci

# Checks
RUN command -v pre-commit && \
    command -v checkov && \
    command -v hcl2json && \
    command -v infracost && \
    command -v driftctl && \
    command -v tfenv && \
    command -v yq && \
    command -v helm
