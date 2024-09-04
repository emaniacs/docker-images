#!/bin/sh

## check this available env value from postgres documentation
## https://www.postgresql.org/docs/current/libpq-envars.html#LIBPQ-ENVARS
#

## Usage: $0 <dbname> <user>

set -u

cat <<EOF | psql -d "$1"
GRANT SELECT, INSERT, UPDATE, DELETE
ON ALL TABLES IN SCHEMA public 
TO $2;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO $2;
        GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO $2;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO $2;
ALTER DEFAULT PRIVILEGES 
    FOR USER $2
    IN SCHEMA public
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO $2;
EOF
