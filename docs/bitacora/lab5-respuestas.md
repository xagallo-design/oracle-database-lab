# LAB 5 – Oracle DBA Workflow II
## Respuestas, mediciones, anotaciones y conclusiones

**Asignatura:** Administración de Bases de Datos Oracle  
**Proyecto:** Oracle Database Lab  
**Base de datos:** Oracle 26ai – TiendaSur  
**Laboratorio:** Lab 5  
**Rama Git:** `chore/5-oracle-dba-workflow-ii`

---

# 1. Introducción

En este laboratorio se ha trabajado con la administración avanzada de Oracle Database, centrándose en el rendimiento de los índices, la optimización de consultas, la integridad de los datos y los mecanismos de recuperación ante fallos.

Se ha creado un banco de pruebas denominado TiendaSur, compuesto por 100.000 clientes y 1.000.000 de pedidos. A partir de este conjunto de datos se han realizado mediciones de rendimiento, análisis de índices B-tree, pruebas de agrupamiento físico, sargabilidad y costes de escritura.

También se han estudiado los mecanismos internos de Oracle relacionados con SCN, control files, redo logs, ARCHIVELOG, FRA, UNDO, LGWR y DBWn.

Finalmente, se han realizado simulacros de fallos para comprobar la capacidad de recuperación de la base de datos.

# 2. Respuestas a las 22 preguntas

## Pregunta 1. Comparación de las copias lab3-final y lab4-final

La copia de seguridad del Lab 4 demuestra que la reubicación de los datafiles realizada en el laboratorio anterior ha funcionado correctamente.

En la copia `lab4-final`, el paso 6 indica que no existen archivos de la base de datos fuera del volumen Docker.

En cambio, en la copia anterior `lab3-final` aparecían cinco archivos fuera del volumen.

**Conclusión:** la reubicación de los datafiles permite centralizar el almacenamiento de la base de datos dentro del volumen persistente de Docker, facilitando las copias de seguridad, la portabilidad y la recuperación.

**Evidencia:** `evidencia/script/00-backup-lab4.script.log`.

## Pregunta 2. Cálculo del BFR de CLIENTE y PEDIDO

El BFR (Blocking Factor Ratio) representa el número aproximado de filas que caben en un bloque de datos.

Los valores obtenidos son:

- CLIENTE: aproximadamente 68 filas por bloque.
- PEDIDO: aproximadamente 188 filas por bloque.

La fórmula para calcular los bloques necesarios es:

b = ceil(r / BFR)

Donde:
- r representa el número de filas.
- BFR representa las filas por bloque.

PEDIDO permite almacenar casi tres veces más filas por bloque porque sus registros son más pequeños, aproximadamente 32 bytes frente a los 98 bytes de CLIENTE.

**Conclusión:** el tamaño de las filas influye directamente en el aprovechamiento del espacio y en el número de bloques necesarios para almacenar una tabla.

**Evidencia:** Parte B, `evidencia/script/01-*` y sus correspondientes resultados SQL.

## Pregunta 3. ¿Por qué el banco ejecuta cada sentencia dos veces?

El banco de pruebas ejecuta cada sentencia dos veces y mide únicamente la segunda ejecución.

La primera ejecución permite realizar el parseo inicial y cargar información en la caché de Oracle.

La segunda ejecución permite obtener una medición más estable, reduciendo la influencia de las operaciones iniciales de entrada y salida.

**Conclusión:** realizar las mediciones después del calentamiento permite comparar consultas con mayor fiabilidad y reducir el ruido producido por la caché.

**Evidencia:** Parte B, mediciones de `LAB_TOOLS.MEDIR`.

## Pregunta 4. Altura, hojas y fan-out de IX_PED_CLIENTE

Un índice B-tree organiza sus entradas mediante una estructura jerárquica formada por bloques raíz, ramas y hojas.

En el índice `IX_PED_CLIENTE` se debe registrar:

- Altura: [COPIAR VALOR REAL].
- Número de hojas: [COPIAR VALOR REAL].
- Fan-out medio: [COPIAR VALOR REAL].
- Fan-out máximo: [COPIAR VALOR REAL].

La altura aproximada es de tres niveles.

Si la tabla creciera hasta mil millones de filas, la altura aumentaría solamente uno o dos niveles, aproximadamente hasta cuatro, debido al crecimiento logarítmico de los árboles B-tree.

**Conclusión:** los índices B-tree permiten localizar registros de forma eficiente incluso cuando las tablas contienen grandes cantidades de filas.

**Evidencia:** Parte C, `evidencia/script/02-*` y volcados de bloques.

## Pregunta 5. Descomposición del ROWID de PK_CLIENTE

El ROWID permite identificar físicamente una fila dentro de Oracle.

Está compuesto por información que identifica el objeto de datos, el bloque y la posición de la fila dentro del bloque.

En el volcado de una hoja de `PK_CLIENTE` se observa una entrada que contiene el ROWID correspondiente al registro.

Se debe anotar:

- Bloque: [COPIAR BLOQUE DEL VOLCADO].
- Número de fila: [COPIAR POSICIÓN REAL].

No aparece el número de archivo porque el tablespace utilizado es BIGFILE, que dispone de un único datafile.

**Conclusión:** el ROWID permite acceder directamente a la ubicación física de una fila sin tener que recorrer toda la tabla.

**Evidencia:** Parte C, volcado de bloques de `PK_CLIENTE`.

## Pregunta 6. Comparación de los tipos de índices

Durante la Parte D se compararon diferentes tipos de índices mediante mediciones de lecturas lógicas.

Las principales conclusiones son:

1. Índice cubriente frente a índice compuesto: un índice cubriente puede resolver una consulta utilizando directamente la información almacenada en el índice, reduciendo accesos adicionales a la tabla.
2. Bitmap frente a B-tree: los índices bitmap son adecuados para columnas con pocos valores distintos y cargas de trabajo por lotes. Los B-tree son más apropiados para búsquedas selectivas y operaciones frecuentes de modificación.
3. Índice funcional frente a recorrido completo: un índice funcional permite acelerar consultas que utilizan una expresión sobre una columna, siempre que la expresión coincida con la definida en el índice.

Mediciones obtenidas:

- Primera comparación: [LECTURAS LÓGICAS REALES].
- Segunda comparación: [LECTURAS LÓGICAS REALES].
- Tercera comparación: [LECTURAS LÓGICAS REALES].

**Conclusión:** no existe un tipo de índice universalmente mejor. La elección depende de la consulta, la selectividad, el volumen de datos y las operaciones de escritura.

**Evidencia:** Parte D, `evidencia/script/03-*`.

## Pregunta 7. Clustering Factor de IX_PED_FECHA e IX_PED_CLIENTE

El Clustering Factor (CF) mide la relación entre el orden de las entradas de un índice y la distribución física de las filas en los bloques de la tabla.

`IX_PED_FECHA` presenta un CF favorable porque los pedidos se insertaron ordenados por fecha.

Por ello, su CF es aproximadamente igual al número de bloques de la tabla.

`IX_PED_CLIENTE` presenta un CF desfavorable porque los identificadores de cliente están distribuidos aleatoriamente.

En consecuencia, su CF se aproxima al número total de filas.

Un REBUILD no soluciona este problema porque reconstruye el índice, pero no cambia el orden físico de las filas de la tabla.

**Conclusión:** el rendimiento de un índice depende tanto de su estructura como de la organización física de los datos.

**Evidencia:** Parte E, `evidencia/script/04-*`.

## Pregunta 8. Punto de equilibrio de los índices

El punto de equilibrio indica cuándo deja de compensar utilizar un índice frente a realizar un recorrido completo de la tabla.

La fórmula utilizada es:

k/r > (1/BFR) × (c_sec/c_aleat)

Donde:
- k representa las filas recuperadas.
- r representa el total de filas.
- BFR representa las filas por bloque.
- c_sec representa el coste de lectura secuencial.
- c_aleat representa el coste de lectura aleatoria.

En la práctica, cuando el porcentaje de filas recuperadas supera determinado umbral, puede resultar más eficiente realizar un FULL TABLE SCAN.

Resultados de las curvas:

- Índice con CF favorable: [PORCENTAJE REAL].
- Índice con CF desfavorable: [PORCENTAJE REAL].

**Conclusión:** la utilización de un índice no garantiza siempre un mejor rendimiento. El coste depende del número de filas recuperadas y de su distribución física.

**Evidencia:** Parte E, curva de equilibrio.

## Pregunta 9. ¿Por qué Q4b utiliza el índice y aun así lee más bloques?

La consulta Q4b utiliza el índice porque la condición de búsqueda es selectiva.

Sin embargo, aunque recupera aproximadamente el 2,1 % de las filas, puede leer más bloques que un recorrido completo.

Esto sucede porque `IX_PED_CLIENTE` tiene un Clustering Factor desfavorable.

Las filas están distribuidas aleatoriamente por los bloques de la tabla, por lo que Oracle necesita realizar numerosos accesos aleatorios.

**Conclusión:** un índice puede ser utilizado correctamente por el optimizador y aun así ofrecer un rendimiento inferior a un recorrido completo.

**Evidencia:** Parte F, comparación Q4b.

## Pregunta 10. Coste de escritura y selección de índices

Cada índice B-tree añade trabajo de mantenimiento durante las operaciones INSERT, UPDATE y DELETE.

En el laboratorio se comparó el coste de escritura con 4, 9 y 5 índices.

Los resultados reales deben anotarse así:

| Número de índices | Bloques modificados por INSERT |
|---|---|
| 4 índices | [VALOR REAL] |
| 9 índices | [VALOR REAL] |
| 5 índices | [VALOR REAL] |

Cada índice adicional puede provocar modificaciones de bloques adicionales durante las inserciones.

La propuesta de índices se revisó teniendo en cuenta su utilidad, redundancia y coste de mantenimiento.

Se eliminaron:

- `IX_PED_CLIENTE`, porque era redundante al existir un índice cubriente que comenzaba por la misma columna.
- `IX_PED_IMPORTE`, porque no presentaba usos registrados.

Se mantuvieron o crearon los índices necesarios para las consultas del banco de pruebas.

**Conclusión:** añadir índices puede mejorar las consultas, pero también aumenta el coste de las operaciones de escritura y el mantenimiento de la base de datos.

**Evidencia:** Parte G, `evidencia/script/06-*`.

## Pregunta 11. Diferencias entre divisiones 50/50, 90/10 y patrón cola

Se analizaron tres comportamientos diferentes de los índices B-tree.

- División 50/50: se produce normalmente con claves aleatorias. Las entradas se reparten entre las hojas, dejando ambas aproximadamente a medio llenar.
- División 90/10: aparece con claves crecientes. La hoja anterior permanece casi llena y se crea una nueva hoja con las entradas recientes.
- Patrón cola: aparece cuando se insertan registros por un extremo y se eliminan por el otro. Se generan hojas poco ocupadas que permanecen dentro del índice.

**Conclusión:** el patrón de inserción y eliminación influye directamente en el espacio ocupado y en la eficiencia de los índices.

**Evidencia:** Parte H, gráficos `IX_AZAR`, `IX_CRECIENTE`, `IX_INVERTIDA` e `IX_COLA`.

## Pregunta 12. Mejor remedio para el patrón cola

El remedio recomendado para producción durante el horario de servicio es `COALESCE`.

Esta operación reorganiza las hojas del índice y combina espacio disponible sin necesitar reconstruir completamente el índice.

Otras alternativas son:

- `SHRINK SPACE`: permite compactar y recuperar espacio.
- `REBUILD`: reconstruye el índice cuando existe una causa justificada y medida.
- Particionamiento por fecha: permite eliminar particiones completas cuando los datos dejan de ser necesarios.

**Conclusión:** se debe escoger el mantenimiento menos intrusivo que solucione el problema real.

**Evidencia:** Parte H.

## Pregunta 13. Valores que compara Oracle al abrir la base de datos

Oracle compara el SCN del checkpoint registrado en el control file con el SCN de checkpoint de las cabeceras de los datafiles.

Esta comparación permite determinar si los archivos están sincronizados y si es necesaria una recuperación.

El proceso CKPT actualiza la información de checkpoint.

**Conclusión:** el SCN permite controlar la consistencia y el estado de recuperación de la base de datos.

**Evidencia:** Parte I, `evidencia/script/08-*`.

## Pregunta 14. Protección del multiplexado del control file

El control file almacena información fundamental para la base de datos:

- Ubicación de los datafiles.
- Ubicación de los redo logs.
- Información de checkpoints y SCN.
- Información necesaria para montar y recuperar la base de datos.

Multiplexar el control file en tres copias dentro del mismo volumen protege frente a la pérdida o corrupción de una copia individual.

Sin embargo, no protege frente a la pérdida completa del volumen.

En producción, las copias deberían distribuirse en discos, volúmenes o controladoras diferentes.

**Conclusión:** disponer de varias copias del control file aumenta la disponibilidad, pero deben estar físicamente separadas para ofrecer una protección adecuada.

**Evidencia:** Parte J, `evidencia/script/09-*`.

## Pregunta 15. Estados CURRENT, ACTIVE e INACTIVE de los redo logs

Oracle utiliza diferentes estados para controlar los grupos de redo logs.

- CURRENT: grupo donde LGWR está escribiendo actualmente.
- ACTIVE: grupo que todavía puede ser necesario para la recuperación de instancia.
- INACTIVE: grupo que ya no es necesario para la recuperación de instancia.

Oracle impide borrar los grupos en uso o necesarios para la recuperación.

Además, en modo ARCHIVELOG no se puede reutilizar o eliminar un grupo INACTIVE que todavía no se haya archivado correctamente.

**Conclusión:** los redo logs son esenciales para garantizar la recuperación y la durabilidad de las transacciones.

**Evidencia:** Parte K, `evidencia/script/10-*`.

## Pregunta 16. Cadena de consecuencias de una FRA llena

Cuando la Fast Recovery Area (FRA) se llena, se produce una cadena de problemas:

1. Oracle detecta que la FRA ha alcanzado su límite y genera errores como ORA-19815 y ORA-19809.
2. ARCn no puede archivar los redo logs.
3. Los grupos de redo no pueden reutilizarse porque necesitan ser archivados.
4. Se producen esperas como `log file switch (archiving needed)`.
5. Las conexiones nuevas pueden recibir ORA-00257.
6. La base de datos puede dejar de aceptar nuevas operaciones de modificación.

Para solucionar el problema se deben gestionar los archivos de recuperación mediante RMAN y revisar el espacio disponible.

**Conclusión:** la FRA debe dimensionarse y supervisarse correctamente para evitar que el archivado de redo bloquee la actividad de la base de datos.

**Evidencia:** Parte L, `evidencia/script/11-*`.

## Pregunta 17. Lectores no bloquean a escritores

Oracle utiliza UNDO para proporcionar consistencia de lectura.

Durante la prueba:

1. La sesión A realiza un UPDATE sin confirmar.
2. La sesión B consulta el mismo registro.
3. La sesión B obtiene el valor anterior confirmado utilizando la información almacenada en UNDO.
4. La sesión B no necesita esperar a que la sesión A confirme la transacción.

Esto permite que las consultas lean una versión consistente de los datos mientras existen modificaciones pendientes.

**Conclusión:** el mecanismo de consistencia multiversión de Oracle permite que lectores y escritores trabajen simultáneamente sin bloquearse innecesariamente.

**Evidencia:** Parte M, `evidencia/script/12-*`.

## Pregunta 18. ¿Por qué DELETE genera más UNDO que INSERT y por qué ROLLBACK genera REDO?

Un DELETE necesita guardar en UNDO la información de la fila eliminada para poder reconstruirla si es necesario.

Por este motivo, normalmente genera más UNDO que un INSERT.

Un ROLLBACK también genera REDO porque modifica bloques de datos y bloques de UNDO para deshacer los cambios.

Estas modificaciones deben poder recuperarse si ocurre una caída.

**Conclusión:** UNDO y REDO trabajan conjuntamente para garantizar la consistencia y recuperación de las transacciones.

**Evidencia:** Parte M, `12-undo-y-redo.sql`.

## Pregunta 19. ¿Dónde está la garantía de durabilidad después del COMMIT?

Cuando una transacción ejecuta COMMIT, LGWR escribe los registros de REDO correspondientes en el redo log online.

La confirmación de la transacción depende de que ese REDO quede almacenado de forma persistente.

No es necesario que DBWn haya escrito previamente los bloques modificados en los datafiles.

Después del checkpoint, DBWn también habrá escrito los bloques sucios en los datafiles.

**Conclusión:** REDO garantiza la durabilidad de las transacciones confirmadas y los checkpoints permiten sincronizar progresivamente los datafiles con la información registrada.

**Evidencia:** Parte N, `evidencia/script/13-*`.

## Pregunta 20. Simulacro A: caída de instancia

En el simulacro A se provocó una caída de instancia mediante `SHUTDOWN ABORT`.

Al reiniciar Oracle, se realizó una recuperación de instancia.

El proceso consistió en:

- Roll forward: aplicar los registros REDO necesarios para recuperar los cambios.
- Roll back: deshacer las transacciones que no habían sido confirmadas.

La fila 102, que estaba confirmada, sobrevivió a la caída.

La fila 103, que no estaba confirmada, fue deshecha.

**Conclusión:** Oracle puede recuperar automáticamente los cambios confirmados y deshacer las operaciones incompletas después de una caída de instancia.

**Evidencia:** Parte O, simulacro A, `evidencia/script/14a-*` y alert log.

## Pregunta 21. RTO y RPO de los simulacros C y D

En el simulacro C se produjo la eliminación de una tabla mediante DROP TABLE.

La recuperación dependió de la posibilidad de utilizar Flashback Table o de restaurar una copia completa.

En el simulacro D se simuló la pérdida de un datafile. Oracle permitió restaurar el archivo afectado mediante RMAN y aplicar el REDO archivado.

Resultados:

| Simulacro | RTO | RPO | Mecanismo |
|---|---|---|---|
| C | [TIEMPO REAL] | [TIEMPO REAL] | Restauración de copia completa |
| D | [TIEMPO REAL] | 0 | RMAN RESTORE + RECOVER |

El RTO del simulacro C es considerablemente mayor porque implica restaurar una copia completa y recuperar el estado de la base de datos.

En el simulacro D solo es necesario recuperar el datafile afectado y aplicar los redo archivados.

**Conclusión:** la recuperación de un archivo individual suele ser mucho más rápida y permite conservar los cambios confirmados mediante la aplicación del REDO.

**Evidencia:** Parte O, `14c-simulacro-restauracion` y `14d-perdida-datafile`.

## Pregunta 22. Clasificación de errores ORA- del healthcheck

Los errores ORA- detectados durante el healthcheck deben clasificarse según su origen y efecto.

Se distinguen tres categorías:

1. Incidente real: error que indica un problema actual de configuración, disponibilidad, almacenamiento o integridad.
2. Efecto del laboratorio: error producido intencionadamente durante los simulacros de recuperación, como la pérdida temporal de un control file o datafile.
3. Ruido conocido: mensajes como ORA-00800 y ORA-20013, identificados en el guion del laboratorio como mensajes conocidos que no deben confundirse automáticamente con un incidente real.

La clasificación definitiva debe realizarse utilizando los mensajes concretos registrados en el bloque 5 del healthcheck.

**Conclusión:** no todos los errores ORA- indican una avería activa. Es necesario interpretar el contexto, consultar el alert log y comprobar el estado real de la base de datos.

**Evidencia:** Parte P, `evidencia/spool/15-healthcheck.spool.log`.

---

# 3. Tabla de resultados de los simulacros

Los valores de RTO y RPO deben obtenerse de los registros generados durante la ejecución.

| Simulacro | Tipo de fallo | Resultado esperado | RTO | RPO |
|---|---|---|---|---|
| A | Caída de instancia | Recuperación automática | [REAL] | [REAL] |
| B | Pérdida de control file | Recuperación mediante copia sana | [REAL] | [REAL] |
| C | DROP TABLE | Recuperación de tabla o restauración | [REAL] | [REAL] |
| D | Pérdida de datafile | RMAN RESTORE + RECOVER | [REAL] | 0 |

# 4. Anotaciones y aprendizajes

Durante el desarrollo del laboratorio se han obtenido los siguientes aprendizajes:

- Los índices deben diseñarse según las consultas reales y no simplemente por la existencia de columnas utilizadas en filtros.
- El Clustering Factor influye directamente en el coste de los accesos mediante índices.
- Un índice puede resultar contraproducente si obliga a realizar demasiadas lecturas aleatorias.
- El mantenimiento de índices tiene un coste que debe considerarse en las operaciones de escritura.
- El optimizador de Oracle necesita estadísticas adecuadas para elegir correctamente los planes de ejecución.
- UNDO permite mantener la consistencia de lectura y deshacer transacciones.
- REDO permite recuperar cambios confirmados.
- El control file y los redo logs son componentes fundamentales para la recuperación.
- ARCHIVELOG y FRA permiten conservar información necesaria para recuperar la base de datos.
- RMAN facilita la restauración y recuperación de archivos dañados o perdidos.
- Los simulacros permiten comprobar si los mecanismos de recuperación funcionan realmente.

# 5. Retrospectiva de los simulacros

## ¿Qué ha funcionado correctamente?

Los mecanismos de recuperación de Oracle permiten recuperar la información confirmada después de una caída de instancia y restaurar archivos afectados utilizando copias de seguridad y REDO.

La multiplexación de los control files permite continuar trabajando cuando una de sus copias deja de estar disponible.

La configuración ARCHIVELOG permite utilizar los redo archivados para recuperar los datafiles.

## ¿Qué ha resultado más sorprendente?

Uno de los aspectos más importantes ha sido comprobar que Oracle no necesita escribir inmediatamente los bloques modificados en los datafiles para confirmar una transacción.

La garantía de durabilidad se consigue mediante la escritura del REDO por parte de LGWR.

También resulta importante comprobar que recuperar un único datafile puede ser mucho más rápido que restaurar una copia completa de la base de datos.

## ¿Qué mejoraría en una instalación real?

En un entorno de producción aplicaría las siguientes mejoras:

1. Distribuir las copias de los control files en dispositivos físicos diferentes.
2. Mantener varios miembros de redo logs en discos independientes.
3. Supervisar continuamente el espacio disponible en la FRA.
4. Automatizar las copias RMAN y comprobar periódicamente su integridad.
5. Programar pruebas de restauración para verificar que las copias son utilizables.
6. Supervisar las consultas lentas y revisar periódicamente los índices.
7. Configurar alertas para detectar problemas de almacenamiento, archivado y recuperación.
8. Documentar los procedimientos de recuperación mediante runbooks.

**Conclusión de la retrospectiva:** la disponibilidad de una base de datos no depende únicamente de tener copias de seguridad, sino también de disponer de procedimientos de recuperación probados, correctamente documentados y medidos.

# 6. Conclusiones generales del Lab 5

El laboratorio ha permitido comprender y aplicar conceptos fundamentales de administración avanzada de Oracle Database.

En primer lugar, se ha comprobado que el diseño correcto de índices mejora el rendimiento de las consultas, pero también introduce costes adicionales en las operaciones de escritura.

En segundo lugar, se ha estudiado cómo la distribución física de los datos, el Clustering Factor y la selectividad influyen en la elección del plan de ejecución.

También se han analizado los mecanismos internos de Oracle responsables de la consistencia y durabilidad de las transacciones, especialmente UNDO, REDO, LGWR, DBWn y CKPT.

Por último, se han realizado pruebas de recuperación que permiten comprender la importancia de los control files multiplexados, los redo logs, ARCHIVELOG, FRA y RMAN.

La principal conclusión es que una administración correcta de Oracle requiere equilibrar rendimiento, seguridad, disponibilidad y capacidad de recuperación.

No basta con que la base de datos funcione correctamente: también debe ser posible recuperar sus datos ante diferentes tipos de fallos.

# 7. Evidencias utilizadas

Las principales evidencias del laboratorio se encuentran en:

`docs/bitacora/lab5/evidencia/`

| Evidencia | Contenido |
|---|---|
| 00 | Copia de seguridad del Lab 4 |
| 01 | Banco TiendaSur y herramienta de medición |
| 02 | Anatomía de índices |
| 03 | Tipos de índices |
| 04 | Clustering Factor y punto de equilibrio |
| 05 | Sargabilidad |
| 06 | Diseño de índices y coste de escritura |
| 07 | Divisiones de hojas y patrón cola |
| 08 | SCN y checkpoints |
| 09 | Multiplexación de control files |
| 10 | Redo logs |
| 11 | ARCHIVELOG y FRA |
| 12 | Consistencia de lectura y UNDO |
| 13 | LGWR y DBWn |
| 14 | Simulacros de recuperación |
| 15 | Healthcheck |
| 16 | Verificación final |

# 8. Verificación final

La entrega se considerará terminada cuando el script de verificación final muestre:

`RESULTADO: TODO OK. Lab 5 listo para entregar.`

También se comprobará que:

- La base de datos contiene 100.000 clientes y 1.000.000 de pedidos.
- Los índices de PEDIDO corresponden a la migración V005.
- Existen tres copias del control file.
- Los grupos de redo tienen dos miembros.
- La base de datos funciona en ARCHIVELOG.
- La FRA está configurada en 4 GB.
- Existen copias RMAN completadas.
- Las filas de comprobación están en estado ACTIVO.
- El esquema LAB5_PRUEBAS ha sido eliminado.
- Todas las evidencias están presentes.
- No se han incluido contraseñas ni archivos sensibles en Git.

**Resultado final:** [PENDIENTE DE VERIFICACIÓN TODO OK]

---

**Fin del documento – Lab 5 Oracle DBA Workflow II.**
