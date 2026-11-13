ARG PWS_VERSION=0.16.1
FROM jasonacox/pypowerwall-server:${PWS_VERSION}
COPY run.sh /run.sh
RUN chmod +x /run.sh
ENTRYPOINT ["tini", "--"]
CMD ["/run.sh"]
