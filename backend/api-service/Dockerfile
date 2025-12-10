# 1. Usamos la imagen base oficial
FROM nodered/node-red:latest

# 2. Cambiamos a root para tener permisos de instalación global
USER root

# 3. Nos movemos a la carpeta del CÓDIGO de Node-RED (No a la de datos de usuario)
# Instalar aquí hace que el plugin sea parte del núcleo del contenedor.
WORKDIR /usr/src/node-red

# 4. INSTALACIÓN DE PLUGINS (Aquí es donde ocurre la magia)
# Al ponerlo aquí, Docker "hornea" el plugin dentro de la imagen.
# Ya no hace falta Internet al arrancar, ni package.json en /data.
RUN npm install node-red-contrib-postgresql

# (Opcional) Si necesitas más plugins en el futuro, añádelos aquí:
# RUN npm install node-red-dashboard

# 5. Volvemos a la carpeta de datos y al usuario normal por seguridad
WORKDIR /data
USER node-red

# 6. No necesitamos CMD ni scripts raros.
# Usamos el arranque por defecto de Node-RED, que leerá tu carpeta ./node-red-data
# gracias al volumen que definimos en el compose.yaml.