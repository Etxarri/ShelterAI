/**
 * Node-RED Function Node para POST /api/login
 * 
 * Este nodo gestiona:
 * 1. Validación de esquema JSON (email válido, password no vacío)
 * 2. Consulta a PostgreSQL para verificar credenciales
 * 3. Devolución de role ('worker' o 'refugee') si es correcto
 * 4. Respuesta 401 si falla
 * 
 * Requisitos:
 * - Node: node-red-node-postgres
 * - Base de datos: tabla 'users' con columnas: id, email, password, full_name, role
 * 
 * Entrada esperada (msg.payload):
 * {
 *   "email": "usuario@ejemplo.com",
 *   "password": "mi_password"
 * }
 * 
 * Respuesta si es correcto (200):
 * {
 *   "success": true,
 *   "user_id": 1,
 *   "name": "Nombre Usuario",
 *   "role": "worker",
 *   "token": "simulated_token_123"
 * }
 * 
 * Respuesta si falla (401):
 * {
 *   "success": false,
 *   "message": "Email o contraseña incorrectos"
 * }
 */

// Validar esquema JSON del request
const jsonSchema = {
  type: 'object',
  required: ['email', 'password'],
  properties: {
    email: {
      type: 'string',
      format: 'email'
    },
    password: {
      type: 'string',
      minLength: 1
    }
  }
};

function validateJsonSchema(data, schema) {
  // Validar que sea objeto
  if (typeof data !== 'object' || data === null) {
    return false;
  }
  
  // Validar campos requeridos
  if (schema.required) {
    for (const field of schema.required) {
      if (!(field in data)) {
        return false;
      }
    }
  }
  
  // Validar email format
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(data.email)) {
    return false;
  }
  
  // Validar password no vacío
  if (typeof data.password !== 'string' || data.password.length === 0) {
    return false;
  }
  
  return true;
}

// Validar entrada
if (!validateJsonSchema(msg.payload, jsonSchema)) {
  msg.statusCode = 400;
  msg.payload = {
    success: false,
    message: 'Validación fallida: email inválido o password vacío'
  };
  return msg;
}

// Preparar query SQL para consultar usuario
const email = msg.payload.email;
const password = msg.payload.password;

// PASO 1: Crear nodo SQL query en Node-RED que ejecute:
// SELECT id, email, password, full_name, role FROM users WHERE email = $1

msg.topic = 'SELECT id, email, password, full_name, role FROM users WHERE email = $1';
msg.payload = [email];

// Nota: Este nodo debe estar conectado a un nodo PostgreSQL que devuelve el resultado
// El siguiente paso se hace en otro Function Node que procesa la respuesta SQL

return msg;
