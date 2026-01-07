/**
 * Node-RED Function Node para procesar respuesta SQL en POST /api/login
 * 
 * Este nodo procesa la respuesta del SELECT SQL:
 * 1. Verifica si el usuario existe
 * 2. Compara contraseña
 * 3. Devuelve role si es correcto
 * 
 * Entrada (msg):
 * - msg.payload: Array con resultado del SELECT
 * - Ejemplo: [{ id: 1, email: "user@test.com", password: "pass123", full_name: "Usuario", role: "worker" }]
 * 
 * Salida si es correcto (200):
 * {
 *   "success": true,
 *   "user_id": 1,
 *   "name": "Usuario",
 *   "role": "worker",
 *   "token": "simulated_token_123"
 * }
 * 
 * Salida si falla (401):
 * {
 *   "success": false,
 *   "message": "Email o contraseña incorrectos"
 * }
 */

try {
  // msg.payload contiene el resultado SQL
  const result = msg.payload;
  
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
  const passwordFromRequest = msg.req.body.password;
  
  // Comparar contraseña (en prototipo es comparación directa)
  // En producción: usar bcrypt.compare()
  if (user.password !== passwordFromRequest) {
    msg.statusCode = 401;
    msg.payload = {
      success: false,
      message: 'Email o contraseña incorrectos'
    };
    return msg;
  }
  
  // ÉXITO: Credentials válidas, devolver role
  msg.statusCode = 200;
  msg.payload = {
    success: true,
    user_id: user.id,
    name: user.full_name,
    role: user.role, // 'worker' o 'refugee'
    token: 'simulated_token_' + Date.now() // Token simulado
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
