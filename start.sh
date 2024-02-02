#! /bin/bash

tls_init_flag=/irods_tls_certs_initialized.flag
keystore_options=

if [ "$1" != "sha" ]; then
    # Handle TLS certificate.
    if [ ! -f "$tls_init_flag" -a -f /nfsrods_ssl.crt ]; then
        echo "Cert found for NFSRODS"

        nfsrods_keystore=/nfsrods.jks
        cp ${JAVA_HOME}/lib/security/cacerts ${nfsrods_keystore}

        set -e
        echo "Importing cert to NFSRODS keystore"
        keytool -import -trustcacerts -keystore "$nfsrods_keystore" -storepass changeit -noprompt -alias nfsrods -file /nfsrods_ssl.crt
        echo "Done"

        keystore_options="-Djavax.net.ssl.trustStore=${nfsrods_keystore} -Djavax.net.ssl.trustStorePassword=changeit"

        # Creat file to keep the container from processing the
        # TLS certificates again.
        touch $tls_init_flag
    else
        echo "Cert not found for NFSRODS - not importing"
    fi
fi

exec java $keystore_options \
    -Dlog4j2.contextSelector=org.apache.logging.log4j.core.async.AsyncLoggerContextSelector \
    -Dlog4j2.configurationFile=$NFSRODS_CONFIG_HOME/log4j.properties \
    -Dlog4j.shutdownHookEnabled=false \
    -jar /nfsrods.jar "$@"
