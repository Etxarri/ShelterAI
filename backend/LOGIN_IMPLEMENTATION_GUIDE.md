# Sistema de Login y Autenticación - ShelterAI

## 📋 Resumen

Este documento describe la implementación completa del sistema de autenticación con:
- **Single Entry Point (Login)** para acceso unificado
- **Redirección por rol** (worker → dashboard, refugee → perfil)
- **Backend validado** con Node-RED + PostgreSQL
- **Frontend Flutter** con gestión de estado segura

---

## 🔐 Arquitectura de Autenticación

```
Usuario abre app
    ↓
LoginScreen (always first route)
    ↓
AuthService.login(email, password)
    ↓
POST /api/login → Node-RED
    ↓
Node-RED valida JSON Schema + consulta BD
    ↓
Devuelve { role: 'worker' | 'refugee', ... }
    ↓
Frontend: AuthState.login(role, userId, token, userName)
    ↓
Redirección automática:
- 'worker' → /worker-dashboard
- 'refugee' → /refugee-profile
```

---

## 📱 Frontend (Flutter)

### 1. Estructura de Archivos

```
lib/
├── providers/
│   └── auth_state.dart        # Estado global de autenticación
├── services/
│   └── auth_service.dart      # Lógica de login (HTTP)
└── screens/
    ├── login_screen.dart      # Pantalla de login
    ├── worker_dashboard_screen.dart
    └── refugee_profile_screen.dart
```

### 2. AuthService - Consumir endpoint `/api/login`

```dart
// lib/services/auth_service.dart
static Future<LoginResponse> login({
  required String email,
  required String password,
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email,
      'password': password,
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return LoginResponse.fromJson(data);
  } else if (response.statusCode == 401) {
    throw Exception('Email o contraseña incorrectos');
  }
  throw Exception('Error: ${response.statusCode}');
}
```

### 3. LoginScreen - Validar y Redirigir

```dart
// lib/screens/login_screen.dart
Future<void> _handleLogin() async {
  final response = await AuthService.login(
    email: email,
    password: password,
  );

  final auth = AuthScope.of(context);
  final roleEnum = response.role == 'worker' 
    ? UserRole.worker 
    : UserRole.refugee;

  auth.login(roleEnum, userId: response.userId, ...);

  // REDIRECCIÓN AUTOMÁTICA SEGÚN ROLE
  if (response.role == 'worker') {
    Navigator.pushReplacementNamed(context, '/worker-dashboard');
  } else {
    Navigator.pushReplacementNamed(context, '/refugee-profile');
  }
}
```

### 4. Rutas en main.dart

```dart
// lib/main.dart
initialRoute: '/login',  // SIEMPRE inicia en login
routes: {
  '/login': (context) => const LoginScreen(),
  '/worker-dashboard': (context) => const WorkerDashboardScreen(),
  '/refugee-profile': (context) => const RefugeeProfileScreen(),
  // ... otras rutas
},
```

---

## 🖥️ Backend (Node-RED)

### 1. Tabla PostgreSQL

```sql
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,  -- En producción: bcrypt
  full_name VARCHAR(255) NOT NULL,
  role VARCHAR(50) NOT NULL DEFAULT 'refugee',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Datos de prueba
INSERT INTO users (email, password, full_name, role) VALUES
('trabajador@test.com', 'pass123', 'Trabajador Test', 'worker'),
('refugiado@test.com', 'pass456', 'Refugiado Test', 'refugee');
```

### 2. Flujo en Node-RED

**Crear estos nodos:**

1. **HTTP In** → POST /api/login
2. **Function (Validación)** → Valida JSON Schema
3. **PostgreSQL** → Ejecuta SELECT
4. **Function (Verificación)** → Compara password + devuelve role
5. **HTTP Response** → Devuelve JSON

### 3. Function Node 1: Validación de Esquema

```javascript
// Validar email + password según JSON Schema
const jsonSchema = {
  type: 'object',
  required: ['email', 'password'],
  properties: {
    email: { type: 'string', format: 'email' },
    password: { type: 'string', minLength: 1 }
  }
};

function validateJsonSchema(data, schema) {
  if (typeof data !== 'object' || data === null) return false;
  
  for (const field of schema.required) {
    if (!(field in data)) return false;
  }
  
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(data.email)) return false;
  
  if (typeof data.password !== 'string' || data.password.length === 0) 
    return false;
  
  return true;
}

if (!validateJsonSchema(msg.payload, jsonSchema)) {
  msg.statusCode = 400;
  msg.payload = { success: false, message: 'Validación fallida' };
  return msg;
}

// Preparar query SQL
msg.topic = 'SELECT id, email, password, full_name, role FROM users WHERE email = $1';
msg.payload = [msg.payload.email];
msg.passwordToVerify = msg.req.body.password;

return msg;
```

### 4. PostgreSQL Node

**Configuración:**
- **Type:** Select
- **Query:** Use msg.topic
- **Output:** Mensaje con resultado en msg.payload

### 5. Function Node 2: Verificación y Role

```javascript
try {
  const result = msg.payload;
  const passwordFromRequest = msg.passwordToVerify;
  
  // Usuario no existe
  if (!Array.isArray(result) || result.length === 0) {
    msg.statusCode = 401;
    msg.payload = {
      success: false,
      message: 'Email o contraseña incorrectos'
    };
    return msg;
  }
  
  const user = result[0];
  
  // Contraseña no coincide
  if (user.password !== passwordFromRequest) {
    msg.statusCode = 401;
    msg.payload = {
      success: false,
      message: 'Email o contraseña incorrectos'
    };
    return msg;
  }
  
  // ✅ ÉXITO: devolver role
  msg.statusCode = 200;
  msg.payload = {
    success: true,
    user_id: user.id,
    name: user.full_name,
    role: user.role,  // 'worker' o 'refugee' ← CRÍTICO
    token: 'simulated_token_' + Date.now()
  };
  
  return msg;
} catch (err) {
  msg.statusCode = 500;
  msg.payload = { success: false, message: 'Error interno' };
  return msg;
}
```

---

## 📤 Contrato de Datos (JSON)

### REQUEST
```json
{
  "email": "usuario@ejemplo.com",
  "password": "mi_password"
}
```

### RESPONSE 200 ✅
```json
{
  "success": true,
  "user_id": 1,
  "name": "Nombre Usuario",
  "role": "worker",
  "token": "simulated_token_123"
}
```

### RESPONSE 401 ❌
```json
{
  "success": false,
  "message": "Email o contraseña incorrectos"
}
```

### RESPONSE 400 ⚠️
```json
{
  "success": false,
  "message": "Validación fallida: email inválido o password vacío"
}
```

---

## 🧪 Pruebas

### 1. Probar con curl

```bash
# Credenciales correctas (worker)
curl -X POST http://localhost:1880/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"trabajador@test.com","password":"pass123"}'

# Respuesta esperada:
# {"success":true,"user_id":1,"name":"Trabajador Test","role":"worker","token":"..."}

# Credenciales incorrectas
curl -X POST http://localhost:1880/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"trabajador@test.com","password":"wrongpass"}'

# Respuesta esperada:
# {"success":false,"message":"Email o contraseña incorrectos"}
```

### 2. Flujo completo en Flutter

1. Abre la app → LoginScreen
2. Ingresa: `trabajador@test.com` / `pass123`
3. Presiona "Iniciar Sesión"
4. Debe redirigir a `/worker-dashboard`
5. Verifica el nombre en el header

---

## 🔒 Seguridad - Mejoras Futuras

### Inmediatas (Prototipo)
- ✅ Validación de JSON Schema en backend
- ✅ Manejo de errores 401
- ✅ Roles diferenciados

### Corto Plazo (Pre-Producción)
- 🔲 **Bcrypt** para hash de password
  ```javascript
  const bcrypt = require('bcryptjs');
  const hashedPassword = bcrypt.hashSync(password, 10);
  ```

- 🔲 **JWT** en lugar de tokens simulados
  ```javascript
  const jwt = require('jsonwebtoken');
  const token = jwt.sign({ userId: user.id }, 'SECRET', { expiresIn: '24h' });
  ```

- 🔲 **Rate Limiting** para prevenir fuerza bruta

### Largo Plazo (Producción)
- 🔲 2FA (Two-Factor Authentication)
- 🔲 OAuth 2.0
- 🔲 Audit logs
- 🔲 Refresh tokens

---

## 📚 Archivos de Referencia

| Archivo | Descripción |
|---------|-------------|
| `lib/services/auth_service.dart` | POST /login + parseo de role |
| `lib/screens/login_screen.dart` | UI + handleLogin() |
| `lib/providers/auth_state.dart` | Estado global con role + userId |
| `lib/screens/worker_dashboard_screen.dart` | Home para workers |
| `lib/screens/refugee_profile_screen.dart` | Home para refugiados |
| `NODERED_LOGIN_COMPLETE_GUIDE.js` | Código Node-RED completo |

---

## ✅ Checklist de Implementación

- [x] Crear tabla `users` en PostgreSQL
- [x] Implementar `AuthService.login()` en Flutter
- [x] Crear `LoginScreen` con formulario
- [x] Implementar `AuthState` con role
- [x] Crear dashboards por rol
- [x] Function Node de validación en Node-RED
- [x] Function Node de verificación en Node-RED
- [x] Probar flujo completo

---

## 🚀 Próximos Pasos

1. **Actualizar Android Manifest** para permisos de internet (si es necesario)
2. **Cambiar base URL** en `AuthService.baseUrl` según ambiente
3. **Implementar refresh token** para sesiones largas
4. **Agregar logout** en todas las pantallas (ya está en el código)
5. **Testing** con múltiples usuarios

---

**Generado:** Diciembre 2025  
**Proyecto:** ShelterAI  
**Estado:** ✅ Listo para Prototipo
