FROM nodered/node-red:latest

# Ejecutar como root para instalar dependencias
USER root

# Copiamos package.json, flows.json y settings a /tmp (temporales)
COPY node-red-data/package.json /tmp/package.json
COPY node-red-data/flows.json /tmp/flows.json
COPY node-red-data/settings.js /tmp/settings.js

# Creamos script de inicialización
RUN echo '#!/bin/sh' > /usr/local/bin/init-nodered.sh && \
    echo 'if [ ! -f /data/.initialized ]; then' >> /usr/local/bin/init-nodered.sh && \
    echo '  echo "Primera inicialización - Copiando archivos..."' >> /usr/local/bin/init-nodered.sh && \
    echo '  cp /tmp/flows.json /data/flows.json' >> /usr/local/bin/init-nodered.sh && \
    echo '  cp /tmp/package.json /data/package.json' >> /usr/local/bin/init-nodered.sh && \
    echo '  cp /tmp/settings.js /data/settings.js' >> /usr/local/bin/init-nodered.sh && \
    echo '  cd /data && npm install --no-audit --no-fund' >> /usr/local/bin/init-nodered.sh && \
    echo '  touch /data/.initialized' >> /usr/local/bin/init-nodered.sh && \
    echo 'fi' >> /usr/local/bin/init-nodered.sh && \
    echo 'chown -R node-red:node-red /data' >> /usr/local/bin/init-nodered.sh && \
    echo 'exec npm start -- --userDir /data' >> /usr/local/bin/init-nodered.sh && \
    chmod +x /usr/local/bin/init-nodered.sh

# Volvemos al usuario por defecto
USER node-red

# Usamos el script de inicialización
CMD ["/usr/local/bin/init-nodered.sh"]
