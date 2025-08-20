FROM alpine:3.21 AS build
ARG VERSION=1.24.1

RUN apk add --no-cache autoconf automake curl gcc libc-dev libevent-dev libtool openssl-dev make

RUN curl -sS -o /pgbouncer.tar.gz -L https://www.pgbouncer.org/downloads/files/$VERSION/pgbouncer-$VERSION.tar.gz

RUN tar -xzf pgbouncer.tar.gz \
        && mv pgbouncer-$VERSION pgbouncer \
        && cd /pgbouncer \
        && ./configure --prefix=/usr \
        && make

FROM alpine:3.21

RUN apk add --no-cache busybox libevent postgresql-client && \
  mkdir -p /etc/pgbouncer /var/log/pgbouncer /var/run/pgbouncer && \
  touch /etc/pgbouncer/userlist.txt && \
  chown -R postgres /var/log/pgbouncer /var/run/pgbouncer /etc/pgbouncer

COPY --from=build /pgbouncer/pgbouncer /usr/bin
COPY --from=build /pgbouncer/etc/pgbouncer.ini /etc/pgbouncer/pgbouncer.ini.example
COPY --from=build /pgbouncer/etc/userlist.txt /etc/pgbouncer/userlist.txt.example
EXPOSE 5432
USER postgres

ENTRYPOINT ["/usr/bin/pgbouncer"]
CMD ["/usr/bin/pgbouncer", "/etc/pgbouncer/pgbouncer.ini"]
