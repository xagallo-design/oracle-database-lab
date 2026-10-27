# Lab 4 — Respuestas

## Preguntas tipo examen
- **P1: A, D.** SHUTDOWN IMMEDIATE hace checkpoint y cierra limpio: los archivos son consistentes, no necesitan redo y se abren con STARTUP. No exige ARCHIVELOG ni RMAN.
- **P2: B.** Sin Enterprise no hay MOVE DATAFILE online; se usa OFFLINE, copia del SO, RENAME DATAFILE y ONLINE.
- **P3: A, C.** STARTUP_TIME cambia en cada arranque y CREATED es la creación de la base. El DBID no cambia al recrear el contenedor y v$database funciona desde MOUNT.
- **P4: A, C.** En NOMOUNT solo hay SPFILE y SGA: v$parameter responde y se puede CREATE CONTROLFILE. dba_users, ARCHIVELOG y renombrar SYSTEM exigen MOUNT/OPEN.
- **P5: B.** ALTER DATABASE ARCHIVELOG se ejecuta en MOUNT.
- **P6: B.** Con SPFILE, el SCOPE por defecto es BOTH.
- **P7: C.** PROCESSES es parámetro de instancia: dentro de una PDB falla con ORA-65040.
- **P8: A, C.** STARTUP PFILE=... con la copia buena y CREATE SPFILE FROM PFILE para reparar el SPFILE.
- **P9: B.** Con MEMORY_TARGET=0 y SGA_TARGET>0 es ASMM; un parámetro fijado (DB_CACHE_SIZE) actúa como mínimo.
- **P10: A, D.** El área de ordenación y la memoria de sesión (servidor dedicado) están en la PGA; shared pool, log buffer y buffer cache están en la SGA.
- **P11: C.** El COMMIT espera a LGWR (redo); DBWn escribe los bloques después.
- **P12: B, D.** PMON y SMON son obligatorios; ARC0, RECO y CJQ0 no lo son siempre.

## Preguntas de comprobación
### Respaldo
1. Consistente porque SHUTDOWN IMMEDIATE hace checkpoint y cierra limpio: todos los datafiles comparten el SCN de checkpoint y no hace falta redo (evidencia 00: "Database closed... instance shut down"). Con la base abierta sería inconsistente y, al estar en NOARCHIVELOG, no se podría recuperar.
2. manifiesto.txt dice qué es la copia (etiqueta, fecha, imagen, commit, tipo); SHA256SUMS guarda la huella de cada archivo. restaurar-estado.sh ejecuta sha256sum --check primero y, si falla, se detiene sin tocar nada.
3. RPO: se pierde todo lo hecho tras <fecha UTC de mi copia>, porque es una copia en frío puntual. RTO: restaurar-estado.sh tardó <X min Y s> (evidencia 00-simulacro) para un volumen de <N MB>.

### Diagnóstico y correcciones
4. V000 usó rutas relativas y db_create_file_dest estaba vacío (sin OMF), así que Oracle los creó en $ORACLE_HOME/dbs, fuera del volumen (evidencia 01, secciones 4 y 5). Habría evitado el problema fijar DB_CREATE_FILE_DEST o usar rutas absolutas.
5. RENAME DATAFILE solo cambia la ruta en el control file; no copia ni mueve nada. Hay que copiar antes con el SO y con el tablespace OFFLINE.
6. V000 ya está aplicada y una migración aplicada es historia (forward-only), por eso se crea V003. Borrar la contraseña del archivo no sirve porque sigue en el historial de Git; invalidarla (NO AUTHENTICATION) la deja inservible (evidencia 04 y prueba ORA-01017).
7. Demuestra que la base sobrevive a docker rm porque sus archivos están en el volumen (evidencia 03). Se hace después de reubicar, o se perderían los datafiles, y después del backup, para tener punto de restauración.

### Instancia y arranque
8. Instancia: <STARTUP_TIME>, <SGA total>, <procesos db_*_FREE / PID>. Base de datos: <DBID>, <CREATED y LOG_MODE>, <datafiles/control files/redo>.
9. NOMOUNT lee el SPFILE (SGA y procesos); MOUNT abre los control files; OPEN abre datafiles y redo. ORA-01507 en NOMOUNT porque v$database lee el control file; ORA-01219 en MOUNT porque el diccionario está en SYSTEM, aún cerrado (evidencia 06).
10. Por el estado guardado (SAVE STATE; dba_pdb_saved_states STATE=OPEN). Si no lo hiciera: ALTER PLUGGABLE DATABASE FREEPDB1 OPEN; y luego SAVE STATE.
11. Ruido conocido, no alerta real. ORA-00800 [Set Priority Failed] es un aviso soft por falta de CAP_SYS_NICE; ORA-20013 DBMS_QOPATCH no puede leer el inventario de parches en un contenedor. Se documentan y se excluyen; cualquier otro ORA- se investiga.

### Parámetros
12. v$parameter es el valor efectivo en memoria; v$spparameter, lo escrito en el SPFILE. Con db_files tras SCOPE=SPFILE: 200 en memoria y 300 en el SPFILE (pendiente); tras RESET: 200 y "no especificado".
13. BOTH cambia memoria y SPFILE a la vez; con SPFILE es el SCOPE por defecto (MEMORY si se arrancó con PFILE). Evidencia: open_cursors 500/500 con comentario.
14. PROCESSES dimensiona estructuras de la SGA que se reservan al arrancar, así que el cambio en memoria da ORA-02095 aunque la metadata diga IMMEDIATE. Se cambia con SCOPE=SPFILE y reinicio.
15. El PFILE es texto legible y se versiona: git diff muestra cambios. Configuration drift es la deriva de la configuración respecto a lo documentado; se detecta comparando fotos (evidencia config: <39> frente a <128> líneas).

### Memoria y procesos
16. ASMM: memory_size=0, memory_target=0 y sga_target=1536M; la PGA va aparte con pga_aggregate_target=512M. db_cache_size=0 significa "sin mínimo fijado".
17. Ronda 1: <247> lógicas / <245> físicas; ronda 2: <247> / <0>. Tasa de acierto = 1 − físicas/lógicas = <100 %> en la ronda 2.
18. Cada proceso cuenta en su RSS la SGA compartida, así que sumarlos multiplica la memoria real. Se usa v$sga + v$pgastat o docker stats.
19. El SPID de LGWR en v$process (<593>) es el PID dentro del contenedor y coincide con /proc; docker top muestra el PID del host (<7225>): son PID namespaces distintos.
20. PMON limpia procesos de usuario caídos (deshace la transacción y libera bloqueos; p. ej., un portátil que se apaga a mitad de un UPDATE). SMON hace la recuperación de instancia al arrancar tras un fallo y limpia segmentos temporales.

### Seguridad
21. Mínimo privilegio: C##OPS_RO solo tiene CREATE SESSION, SET CONTAINER y SELECT_CATALOG_ROLE, así que lee el diccionario y las V$ pero no puede modificar datos, ejecutar DDL, ALTER SYSTEM ni apagar la base. SYSTEM es un DBA con poder total.
22. (1) Contraseñas literales en V000 y en el historial de Git, corregidas con V003 (cuentas sin contraseña). (2) sys/<contraseña> en la línea de comandos de 08 (visible con ps), corregida con autenticación del SO (/ as sysdba). Además, 05 v2 no pasa contraseña al reutilizar el volumen.
