# Lab 6 · Respuestas

1.

En el registro de diagnóstico aparecen errores ORA-00800 y ORA-65019. Un número de errores no es una alarma por sí solo porque hay que analizar su frecuencia, causa, contexto y si han afectado al funcionamiento de la base de datos.

2.

La ventana de mantenimiento del miércoles comienza a las 22:00 y dura 4 horas, hasta las 02:00 del jueves. Durante ella se ejecutan las tareas automáticas de mantenimiento: recopilación de estadísticas del optimizador, Segment Advisor y SQL Tuning Advisor.

3.

V$SPPARAMETER muestra los valores configurados para el siguiente arranque, mientras que V$PARAMETER muestra los valores que están activos en la instancia. Después de utilizar SCOPE=SPFILE, el cambio aparece en V$SPPARAMETER, pero no se aplica inmediatamente en V$PARAMETER. Sin ejecutar RESET, el valor pendiente se habría aplicado al siguiente reinicio.

4.

RESET fue la opción correcta para db_files porque permitía eliminar el valor personalizado y recuperar el valor predeterminado de Oracle. No habría sido correcto para processes si se necesitaba conservar un valor específico para la instancia, ya que habría eliminado también esa configuración.

5.

Al intentar conectarse a FREEPDB1 cuando estaba cerrada, C##OPS_RO recibió ORA-01109: database not open. La instancia mostraba «Database opened» porque la CDB estaba abierta, pero la PDB FREEPDB1 permanecía en estado MOUNTED. Que la instancia esté abierta no significa que todas las PDB estén abiertas.

6.

La sesión de APP_ACADEMIA tenía SID 62, SPID 2292 y estaba esperando en el evento PL/SQL lock timer. MODULE identificaba el módulo de la aplicación como matriculas, ACTION indicaba cierre-periodo y CLIENT_IDENTIFIER permitía identificar el contexto concreto del cliente. Estos datos aportan más información operativa que USERNAME, que solamente identifica la cuenta de conexión.

7.

Después de CANCEL SQL, la transacción seguía abierta porque únicamente se canceló la llamada SQL en curso. Después de KILL SESSION, la sesión terminó y Oracle deshizo la transacción pendiente. La fila 101 volvió al estado ACTIVO porque el UPDATE que la había modificado no llegó a confirmarse mediante COMMIT.

8.

El valor exacto de COMMON_USER_PREFIX no aparece en el fragmento de evidencia disponible. Este parámetro determina el prefijo obligatorio de las cuentas comunes de la CDB. En la configuración habitual de Oracle, el prefijo es C##, por lo que las cuentas comunes deben comenzar con ese prefijo.

9.

Las tres perspectivas del diccionario muestran información diferente según el usuario y el contenedor desde el que se consulta:

USER_TABLES muestra las tablas propiedad del usuario conectado.

ALL_TABLES muestra las tablas a las que el usuario tiene acceso.

DBA_USERS muestra los usuarios del contenedor actual.

CDB_USERS permite consultar usuarios de los contenedores visibles desde la raíz.

V$DATAFILE muestra los archivos de datos de la instancia y permite relacionarlos con los contenedores.

En la ejecución de C##OPS_RO desde CDB$ROOT aparecieron 37 usuarios en DBA_USERS y 37 usuarios en CDB$ROOT y 47 en FREEPDB1 mediante CDB_USERS. USER_TABLES y ALL_TABLES de ADMIN_ACADEMIA devolvieron 0 filas para esa identidad.

10.

La carga realizó 10 recorridos completos de un millón de filas. Se registraron 53.781 lecturas lógicas en total y 5.378 lecturas lógicas por recorrido. El DB time fue aproximadamente 0,37 segundos y el DB CPU aproximadamente 0,36 segundos. Como ambos valores son muy parecidos, significa que casi todo el tiempo se dedicó a CPU y hubo muy pocas esperas.

11.

El tablespace TBS_ACADEMIA_HIST tenía un límite máximo de 40 MB. El detalle exacto del espacio asignado y libre antes de la carga no aparece en el fragmento disponible. Para generar alertas utilizaría el porcentaje de ocupación respecto al máximo permitido, porque permite anticipar cuándo se alcanzará el límite real del tablespace. Los umbrales configurados fueron 80 % para aviso y 95 % para nivel crítico.

12.

El usuario que insertó fue el usuario que ejecutó la operación, pero quien pagó la cuota fue CARGA_HIST, porque es el propietario del segmento. El error ORA-01950 aparece cuando el propietario no tiene cuota suficiente en el tablespace. Ampliar el tamaño del tablespace no habría solucionado ORA-01536 porque ese error se debe a que el usuario ha superado su cuota, no necesariamente a que el tablespace se haya quedado sin espacio.

13.

La carga reanudable quedó suspendida al alcanzar el límite de espacio o cuota disponible. Oracle permite que la sentencia espere durante el tiempo de espera configurado y que se reanude cuando se soluciona el problema. La duración exacta de la suspensión y la línea concreta del alert log no aparecen en el fragmento de evidencia disponible.

14.

Antes del DELETE había 20.000 filas y 2.944 bloques. Después del DELETE quedaron 2.000 filas, pero el segmento continuó ocupando 2.944 bloques. Después del SHRINK SPACE se redujo a 304 bloques y aproximadamente 2,4 MB. DELETE elimina filas, pero no devuelve automáticamente los extents al tablespace. SHRINK SPACE compacta el segmento y permite liberar los bloques sobrantes.

15.

Los valores del perfil DEFAULT eran:

FAILED_LOGIN_ATTEMPTS: 10.

INACTIVE_ACCOUNT_TIME: 365.

PASSWORD_GRACE_TIME: 7.

PASSWORD_LIFE_TIME: 180.

PASSWORD_LOCK_TIME: 1.

PASSWORD_REUSE_MAX: UNLIMITED.

PASSWORD_REUSE_TIME: UNLIMITED.

PASSWORD_ROLLOVER_TIME: 0.

PASSWORD_VERIFY_FUNCTION: NULL.

Para PRF_PERSONAS se estableció un máximo de 3 intentos fallidos, para bloquear la cuenta ante varios intentos incorrectos, y una longitud mínima de contraseña de 8 caracteres, para mejorar la seguridad. La función de verificación rechazó una contraseña corta con ORA-28003 y ORA-20000.

16.

Ana pudo leer ACA_MATRICULAS porque tenía asignado ROL_SECRETARIA_ACADEMIA, que heredaba ROL_LECTURA_ACADEMIA. Este último tenía el privilegio SELECT ANY TABLE sobre el esquema ADMIN_ACADEMIA. Al intentar modificar la columna NOMBRES recibió ORA-41900 porque su rol solamente permitía actualizar la columna ESTADO de ACA_ESTUDIANTES.

17.

Los cambios de columnas pueden invalidar vistas y funciones dependientes cuando modifican la estructura que utilizan. En el laboratorio se trabajó con ACA_EST_LAB6, V_ACTIVOS_LAB6, V_CONTACTO_LAB6 y F_TOTAL_ACTIVOS_LAB6. La incorporación de una columna nueva no invalidó los objetos porque no rompió las dependencias existentes. Los objetos inválidos se podían recompilar mediante UTL_RECOMP.RECOMP_SERIAL o utlrp.sql.

18.

Duplicar la SGA no garantiza una mejora del DB time. Si el problema no está relacionado con falta de memoria compartida, aumentar la SGA no reduce necesariamente el tiempo de ejecución. El tamaño de PGA recomendado debe determinarse con el PGA Advisor, observando el punto a partir del cual aparecen sobreasignaciones. El umbral numérico concreto de los advisors no aparece en el fragmento de evidencia disponible.

19.

La consulta de la aplicación registró 5.378 lecturas lógicas por recorrido en la medición de deltas. La evidencia de traza o TKPROF debe identificar las lecturas lógicas mediante la estadística de consistent gets y/o db block gets. El número exacto de lecturas lógicas de la traza de sesión no aparece en el fragmento disponible.

20.

Incidente 1: La pantalla de secretaría quedó bloqueada por una sesión de APP_ACADEMIA con SID 62 y SERIAL# 24347. Se identificó el proceso SPID 2292 y el evento PL/SQL lock timer. Primero se ejecutó CANCEL SQL y después KILL SESSION. La validación confirmó que la sesión desapareció y que la fila 101 volvió a ACTIVO por el rollback.

Incidente 2: La aplicación no podía conectarse porque el servicio no estaba disponible y se produjo ORA-12514. La intervención consistió en comprobar el estado de la PDB y del servicio, arrancar el servicio mediante DBMS_SERVICE.START_SERVICE y guardar el estado. La validación se realizó comprobando que el servicio academia_app estuviera disponible.

Incidente 3: ANA_GARCIA quedó bloqueada después de tres intentos fallidos de autenticación. Oracle mostró ORA-28000 y el estado LOCKED(TIMED). Se investigaron los intentos y se desbloqueó la cuenta. La validación final mostró que ANA_GARCIA estaba OPEN.

10. Simulacro de examen 1Z0-182

S1. # B

S2. # C

S3. # B

S4. # A y B

S5. # C

S6. # B

S7. # A

S8. # B

S9. # C

S10. # C

S11. # B

S12. # A y C

S13. # B

S14. # A y C

S15. # A y C

S16. # B

S17. # B

S18. # B

S19. # A y B

S20. # B

S21. # C

S22. # C