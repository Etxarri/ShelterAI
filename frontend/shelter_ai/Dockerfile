# Etapa 1: Construcción con Flutter
FROM ghcr.io/cirruslabs/flutter:stable AS build

# Habilitar web
RUN flutter config --enable-web

# Directorio de trabajo
WORKDIR /app

# Copiar archivos de configuración primero (mejor caching)
COPY pubspec.* ./
RUN flutter pub get

# Copiar el resto del código
COPY . .

# Construir para web en modo release
RUN flutter build web --release

# Etapa 2: Servidor web ligero
FROM nginx:alpine

# Copiar los archivos compilados de Flutter
COPY --from=build /app/build/web /usr/share/nginx/html

# Exponer puerto 80
EXPOSE 80

# nginx se inicia automáticamente