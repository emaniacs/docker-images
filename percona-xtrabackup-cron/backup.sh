#!/bin/sh


## we need to read all env variable set my manifest
if test ! -f /tmp/backup.environ
then
    tr '\0' '\n' < /proc/1/environ |grep 'BACKUP_\|MYSQL_\|RCLONE_' > /tmp/backup.sh.environ
fi

. /tmp/backup.sh.environ

## exit on error
set -e

log() {
    echo "[$(date)] $0: $@"
}

if test "$1" = "help"
then
    cat<<EOF
    Backup your mysql using percona-xtrabackup
    it will do fullbackup if base backup not exist, otherwise it will do incremental backup

EOF
    exit 0
fi

if test -z "$BACKUP_PATH"
then
    BACKUP_PATH=/tmp/backup
fi
mkdir -p "$BACKUP_PATH"

## this value used by bitnami to set password, we export
if test -n "$MYSQL_ROOT_PASSWORD_FILE"
then
    MYSQL_PASSWORD=$(cat "$MYSQL_ROOT_PASSWORD_FILE")
fi

if test -z "$MYSQL_PASSWORD"
then
    log "No MYSQL_PASSWORD in env, exit now.."
    exit 255
fi

## socket file need by percona-xtrabackup,
## if exist we use it or use bitnami socket if exist
## or left it empty, so percona-xtrabackup will choose it
SOCKET_ARGS=
if test -n "$MYSQL_SOCKET_FILE"
then
    ## TODO: check if $MYSQL_SOCKET_FILE is a socket file
    SOCKET_ARGS="--socket $MYSQL_SOCKET_FILE"
elif test -S "/opt/bitnami/mysql/tmp/mysql.sock"
then
    SOCKET_ARGS="--socket /opt/bitnami/mysql/tmp/mysql.sock"
fi

COMMAND="xtrabackup --backup --compress --user root $SOCKET_ARGS"

## It used for sync to s3
OUTPUT_DIR=

BACKUP_NAME=base
BACKUP_DIR_BASE=$BACKUP_PATH/base

START="$(date)"
if test -d "$BACKUP_DIR_BASE"
then
    # base backup dir exists, we do incremental backup
    BACKUP_NAME="$(date +%Y-%m-%d-%s)"
    OUTPUT_DIR="$BACKUP_PATH/$BACKUP_NAME"

    log "Base backup exist at $BACKUP_DIR_BASE: DO FULL INCREMENTAAL BACKUP"
    log "Running: $COMMAND --incremental-basedir=$BACKUP_DIR_BASE --target-dir=$OUTPUT_DIR -p<password>"
    $COMMAND --incremental-basedir="$BACKUP_DIR_BASE" --target-dir="$OUTPUT_DIR" -p"$MYSQL_PASSWORD"
else
    ## full backup here
    OUTPUT_DIR=$BACKUP_DIR_BASE

    log "No base backup: DO FULL BACKUP FIRST"
    log "Running: $COMMAND --target-dir=$BACKUP_DIR_BASE -p<password>"
    $COMMAND --target-dir="$BACKUP_DIR_BASE" -p"$MYSQL_PASSWORD"
fi

END_BACKUP="$(date)"

RCLONE_BACKUP=n
if test -n "$RCLONE_CONFIG_FILE" -a -n "$RCLONE_BACKUP_PATH"
then
    RCLONE_BACKUP=y
    log "RCLONE_CONFIG_FILE and RCLONE_BACKUP_PATH exist, copy the last backup using rclone"
    log rclone --config "$RCLONE_CONFIG_FILE" copyto -v "$OUTPUT_DIR/" "$RCLONE_BACKUP_PATH/$BACKUP_NAME"
    rclone --config "$RCLONE_CONFIG_FILE" copyto -v "$OUTPUT_DIR/" "$RCLONE_BACKUP_PATH/$BACKUP_NAME"

    ## Remove all incrementabl backup file in the backup, but keep the directory as docs
    if test "$BACKUP_NAME" != "base"
    then
        log Remove incremental backup after sync to s3
        find "$OUTPUT_DIR" -type f -delete
    fi
fi
END_SYNC="$(date)"

log "Backup finished, at $OUTPUT_DIR"
test "$RCLONE_BACKUP" = "y" && log "Rclone $OUTPUT_DIR to $RCLONE_BACKUP_PATH/$BACKUP_NAME"
log "Start at: $START, end backup at: $END_BACKUP, end sync at: $END_SYNC"
