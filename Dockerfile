FROM ubuntu:22.04

ARG sssd=false

# The following environment variables are required to avoid errors
# during the installation of openjdk-17-jdk.
ENV JAVA_HOME "/usr/lib/jvm/java-17-openjdk-amd64"
ENV PATH "$JAVA_HOME/bin:$PATH"

RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update && apt-get upgrade -y && \
    apt-get install -y apt-transport-https && \
    apt-get install -y openjdk-17-jdk libnss-sss

# Provide default log4j configuration.
# This keeps log4j quiet when instructing the container to print the SHA.
ADD config/log4j.properties /nfsrods_config/log4j.properties

ADD nfsrods.jar start.sh /
RUN chmod u+x start.sh

# Create a copy of the cacerts which ship with the JDK.
# This allows us to launch the NFSRODS server without root.
ENV NFSRODS_KEYSTORE_FILE "/nfsrods.jks"
RUN cp ${JAVA_HOME}/lib/security/cacerts ${NFSRODS_KEYSTORE_FILE}

# Create a dedicated user for running NFSRODS.
ARG nfsrods_user=nfsrods
RUN adduser --system --disabled-password ${nfsrods_user}
USER ${nfsrods_user}

ENV NFSRODS_CONFIG_HOME=/nfsrods_config

ENTRYPOINT ["./start.sh"]
