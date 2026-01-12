// ============================================================================
// COMPLETO: Código Node-RED para endpoint POST /api/login
// ============================================================================
//
// Flujo recomendado en Node-RED:
// 
// HTTP In (POST /api/login)
//         ↓
// Function Node 1: Validación de esquema JSON
//         ↓
// PostgreSQL Node: Ejecutar SELECT
//         ↓
// Function Node 2: Verificar contraseña y devolver role
//         ↓
// HTTP Response
//
// ============================================================================

// ============================================================================
// FUNCTION NODE 1: VALIDACIÓN DE ESQUEMA JSON
// ============================================================================

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
  if (typeof data !== 'object' || data === null) {
    return false;
  }
  
  if (schema.required) {
    for (const field of schema.required) {
      if (!(field in data)) {
        return false;
      }
    }
  }
  
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(data.email)) {
    return false;
  }
  
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

// Preparar para la query SQL
const email = msg.payload.email;
const password = msg.payload.password;

// Guardar password en contexto para verificación posterior
msg.passwordToVerify = password;

// Query para PostgreSQL
msg.topic = 'SELECT id, email, password, full_name, role FROM users WHERE email = $1';
msg.payload = [email];

return msg;

// ============================================================================
// NODE POSTGRESQL: Ejecutar SELECT
// 
// Configurar con:
// - Database: tu_bd
// - Query: Select (leer msg.topic)
// - Usar msg.payload como parámetros
// ============================================================================

// ============================================================================
// FUNCTION NODE 2: VERIFICAR CONTRASEÑA Y DEVOLVER ROLE
// ============================================================================

try {
  const result = msg.payload;
  const passwordFromRequest = msg.passwordToVerify;
  
  // Verificar si el usuario existe
  if (!Array.isArray(result) || result.length === 0) {
    msg.statusCode = 401;
    msg.payload = {
      success: false,
      message: 'Email o contraseña incorrectos'
    };
    return msg;
  }
  
  const user = result[0];
  
  // Comparar contraseña
  // NOTA: En producción usar bcrypt.compare()
  if (user.password !== passwordFromRequest) {
    msg.statusCode = 401;
    msg.payload = {
      success: false,
      message: 'Email o contraseña incorrectos'
    };
    return msg;
  }
  
  // ÉXITO: Credentials válidas
  msg.statusCode = 200;
  msg.payload = {
    success: true,
    user_id: user.id,
    name: user.full_name,
    role: user.role,  // 'worker' o 'refugee'
    token: 'simulated_token_' + Date.now()
  };
  
  return msg;
  
} catch (err) {
  msg.statusCode = 500;
  msg.payload = {
    success: false,
    message: 'Error procesando login'
  };
  return msg;
}

// ============================================================================
// CONFIGURACIÓN DE BASE DE DATOS
// ============================================================================
//
// Crear tabla en PostgreSQL:
//
// CREATE TABLE users (
//   id SERIAL PRIMARY KEY,
//   email VARCHAR(255) UNIQUE NOT NULL,
//   password VARCHAR(255) NOT NULL,
//   full_name VARCHAR(255) NOT NULL,
//   role VARCHAR(50) NOT NULL DEFAULT 'refugee',
//   created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
// );
//
// INSERT INTO users (email, password, full_name, role) VALUES
// ('trabajador@test.com', 'pass123', 'Trabajador Test', 'worker'),
// ('refugiado@test.com', 'pass456', 'Refugiado Test', 'refugee');
//
// ============================================================================
// CONTRATO DE DATOS
// ============================================================================
//
// REQUEST (POST /api/login):
// {
//   "email": "usuario@ejemplo.com",
//   "password": "mi_password"
// }
//
// RESPONSE 200 (EXITOSO):
// {
//   "success": true,
//   "user_id": 1,
//   "name": "Nombre Usuario",
//   "role": "worker",        // <- CRÍTICO: decide navegación en Flutter
//   "token": "simulated_token_123"
// }
//
// RESPONSE 401 (CREDENCIALES INVÁLIDAS):
// {
//   "success": false,
//   "message": "Email o contraseña incorrectos"
// }
//
// RESPONSE 400 (VALIDACIÓN FALLIDA):
// {
//   "success": false,
//   "message": "Validación fallida: email inválido o password vacío"
// }
//
// ============================================================================
// MEJORAS FUTURAS
// ============================================================================
//
// 1. Usar bcrypt para almacenar/comparar passwords:
//    npm install bcryptjs
//    const bcrypt = require('bcryptjs');
//    const hash = bcrypt.hashSync(password, 10); // Para guardar
//    bcrypt.compareSync(password, user.password); // Para comparar
//
// 2. Generar JWT en lugar de tokens simulados:
//    npm install jsonwebtoken
//    const jwt = require('jsonwebtoken');
//    const token = jwt.sign({ userId: user.id }, 'SECRET', { expiresIn: '24h' });
//
// 3. Implementar rate limiting para prevenir ataques de fuerza bruta
//
// 4. Validación más robusta usando librerías como ajv:
//    npm install ajv
//    const Ajv = require('ajv');
//    const ajv = new Ajv();
//    const validate = ajv.compile(jsonSchema);
//
// ============================================================================
