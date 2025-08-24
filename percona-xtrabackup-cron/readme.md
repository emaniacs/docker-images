## Mysql backup using percona xtrabackup


This image created for solve a backup issue using percona xtrabackup and
kubernetes cronjob, percona xtrabackup need direct access to the mysql data dir
and the socket file, so its almost impossible to use kubernetes Cronjob, so i
create this custom image.


I need to create a backup for mysql, installed using bitnami helm chart and the
data already big enough, below are requirements for the backup

- its should no downtime, hot backup
- its should not consume too much resource

mysqldump being first choice whenever we want to backup a mysql data, but its
not met with the requirements, specially mysqldump will lock the the table, yes
we can use `--single-transaction` but the inconsistency data still might happen.

Percona xtrabackup was the best choice, its really good in huge data, low
resources, fast and support live backup since it do phisical backup by copying
the raw data.

By doing phisical backup it mean the app need to access directly the mysql data
and its almost impossible to use kubernetes
Cronjob[https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/]
since that running a different container with the mysql server itself, so i
create this image and run as sidecar in mysql server and mount the volume and
any related thing with the mysql server.


## How to use

1. Create secret to be used by the sidecar, see mysql-backup-percona-secret.yaml
   for sample. `kubectl -f mysql-backup-percona-secret.yaml apply`

2. Patch the mysql statefulset, see `patch.yaml` as sample.
   `kubectl patch statefulset mysql --type strategic --patch-file patch.yaml`

It will inject a file to `/etc/cron.d/backup.crontab`, this crontab will execute
`backup.sh` script at 00:10, everyday.

`backup.sh` script will do the backup, if there are no base backup (a directory
        at `$BACKUP_PATH/base`) it will do full backup, otherwise it will do
incremental backup at `$BACKUP_PATH/<date +%Y-%m-%d-%s>`.


## Sync the backup

If `$RCLONE_CONFIG_FILE` and `$RCLONE_BACKUP_PATH` defined in the pod, it will
sync the backup using rclone[https://rclone.org/]
