# Laboratorio 3 — Respuestas de comprobación

## 8.1.1. Docker

### 1. ¿Qué diferencia hay entre una imagen y un contenedor? Usa como ejemplo lo que hiciste en los ejercicios G2 y G4.

Una imagen es una plantilla de solo lectura que contiene lo necesario para crear un entorno.Un contenedor es una instancia creada a partir de esa imagen. En G2 ejecuté `hello-world` y el contenedor terminó después de mostrar el mensaje. En G4 entré en un contenedor Alpine con una terminal y permaneció activo hasta que ejecuté `exit`.

### 2. En el Ejercicio G5 el archivo nota.txt desapareció y en el G6 no. Explica por qué.

En G5 guardé el archivo dentro del sistema de archivos temporal del contenedor. Al borrar ese contenedor, también desapareció el archivo. En G6 guardé el archivo dentro de un volumen de Docker, que es independiente del ciclo de vida del contenedor y conserva los datos aunque se elimine y se cree otro contenedor.

### 3. ¿Qué diferencia hay entre docker ps y docker ps -a, y qué significa STATUS = Exited (0)?

`docker ps` muestra los contenedores que están en ejecución. `docker ps -a` muestra también los detenidos. `Exited (0)` significa que el proceso principal terminó correctamente, sin indicar un error.

### 4. En -p 8181:8181, ¿qué número corresponde a tu equipo y cuál al contenedor? ¿Qué pasaría con -p 80:8080 en el ejercicio de nginx?

En `-p 8181:8181`, el primer número es el puerto del equipo anfitrión y el segundo es el puerto del contenedor. Con `-p 80:8080`, el equipo recibiría las conexiones por el puerto 80 y las enviaría al puerto 8080 del contenedor. Si Nginx escucha en otro puerto, como el 80, la página no respondería por ese mapeo.

### 5. ¿Por qué un contenedor de Oracle se queda en marcha y el de hello-world termina solo?

Oracle ejecuta un proceso de base de datos que permanece activo esperando conexiones. `hello-world` solo ejecuta un programa que muestra un mensaje y termina; cuando acaba el proceso principal, el contenedor también termina.

### 6. ¿Qué es el digest de una imagen y por qué lo registramos si ya sabemos que usamos :latest?

El digest es una identificación basada en el contenido de una imagen, normalmente expresada mediante un hash SHA-256. La etiqueta `latest` puede apuntar a versiones diferentes en distintos momentos. Registrar el digest permite identificar con precisión la imagen utilizada y mejorar la reproducibilidad.

### 7. ¿Qué comando borraría realmente los datos de Oracle? ¿Por qué docker rm oralab-26ai no lo hace?

Eliminar el volumen persistente de Oracle, por ejemplo con `docker volume rm oralab-26ai-data`, borraría los datos almacenados en ese volumen. `docker rm oralab-26ai` elimina el contenedor, pero no elimina automáticamente el volumen nombrado que contiene los datos persistentes.

## 8.1.2. Git, organización y evidencia

### 8. ¿Por qué este laboratorio se hace dentro del repositorio oracle-database-lab, con Issue, branch y Pull Request, en vez de en una carpeta aparte?

Porque así el trabajo queda organizado, versionado y relacionado con una tarea concreta. La rama permite trabajar sin modificar directamente `main`, y el Pull Request facilita la revisión de los cambios y de las evidencias antes de fusionarlos.

### 9. ¿Qué diferencia hay entre source 00-config.sh y bash 00-config.sh? ¿Por qué usamos source?

`source 00-config.sh` ejecuta el archivo en la terminal actual y deja disponibles sus variables y funciones. `bash 00-config.sh` lo ejecuta en un proceso hijo, por lo que sus variables no permanecen en la terminal al terminar. Usamos `source` para reutilizar las constantes de configuración en los comandos posteriores.

### 10. Explica cada parte del nombre 20260915T091230Z_02-docker.script.log.

`20260915` es la fecha, `T` separa la fecha de la hora, `091230` representa las 09:12:30 y `Z` indica que la hora está en UTC. `_02` identifica el paso número 2, `docker` describe su contenido, `.script.log` indica que es un registro de la terminal.

### 11. ¿Para qué sirve .gitattributes y qué error evita?

`.gitattributes` permite establecer reglas para tratar archivos en Git, incluidos sus finales de línea. Con `eol=lf` para scripts y documentos evitamos diferencias innecesarias entre Windows y Linux y errores como `$'\r': command not found` al ejecutar scripts con finales de línea de Windows.

### 12. ¿Por qué en este Pull Request elegimos Create a merge commit en lugar de Squash and merge?

Porque el merge commit conserva los commits individuales realizados durante las distintas partes del laboratorio y los integra en `main` con un commit de unión. Así se mantiene un historial detallado y trazable, tal como pide la práctica.

## 8.1.3. Seguridad

### 13. Describe las cuatro capas de la estrategia de contraseñas (Parte D) y qué pasaría si te saltas la primera.

Las cuatro capas son:

1. Añadir `config/.env` y `backups/` a `.gitignore` antes de crear el archivo con secretos.
2. Mantener una plantilla `config/.env.example` versionada con valores de ejemplo, nunca con contraseñas reales.
3. Guardar las contraseñas reales en el archivo local `config/.env`, que no se debe subir a Git.
4. Leer las contraseñas de forma segura al ejecutar los comandos, sin escribirlas directamente en ellos.

Si se omite la primera capa, Git podría detectar el archivo real como un archivo normal y terminar incluyéndolo en un commit.

### 14. ¿Por qué no escribimos la contraseña directamente en el comando docker run, aunque el script no se suba a Git?

Porque la contraseña podría quedar expuesta en el historial de la terminal, en la lista de procesos, en registros o en otros mecanismos de diagnóstico. Es más seguro leerla desde una variable protegida y evitar que aparezca en el comando o en la evidencia.

### 15. Si descubres tu contraseña en un commit ya publicado, ¿basta con borrarla en un commit nuevo? ¿Qué debes hacer?

No. El valor seguirá presente en el historial de Git y podría recuperarse desde el commit anterior. Hay que cambiar o revocar inmediatamente la contraseña expuesta, revisar dónde se publicó y seguir el procedimiento para eliminar el secreto del historial cuando corresponda. También se debe comprobar que el secreto no continúe en otros archivos o registros.

## 8.1.4. Oracle y herramientas

### 16. ¿Por qué no usamos SPOOL ni @archivo.sql con sqlplus dentro del contenedor, y qué hicimos en su lugar?

Porque las rutas dentro del contenedor no son las mismas que las rutas del repositorio en Ubuntu, y los archivos creados dentro del contenedor no aparecen automáticamente en el repositorio. En su lugar, ejecutamos SQL*Plus desde el contenedor mediante `docker exec` y redirigimos o canalizamos los archivos y resultados desde el equipo anfitrión para conservar la evidencia en el repositorio.

### 17. ¿Qué hace WHENEVER SQLERROR EXIT SQL.SQLCODE al inicio de V000 y V001, y qué pasaría sin esa línea?

Indica a SQL*Plus que termine la ejecución y devuelva un código de error cuando una instrucción SQL falle. Sin esa línea, el script podría continuar después de un error y dar la impresión de que la migración terminó correctamente aunque algunos objetos no se hubieran creado.

### 18. ¿Qué es una migración y por qué V000 y V001 no se deben editar una vez aplicadas?

Una migración es un archivo versionado que define cambios en la estructura o configuración de la base de datos. `V000` prepara los tablespaces y usuarios y `V001` crea las tablas e índices de los esquemas. No se deben editar después de aplicarlas porque la base de datos ya refleja la versión anterior del archivo. Las modificaciones posteriores deben hacerse mediante una nueva migración.

### 19. ¿Por qué en SQL Developer se usa el servicio FREEPDB1 y no FREE ni un SID?

Porque `FREEPDB1` identifica el servicio de la base de datos conectable (PDB) donde se realizan las actividades del laboratorio. `FREE` corresponde al servicio de la base de datos contenedora y no es el servicio de trabajo indicado para estos ejercicios. Además, la conexión solicitada se configura por nombre de servicio, no mediante un SID.

### 20. ¿Qué aporta SQLcl frente a SQL*Plus, y por qué un DBA debe dominar ambas?

SQLcl ofrece funciones modernas como autocompletado, historial, mejor formato de resultados, gestión de conexiones e integración con Liquibase. SQL*Plus sigue siendo una herramienta clásica disponible en muchos entornos Oracle y servidores. Un DBA debe dominar ambas para poder trabajar tanto con herramientas modernas como con entornos tradicionales.

## 8.1.5. Entorno de trabajo

### 21. ¿Por qué el curso pasa de Git Bash a Ubuntu en WSL 2? Da al menos dos problemas concretos de Git Bash que desaparecen en Ubuntu.

Ubuntu en WSL 2 ofrece un entorno Linux más parecido al que se utiliza en servidores y en despliegues profesionales. Entre los problemas que se evitan están las diferencias en rutas y comandos entre Windows y Linux, y los errores de finales de línea CRLF en scripts Bash. También facilita utilizar herramientas Linux y trabajar con Docker en un entorno coherente con los scripts del laboratorio.

### 22. ¿Por qué clonamos el repositorio en ~/oracle-database-lab y no trabajamos sobre la carpeta de Windows (/mnt/c/...)? ¿Y por qué recomendamos bash frente a zsh para los scripts del curso?

Trabajar en `~/oracle-database-lab` mantiene el repositorio en el sistema de archivos Linux de WSL 2, lo que suele ofrecer mejor rendimiento y menos problemas de permisos, rutas y compatibilidad con herramientas Linux que trabajar bajo `/mnt/c/`. Recomendamos Bash porque es el intérprete previsto por los scripts del curso y tiene una sintaxis ampliamente compatible en entornos Linux. Así se reducen diferencias de comportamiento entre equipos.
