#!/usr/bin/env bash
set -euo pipefail

source scripts/deployment/env/00-config.sh
set -a
source config/.env
set +a

: "${ORACLE_PWD:?Falta ORACLE_PWD en config/.env}"
: "${ORDS_PUBLIC_PWD:?Falta ORDS_PUBLIC_PWD en config/.env}"

ORDS="$ORDS_HOME/bin/ords"
BASE="https://download.oracle.com/otn_software/java/ords"

echo "== Java =="
java -version 2>&1 | head -n 1

echo "== Instalación de ORDS =="
if [ ! -x "$ORDS" ]; then
  wget -q -O /tmp/ords-latest.zip "$BASE/ords-latest.zip"
  unzip -q -o /tmp/ords-latest.zip -d "$ORDS_HOME"
fi

"$ORDS" --version

echo "== Configuración de FREEPDB1 =="
if [ -f "$ORDS_CONFIG/databases/default/pool.xml" ]; then
  echo "ORDS ya está configurado; se conserva la configuración existente."
else
  printf '%s\n%s\n' "$ORACLE_PWD" "$ORDS_PUBLIC_PWD" |
    "$ORDS" --config "$ORDS_CONFIG" install \
      --admin-user "SYS AS SYSDBA" \
      --db-hostname localhost \
      --db-port "$PORT_DB" \
      --db-servicename "$SERVICE_PDB" \
      --feature-db-api true \
      --feature-rest-enabled-sql true \
      --feature-sdw true \
      --log-folder "$ORDS_LOGS" \
      --password-stdin
fi

"$ORDS" --config "$ORDS_CONFIG" config set standalone.http.port "$ORDS_PORT"
echo "Instalación de ORDS completada."
