# RESPUESTAS DE XAVIER GALLO
1. Diferencia entre Working Directory, Staging Area y Local Repository
•Working Directory: Tu carpeta con los archivos que estás editando.
•Staging Area: La "bandeja" donde pones los cambios que quieres incluir en la foto.
•Local Repository: El álbum permanente (.git) donde se guardan las fotos confirmadas (commits).
•Ejemplo: Editas README.md (Working Directory), haces git add README.md (Staging Area) y haces git commit (Local Repository).
2. Si modificas un archivo y no haces git add, ¿entra en el próximo commit? No. git commit solo guarda lo que hayas subido antes a la Staging Area con git add.
3. ¿Por qué git status no mostraba las carpetas vacías y qué truco se usó? Git solo rastrea archivos, no carpetas vacías. Se solucionó creando un archivo vacío dentro llamado .gitkeep para obligar a Git a registrar la carpeta.
4. ¿Qué es HEAD? Es el marcador o puntero que dice: "estás trabajando exactamente aquí" (en esta rama y en este commit).
5. Diferencia entre rama (git switch -c) y carpeta (mkdir), y comprobación mkdir crea una carpeta física en tu disco. Una rama es solo una línea de tiempo paralela que no crea carpetas. Se comprobó al ver con ls -la que no existía ninguna carpeta nueva y que los archivos en disco cambiaban solos al saltar de una rama a otra con git switch.
6. Marcadores de conflicto en la Parte H
•Entre <<<<<<< HEAD y =======: El texto que ya tenías en la rama donde estás parado (main).
•Entre ======= y >>>>>>>: El texto que viene de la rama que intentas fusionar (fix/readme-subtitle).
7. ¿Por qué NO hacer git commit --amend si ya hiciste push? Porque --amend destruye el commit viejo y crea uno nuevo con otro identificador. Al estar ya subido en GitHub, romperás el historial de los demás compañeros de equipo.
8. Si borras la carpeta .git, ¿qué se pierde y qué pasa con el código? Se pierde todo el historial, las ramas y la configuración de Git. Tus archivos y tu código actual en el disco no se pierden.
9. Diferencia entre Git y GitHub (sin decir "nube")
•Git: El programa que corre en tu ordenador para registrar tus cambios de código.
•GitHub: La página web externa donde guardas una copia de tu proyecto para compartirlo y trabajar con otros.
10. ¿Por qué no subir un .env con claves reales aunque el repo sea privado? Porque queda grabado para siempre en el historial de commits y cualquier persona con acceso al proyecto (o si se hace público por error) podrá ver tus contraseñas.
11. ¿Qué significa el error "non-fast-forward" y qué ejecutas primero? Significa que el repositorio remoto tiene cambios que tú no tienes en tu máquina. Primero ejecutas:
•Bash
•git pull
•Para descargar e integrar esos cambios antes de volver a intentar el push.
12. Tipos de Conventional Commits para cada caso
•Añadir índice de rendimiento: perf
•Corregir restricción mal definida: fix
•Actualizar el README: docs