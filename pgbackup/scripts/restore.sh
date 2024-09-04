#!/bin/sh

## for pg_dump and pg_restore depends on environment value
## check this available env value from postgres documentation
## https://www.postgresql.org/docs/current/libpq-envars.html#LIBPQ-ENVARS

# exit on error
set -e

OUTPUT_FILE=$1
if test -z "$OUTPUT_FILE"
then
    echo "$0 <backup_file> <dbname>"
    exit 255
fi

if test ! -f "$OUTPUT_FILE"
then
    echo "$OUTPUT_FILE is not a file"
    exit 255
fi

DBNAME=$2

OUTPUT_DIR="/tmp/restore/"
mkdir -p "$OUTPUT_DIR"

echo "Extract start at $(date)"
pigz -p 10 -dc "$OUTPUT_FILE" | tar -C "$OUTPUT_DIR" --strip-components 1 -xf -
echo "Extract start at $(date)"

echo "Restore start at $(date)"
pg_restore -j 10 -Fd -O -d "$DBNAME" "$OUTPUT_DIR/$DBNAME"
echo "Restore start at $(date)"
