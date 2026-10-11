#!/usr/bin/env bash
set -euo pipefail

source scripts/deployment/env/00-config.sh

set -a
source config/.env
set +a

mkdir -p docs/bitacora/evidencia/spool

echo "== Comprobando contenedor Oracle =="
docker ps --filter "name=$CONT_NAME"

echo
echo "== Comprobando conexión y PDB =="
docker exec -i "$CONT_NAME" sqlplus -s /nolog <<SQL
CONNECT sys/"${ORACLE_PWD}"@//localhost:1521/${SERVICE_PDB} AS SYSDBA
WHENEVER SQLERROR EXIT SQL.SQLCODE
SHOW CON_NAME
EXIT
SQL

echo
echo "La conexión funciona."
echo "No se han ejecutado las migraciones todavía."
echo "Revisa V000 y V001 antes de continuar."
