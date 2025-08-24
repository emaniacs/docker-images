FROM percona/percona-xtrabackup:8.0

USER root
RUN microdnf -y --nodocs --noplugins install cronie

COPY --from=rclone/rclone:1.49.1 /root/rclone /usr/local/bin

RUN rclone version

COPY backup.sh /usr/local/bin/backup.sh
## Sample backup script
#RUN echo '* * * * * root /usr/local/bin/backup.sh |tee -a /tmp/backup.sh.log"' > /etc/cron.d/backup


# remove existing crontab, will replace
##RUN echo '* * * * * root sh -c "echo CRONTAB SAMPLE RUN AT: $(date)|tee -a /tmp/cron.log"' > /etc/cron.d/sample

ENTRYPOINT ["/usr/sbin/crond"]
CMD ["-n", "-x", "proc"]
