FROM jenkins/jenkins:lts-jdk21

USER root

ARG ALLURE_VERSION=2.39.0

# Copy Zscaler certificate
COPY ./certs/rootcert.crt /usr/local/share/ca-certificates/zscaler.crt

# Update CA certificates and Java truststore before package downloads.
RUN update-ca-certificates && \
    keytool -importcert \
        -trustcacerts \
        -alias zscaler \
        -file /usr/local/share/ca-certificates/zscaler.crt \
        -keystore $JAVA_HOME/lib/security/cacerts \
        -storepass changeit \
        -noprompt

# Install required tools and Docker CLI plugins.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gnupg \
        maven \
        wget \
        unzip \
        python3 \
        python3-pip \
        python3-venv && \
    install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc && \
    chmod a+r /etc/apt/keyrings/docker.asc && \
    . /etc/os-release && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian ${VERSION_CODENAME} stable" > /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        docker-ce-cli \
        docker-buildx-plugin \
        docker-compose-plugin && \
    ln -sf /usr/bin/python3 /usr/bin/python && \
    ln -sf /usr/bin/pip3 /usr/bin/pip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Allure from Maven Central and verify the published checksum.
RUN wget -q https://repo.maven.apache.org/maven2/io/qameta/allure/allure-commandline/${ALLURE_VERSION}/allure-commandline-${ALLURE_VERSION}.zip -O /tmp/allure.zip && \
    wget -q https://repo.maven.apache.org/maven2/io/qameta/allure/allure-commandline/${ALLURE_VERSION}/allure-commandline-${ALLURE_VERSION}.zip.sha512 -O /tmp/allure.zip.sha512 && \
    echo "$(cat /tmp/allure.zip.sha512)  /tmp/allure.zip" | sha512sum -c - && \
    unzip /tmp/allure.zip -d /opt/ && \
    ln -sf /opt/allure-${ALLURE_VERSION}/bin/allure /usr/bin/allure && \
    rm /tmp/allure.zip /tmp/allure.zip.sha512

USER jenkins