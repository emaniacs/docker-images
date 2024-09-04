#!/bin/sh

## exit on undefined variable
## exit on error
set -ue

ACTION=$1
shift

usage() {
    echo "$0 <action> <dbname>"
    cat <<EOF
Usage: $0 <ACTION> <dbname> [options]
ACTION:
    backup - backup database
    restore - restore database
    help - show this help
EOF
}

case "$ACTION" in
    backup)
        backup.sh "$@"
    ;;
    restore)
        restore.sh "$@"
    ;;
    help)
        usage
        exit 0
    ;;
    *)
        echo "Invalid action: $ACTION"
        usage
        exit 255
    ;;
esac
