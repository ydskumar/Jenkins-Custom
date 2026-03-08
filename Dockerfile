FROM jenkins/jenkins:lts-jdk21

USER root

# Install required packages
RUN apt-get update && \
    apt-get install -y \
        docker.io \
        maven \
        ca-certificates \
        curl \
        python3 \
        python3-pip \
        python3-venv && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Make python & pip accessible as default commands
RUN ln -sf /usr/bin/python3 /usr/bin/python && \
    ln -sf /usr/bin/pip3 /usr/bin/pip

# Copy Zscaler certificate
COPY ./certs/rootcert.crt /usr/local/share/ca-certificates/zscaler.crt

# Update Linux CA store
RUN update-ca-certificates

# Add certificate to Java truststore
RUN keytool -importcert \
    -trustcacerts \
    -alias zscaler \
    -file /usr/local/share/ca-certificates/zscaler.crt \
    -keystore $JAVA_HOME/lib/security/cacerts \
    -storepass changeit \
    -noprompt

USER jenkins