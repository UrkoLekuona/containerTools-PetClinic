# Prueba técnica de herramientas de building

En este documento se recoge información sobre los resultados de crear una imagen a partir de la aplicación [Spring Petclinic](https://github.com/spring-projects/spring-petclinic). El README original del proyecto se puede ver [aquí](readme-original.md).

Los valores que se han medido han sido:
* Tiempo necesario para la creación de la primera imagen.
* Tiempo necesario para volver a crear la imagen después de haber cambiado el código.
* Tiempo necesario para volver a crear la imagen después de haber modificado las dependencias (cambio en `pom.xml`).
* Tamaño final de la imagen.
* Número de *layer*s de la imagen.

Todas las pruebas se han realizado en la misma máquina. Hay que puntualizar que la mayor parte del tiempo de compilación de esta aplicación consiste en la descarga de dependencias (si no existen en la caché local), lo que quiere decir que puede que este escenario no sea el más favorable para ciertas herramientas, que puede que se caracterízen por poder paralelizar procesos independientes, por ejemplo.

## Herramientas

### Dockerfile

Dockerfile se refiere al proceso de *building* tradicional de docker: `docker build`. El comando que se ha utilizado es: `docker build . -f Dockerfile_multistage -t petclinic:dockerfile`

### Buildpacks

El comando que se ha utilizado es: `pack build petclinic:buildpacks -B cloudfoundry/cnb:bionic`

### Jib

El comando que se ha utilizado es: `./mvnw clean package jib:dockerBuild`

### Openshitf S2I

El comando que se ha utilizado es: `s2i build --incremental . docker.io/fabric8/s2i-java:3.0-java8 petclinic:s2i`

### Spotify Dockerfile Maven Plugin

El comando que se ha utilizado es: `mv Dockerfile Dockerfile.bak && mv Dockerfile_spotify Dockerfile && ./mvnw clean package dockerfile:build; mv Dockerfile Dockerfile_spotify && mv Dockerfile.bak Dockerfile`

### Fabric7 Docker Maven Plugin

Lo primero que hay que hacer es descomentar del `pom.xml` el plugin 
```
<groupId>io.fabric8</groupId>
<artifactId>docker-maven-plugin</artifactId>
```
El comando que se ha utilizado es: `mv Dockerfile Dockerfile.bak && mv Dockerfile_fabric8 Dockerfile && ./mvnw clean package docker:build > output.txt && date; mv Dockerfile Dockerfile_fabric8 && mv Dockerfile.bak Dockerfile`

### Moby Buildkit

Depende de la versión de Docker, es importante activar las *experimental features* para tener acceso a todas las funcionalidades de Buildkit.

El comando que se ha utilizado es: `docker buildx build . -f Dockerfile_buildkit -t petclinic:buildkit`

### Kaniko

Antes de nada, habrá que generar un fichero llamado `.docker/config.json` que contenga los credenciales de autenticaición del repositorio a donde vayamos a subir la imagen. Lo mejor para esto es leer la [documentación oficial](https://github.com/GoogleContainerTools/kaniko#pushing-to-different-registries). En mi caso, he subido la imagen a Docker Hub, y he utilizado el *script* `kanikoCreds.sh <usuario> <contraseña>` para generar el fichero.

El comando que se ha utilizado es: `` `docker run -v "`pwd`/.docker:/kaniko/.docker" -v "`pwd`:/workspace" gcr.io/kaniko-project/executor:latest --dockerfile /workspace/Dockerfile --destination urkolekuona/petclinic:kaniko --cache=true` ``

## Resultados

| Herramienta | Primer *build* | Cambio en código | Cambio en dependencias | Tamaño de la imagen | Nº de *layer*s |
| :---------- | :------------: | :--------------: | :--------------------: | :-----------------: | :------------: |
| Dockerfile | 10m 49s | 2m 41s | 11m 2s | 174MB | 7 |
| Buildpacks | 11m 22s | 1m 30s | 1m 44s | 268MB | 24 |
| Jib | 12m 15s | 1m 49s | 1m 34s | 254MB | 7 |
| Openshift S2I | 10m 7s | 1m 55s | 2m 2s | 725MB | 26 |
| Spotify Dockerfile Maven Plugin | 11m 17s | 1m 56s | 2m 6s | 254MB | 7 |
| Fabric8 Maven Plugin | 10m 34s | 2m 25s | 1m 48s | 254MB | 7 |
| Moby Buildkit | 10m 41s | 2m 16s | 2m 13s | 254MB | 7 |
| Kaniko | 16m 23s | 7m 31s | 15m 34s | 254MB | 7 |