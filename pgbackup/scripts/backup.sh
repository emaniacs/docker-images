#!/bin/sh

## for pg_dump and pg_restore depends on environment value
## check this available env value from postgres documentation
## https://www.postgresql.org/docs/current/libpq-envars.html#LIBPQ-ENVARS

# exit on error
set -e
DBNAME=$1

if test -z "$DBNAME"
then
    echo "$0 <dbname>"
    exit 255
fi

OUTPUT_DIR="/tmp/backup/$DBNAME"
mkdir -p "$OUTPUT_DIR"
OUTPUT_FILE="/tmp/$DBNAME-$(date +%Y-%m-%d).tar.gz"

log() {
    prefix="$1"
    shift
    echo "$prefix($DBNAME): $*"
}

log DUMP "start at $(date)"
pg_dump -Z0 -j 10 -Fd "$DBNAME" -f "$OUTPUT_DIR"
log DUMP "end at $(date)"

log "DUMP SIZE"
du -sh "$OUTPUT_DIR"

log COMPRESS "start at $(date)"
tar -cf - "$OUTPUT_DIR" | pigz > "$OUTPUT_FILE"
log COMPRESS "end at $(date)"

log "Compressed SIZE"
du -sh "$OUTPUT_FILE"
