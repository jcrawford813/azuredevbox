FROM docker.io/library/debian:12

LABEL com.github.containers.toolbox="true" \
      name="azuredev-distrobox" \
      version="12" \
      usage="This image is meant to be used with the distrobox command" \
      summary="Custom image for Azure development" \
      maintainer="jim@mycodinglife.com"

# Remove apt configuration optimized for containers
# Remove docker-gzip-indexes to help with "command-not-found"
RUN rm /etc/apt/apt.conf.d/docker-gzip-indexes /etc/apt/apt.conf.d/docker-no-languages

# Enable myhostname nss plugin for clean hostname resolution without patching
# hosts (at least for sudo), add it right after 'files' entry. We expect that
# this entry is not present yet. Do this early so that package postinst (which
# adds it too late in the order) skips this step
RUN sed -Ei 's/^(hosts:.*)(\<files\>)\s*(.*)/\1\2 myhostname \3/' /etc/nsswitch.conf

# Prevent questions when installing packages
ARG DEBIAN_FRONTEND=noninteractive

# Add Microsoft Keys
RUN apt-get update && \
    apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release wget

RUN curl -sLS https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /usr/share/keyrings/packages.microsoft.gpg > /dev/null

# Add HashiCorp Keys
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

#Add Microsoft Repo
RUN wget https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
RUN dpkg -i packages-microsoft-prod.deb

#Add Edge Repo so that web links in Code will work.
RUN echo 'deb [signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/edge stable main' | tee /etc/apt/sources.list.d/microsoft-edge.list

# Copy sources
COPY ./sources/* /etc/apt/sources.list.d/

# Install packages
RUN apt-get update && \
    apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install \
        libnss-myhostname \
        azure-cli \
        code \
        git \
        jq \
        less \
        python3-pip \
        python3-venv \
        sudo \
        unzip \
        git-lfs \
        terraform \
        wget \
        dotnet-sdk-9.0 \
        dotnet-sdk-8.0 \
        microsoft-edge-stable

RUN apt-get install -y --fix-broken

#Final cleanup
RUN apt-get update && apt-get upgrade -y && apt-get autoremove -y
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Enable password less sudo
RUN sed -i -e 's/ ALL$/ NOPASSWD:ALL/' /etc/sudoers
RUN chown root:root /etc/sudoers
RUN chown root:root /usr/bin/sudo && chmod 4755 /usr/bin/sudo

RUN echo VARIANT_ID=container >> /etc/os-release