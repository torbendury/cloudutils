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
    bind-utils \
    ca-certificates \
    curl \
    diffutils \
    gcc \
    git \
    golang \
    google-cloud-cli \
    google-cloud-cli-gke-gcloud-auth-plugin \
    jo \
    kubectl \
    libpq-devel \
    openssh \
    openssh-clients \
    python3.11 \
    python3.11-devel \
    python3.11-pip \
    python36-devel \
    sudo \
    tar \
    unzip \
    && yum clean all

# Configure Python
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 2 && \
    update-alternatives --set python3 /usr/bin/python3.11 && \
    ln -s /usr/bin/pip3.11 /usr/bin/pip

# Install Python packages
RUN pip install -U \
    psycopg2 \
    setuptools \
    pip-system-certs \
    pip_system_certs \
    certifi \
    pre-commit \
    checkov

# Install Azure CLI addons
RUN az aks install-cli && \
    az extension add --name rdbms-connect --yes --upgrade --system




# Prepare User
RUN groupadd -g 1000 -r ci && \
    useradd ci --create-home -u 1000 -r -g ci && \
    echo "ci ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    chown -R ci:ci /.tfenv && \
    chown -R ci:ci /usr/local/bin/ && \
    mkdir /home/ci/.ssh

# Download binary releases from GitHub
RUN curl -Lo yq.tar.gz https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64.tar.gz && \
    tar -xf yq.tar.gz && chmod +x yq_linux_amd64 && mv yq_linux_amd64 /usr/bin/yq && rm yq.tar.gz

# Install Helm Extensions
RUN helm plugin install https://github.com/databus23/helm-diff

# Checks
RUN command -v pre-commit && \
    command -v checkov && \
