# Imagen base oficial de Node-RED
FROM nodered/node-red:latest

# Cambiar a root para instalar globalmente
USER root

# Instalar el plugin en la carpeta de Node-RED (no globalmente)
# Esto asegura que Node-RED lo encuentra
WORKDIR /usr/src/node-red
RUN npm install node-red-contrib-postgresql

# NO cambiar WORKDIR al final para no interferir con el ENTRYPOINT relativo

# Volver al usuario node-red
USER node-red

# Heredar el ENTRYPOINT y CMD de la imagen base
# (no necesitamos especificar nada, se heredan automáticamente)


