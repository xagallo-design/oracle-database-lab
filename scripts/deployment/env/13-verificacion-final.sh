#!/usr/bin/env bash
set -euo pipefail

source scripts/deployment/env/00-config.sh
set -a
source config/.env
set +a

echo "== 1. Docker =="
docker version --format 'Cliente {{.Client.Version}} / Motor {{.Server.Version}}'

echo "== 2. Imagen y digest =="
docker images --digests "$IMG"

echo "== 3. Contenedor =="
docker ps -a --filter "name=$CONT_NAME" --format '{{.Names}} {{.Status}} {{.Ports}}'

echo "== 4. Volumen persistente =="
docker volume ls --filter "name=$VOL_NAME"

echo "== 5. Base de datos lista =="
docker logs "$CONT_NAME" 2>&1 | grep -c "DATABASE IS READY TO USE" || true

echo "== 6. Entornos de negocio =="
docker exec -i "$CONT_NAME" sqlplus -s /nolog <<SQL
CONNECT sys/"${ORACLE_PWD}"@//localhost:1521/${SERVICE_PDB} AS SYSDBA
WHENEVER SQLERROR EXIT SQL.SQLCODE
SET PAGESIZE 50
SELECT owner, COUNT(*) AS tablas
FROM dba_tables
WHERE owner IN (
 'ADMIN_ACADEMIA','ADMIN_CLINICA','ADMIN_RETAIL',
 'ADMIN_LOGISTICA','ADMIN_FINTECH'
)
GROUP BY owner
ORDER BY owner;
EXIT
SQL

echo "== 7. Java =="
java -version 2>&1 | head -n 1

echo "== 8. SQLcl =="
sql -version

echo "== 9. Secretos fuera de Git =="
git check-ignore -q config/.env \
  && echo "OK: config/.env está ignorado por Git" \
  || { echo "FALLO: config/.env no está ignorado"; exit 1; }
