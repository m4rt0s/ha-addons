ARG BUILD_FROM
FROM ${BUILD_FROM}
RUN apt-get update \
 && apt-get install -y --no-install-recommends nginx \
 && rm -rf /var/lib/apt/lists/*
COPY rootfs/nginx-ingress.conf /etc/nginx-ingress.conf
COPY run.sh /run.sh
RUN chmod +x /run.sh
ENTRYPOINT ["/run.sh"]
