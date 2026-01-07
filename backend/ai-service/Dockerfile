FROM python:3.11-slim

# Establecer directorio de trabajo
WORKDIR /app

# Instalar dependencias del sistema necesarias para compilar paquetes de Python
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    gfortran \
    libpq-dev \
    build-essential \
    python3-dev \
    libopenblas-dev \
    liblapack-dev \
    && rm -rf /var/lib/apt/lists/*

# Actualizar pip y setuptools
RUN pip install --upgrade pip setuptools wheel

# Copiar requirements de producción
COPY requirements_prod.txt .

# Instalar dependencias con wheels precompilados si es posible
RUN pip install --no-cache-dir -r requirements_prod.txt

# Copiar código de la aplicación
COPY inference_api/ ./inference_api/
COPY models/ ./models/

# Crear usuario no-root
RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
USER appuser

# Exponer puerto
EXPOSE 8000

# Variable de entorno para Python
ENV PYTHONUNBUFFERED=1

# Comando de inicio
CMD ["python", "-m", "uvicorn", "inference_api.main:app", "--host", "0.0.0.0", "--port", "8000"]
