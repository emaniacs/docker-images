FROM alpine:latest

# RUN apk add --no-cache postgresql-client pigz s3cmd tmux
RUN apk add --no-cache postgresql-client pigz tmux

# COPY --from=rclone/rclone:1.67 /usr/local/bin/rclone /usr/bin/rclone
COPY --from=rclone/rclone:latest /usr/local/bin/rclone /usr/bin/rclone

RUN pg_dump --version && pg_restore --version

COPY entrypoint.sh /bin/

COPY ./scripts/ /opt/scripts/

ENTRYPOINT ["/bin/entrypoint.sh"]

CMD ["help"]
