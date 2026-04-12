FROM jenkins/jenkins:lts-jdk21

USER root

ARG ALLURE_VERSION=2.39.0

# Install required tools
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        docker.io \
        maven \
        ca-certificates \
        curl \
        wget \
        unzip \
        python3 \
        python3-pip \
        python3-venv && \
    ln -sf /usr/bin/python3 /usr/bin/python && \
    ln -sf /usr/bin/pip3 /usr/bin/pip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy Zscaler certificate
COPY ./certs/rootcert.crt /usr/local/share/ca-certificates/zscaler.crt

# Update CA certificates and Java truststore
RUN update-ca-certificates && \
    keytool -importcert \
        -trustcacerts \
        -alias zscaler \
        -file /usr/local/share/ca-certificates/zscaler.crt \
        -keystore $JAVA_HOME/lib/security/cacerts \
        -storepass changeit \
        -noprompt

# Install Allure from Maven Central (ZIP - stable for corporate networks)
RUN wget -q https://repo.maven.apache.org/maven2/io/qameta/allure/allure-commandline/${ALLURE_VERSION}/allure-commandline-${ALLURE_VERSION}.zip && \
    unzip allure-commandline-${ALLURE_VERSION}.zip -d /opt/ && \
    ln -s /opt/allure-${ALLURE_VERSION}/bin/allure /usr/bin/allure && \
    rm allure-commandline-${ALLURE_VERSION}.zip

USER jenkins