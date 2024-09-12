FROM node:14-alpine

# Args
ARG VERSION=${VERSION:-1.0.0}
ARG MAINTAINER=${MAINTAINER:-robertbruno}
ARG HTTP_SERVER_PORT=${HTTP_SERVER_PORT:-9021}

# Labels
LABEL maintainer="${MAINTAINER}" \
        org.opencontainers.image.authors="${MAINTAINER}" \
        org.opencontainers.image.source="https://github.com/robertbruno/pgnotify-rabbitmq" \
        org.opencontainers.image.version="${VERSION}" \
        org.opencontainers.image.title="pgnotify-rabbitmq" \
        org.opencontainers.image.description="Docker for pgnotify-rabbitmq"

# ENV CMD=${WORKDIR_NAME}/pgnotify-rabbitmq.js
ENV CMD=/opt/pgnotify-rabbitmq.js
ENV NODE_ENV=production

# install gettext for envsubst
RUN apk update && apk add gettext

WORKDIR /${PRODUCT_NAME}/${SERVICE_NAME}/

COPY ./src/package.json .
RUN npm install --production 
COPY ./src .

COPY scripts/docker-entrypoint.sh /
COPY scripts/20-envsubst-on-templates.sh /docker-entrypoint.d/20-envsubst-on-templates.sh
RUN chmod +x /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.d/20-envsubst-on-templates.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE ${HTTP_SERVER_PORT}

STOPSIGNAL SIGQUIT

#HEALTHCHECK --interval=60s --timeout=2s --start-period=15s --retries=10 \  
 # CMD node /${PRODUCT_NAME}/${SERVICE_NAME}/healthcheck.js

RUN chmod +x $CMD
CMD node $CMD
