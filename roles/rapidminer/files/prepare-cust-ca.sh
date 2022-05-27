#!/bin/bash

# https://mikefarah.gitbook.io/yq/commands/write-update


PLATFORM_YML="platform-docker-compose.yml"
ENV_FILE=".env"

if ! $(yq r "$PLATFORM_YML" services.rm-init-svc.environment|grep -v "^#"|grep -q HTTPS_CRT_PATH);then
    yq w -i "$PLATFORM_YML" "services.rm-init-svc.environment[+]" "HTTPS_CRT_PATH=\${HTTPS_CRT_PATH}"
fi
if ! $(yq r "$PLATFORM_YML" services.rm-init-svc.volumes|grep -v "^#"|grep -q '\/tmp\/ssl');then
    yq w -i "$PLATFORM_YML" "services.rm-init-svc.volumes[+]" "./ssl:/tmp/ssl"
fi
if ! $(yq r "$PLATFORM_YML" services.rm-server-svc.environment|grep -v "^#"|grep -q 'JAVA_KEYSTORE_PATH');then
    yq w -i "$PLATFORM_YML" "services.rm-server-svc.environment[+]" "JAVA_KEYSTORE_PATH=/usr/java/default/jre/lib/security/cacerts"
fi
if ! $(yq r "$PLATFORM_YML" services.rm-server-svc.environment|grep -v "^#"|grep -q 'PROXY_HTTPS_PORT');then
    yq w -i "$PLATFORM_YML" "services.rm-server-svc.environment[+]" "PROXY_HTTPS_PORT=443"
fi
if ! $(yq r "$PLATFORM_YML" services.rm-server-svc.volumes|grep -v "^#"|grep -q '\/java_cacerts');then
    yq w -i "$PLATFORM_YML" "services.rm-server-svc.volumes[+]" "./ssl/java_cacerts/cacerts:/etc/pki/ca-trust/extracted/java/cacerts"
fi
if ! $(yq r "$PLATFORM_YML" services.rm-radoop-proxy-svc|grep -v "^#"|grep -q 'volumes');then
    yq w -i "$PLATFORM_YML" "services.rm-radoop-proxy-svc.volumes" null
fi
if ! $(yq r "$PLATFORM_YML" services.rm-radoop-proxy-svc.volumes|grep -v "^#"|grep -q '\/ca-bunde');then
    yq w -i "$PLATFORM_YML" "services.rm-radoop-proxy-svc.volumes[+]" "./ssl/rh_cacerts/ca-bundle.trust.crt:/etc/pki/ca-trust/extracted/openssl/ca-bundle.trust.crt"
    yq w -i "$PLATFORM_YML" "services.rm-radoop-proxy-svc.volumes[+]" "./ssl/rh_cacerts/ca-bundle.crt:/etc/pki/tls/certs/ca-bundle.crt"
fi
if ! $(yq r "$PLATFORM_YML" services.platform-admin-webui-svc.volumes|grep -v "^#"|grep -q '\.\/ssl\/deb_cacerts');then
    yq w -i "$PLATFORM_YML" "services.platform-admin-webui-svc.volumes[+]" "./ssl/deb_cacerts/:/etc/ssl/certs/"
fi
if ! $(yq r "$PLATFORM_YML" services.rm-jupyterhub-svc.environment|grep -v "^#"|grep -q 'REQUESTS_CA_BUNDLE');then
    yq w -i "$PLATFORM_YML" "services.rm-jupyterhub-svc.environment[+]" "REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt"
fi
if ! $(yq r "$PLATFORM_YML" services.rm-jupyterhub-svc.environment|grep -v "^#"|grep -q 'JHUB_CUSTOM_CA_CERTS');then
    yq w -i "$PLATFORM_YML" "services.rm-jupyterhub-svc.environment[+]" "JHUB_CUSTOM_CA_CERTS=\${JHUB_CUSTOM_CA_CERTS}"
fi
if ! $(yq r "$PLATFORM_YML" services.rm-jupyterhub-svc.volumes|grep -v "^#"|grep -q '\.\/ssl\/deb_cacerts');then
    yq w -i "$PLATFORM_YML" "services.rm-jupyterhub-svc.volumes[+]" "./ssl/deb_cacerts/:/etc/ssl/certs/"
fi
if ! $(yq r "$PLATFORM_YML" services.rm-grafana-svc.volumes|grep -v "^#"|grep -q '\.\/ssl\/deb_cacerts');then
    yq w -i "$PLATFORM_YML" "services.rm-grafana-svc.volumes[+]" "./ssl/deb_cacerts/:/etc/ssl/certs/"
fi
if ! $(yq r "$PLATFORM_YML" services.landing-page.volumes|grep -v "^#"|grep -q '\.\/ssl\/deb_cacerts');then
    yq w -i "$PLATFORM_YML" "services.landing-page.volumes[+]" "./ssl/deb_cacerts/:/etc/ssl/certs/"
fi
if ! $(yq r "$PLATFORM_YML" services.rm-token-tool-svc.volumes|grep -v "^#"|grep -q '\.\/ssl\/deb_cacerts');then
    yq w -i "$PLATFORM_YML" "services.rm-token-tool-svc.volumes[+]" "./ssl/deb_cacerts/:/etc/ssl/certs/"
fi

if grep -q "^PUBLIC_URL=http:" "$ENV_FILE";then
    sed -i 's/^PUBLIC_URL=http:/PUBLIC_URL=https:/' "$ENV_FILE"
fi
if grep -q "^SSO_PUBLIC_URL=http:" "$ENV_FILE";then
    sed -i 's/^SSO_PUBLIC_URL=http:/SSO_PUBLIC_URL=https:/' "$ENV_FILE"
fi
if grep -q "^\#\?JHUB_CUSTOM_CA_CERTS" "$ENV_FILE";then
    sed -i "s,^\#\?JHUB_CUSTOM_CA_CERTS.*$,JHUB_CUSTOM_CA_CERTS=$PWD/ssl/deb_cacerts/," "$ENV_FILE"
fi
