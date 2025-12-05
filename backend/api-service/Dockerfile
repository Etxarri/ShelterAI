FROM nodered/node-red:latest

# Ejecutar como root para instalar dependencias en /data
USER root

# Copiamos package.json y hacemos la instalación de los nodos
COPY node-red-data/package.json /data/package.json
RUN cd /data && npm install --no-audit --no-fund

# Aseguramos permisos para el usuario node-red
RUN chown -R node-red:root /data

# Volvemos al usuario por defecto
USER node-red

# El CMD/ENTRYPOINT del contenedor base iniciará Node-RED
