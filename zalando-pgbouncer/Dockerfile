ARG PGBOUNCER_VERSION=master-32
FROM registry.opensource.zalan.do/acid/pgbouncer:${PGBOUNCER_VERSION}

ARG SERVER_TLS_SSLMODE=require
ARG CLIENT_TLS_SSLMODE=disable

## replace server_tls_sslmode with $SERVER_TLS_SSLMODE
RUN sed -i "/#/!s/server_tls_sslmode[[:space:]]*=.*/server_tls_sslmode = ${SERVER_TLS_SSLMODE}/" /etc/pgbouncer/pgbouncer.ini.tmpl

## replace client_tls_sslmode with $CLIENT_TLS_SSLMODE
RUN sed -i "/#/!s/client_tls_sslmode[[:space:]]*=.*/client_tls_sslmode = ${CLIENT_TLS_SSLMODE}/" /etc/pgbouncer/pgbouncer.ini.tmpl

RUN grep ssl /etc/pgbouncer/pgbouncer.ini.tmpl
