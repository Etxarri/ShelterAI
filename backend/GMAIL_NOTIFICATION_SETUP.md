# Configuración de Notificaciones Gmail en ShelterAI

## 📧 Correo del Proyecto
**Email:** shelteraitalde6@gmail.com

## 🎯 Objetivo
Enviar un email de notificación automática cuando un **refugiado** inicia sesión en la aplicación, como medida de seguridad y control de acceso.

---

## 🔧 Configuración en Gmail

### Paso 1: Generar Contraseña de Aplicación

Google ya no permite usar la contraseña normal para aplicaciones de terceros. Debes crear una "Contraseña de aplicación":

1. **Inicia sesión** en shelteraitalde6@gmail.com
2. Ve a **Cuenta de Google** → **Seguridad**
3. Activa la **Verificación en dos pasos** (si no la tienes ya)
4. Una vez activada, busca **Contraseñas de aplicaciones**
5. Selecciona:
   - **Aplicación:** Correo
   - **Dispositivo:** Otro (personalizado) → Escribe "Node-RED ShelterAI"
6. Google te dará una **contraseña de 16 caracteres** (sin espacios)
   - **Ejemplo:** `abcd efgh ijkl mnop` → Cópiala como `abcdefghijklmnop`
7. **Guarda esta contraseña**, la necesitarás en Node-RED

---

## ⚙️ Configuración en Node-RED

### Paso 2: Configurar el Nodo de Email

1. **Abre Node-RED** en http://localhost:1880
2. Ve al tab **"Auth API"** (flujo de login)
3. Localiza el nodo **"e-mail"** (de color naranja/amarillo)
4. **Haz doble clic** en el nodo para editar
5. Configura los siguientes campos:

```
To: (lo gestiona el nodo anterior automáticamente)
Server: smtp.gmail.com
Port: 587
Userid: shelteraitalde6@gmail.com
Password: [PEGA AQUÍ LA CONTRASEÑA DE APLICACIÓN DE 16 CARACTERES]
```

6. **Marca las siguientes opciones:**
   - ☑️ Use secure connection (TLS)
   - ⬜ Use Authentication (debería estar marcado por defecto)

7. Haz clic en **"Done"** y luego en **"Deploy"** (botón rojo arriba a la derecha)

---

## 📋 Flujo Actual en Node-RED

El flujo está configurado de la siguiente manera:

```
POST /api/login
    ↓
[Validar y Preparar] ──→ Valida email/password
    ↓
[Consultar Usuario] ──→ Query en PostgreSQL
    ↓
[Verificar y Responder] ──→ Compara password y devuelve role
    ↓
    ├──→ [HTTP Response] ──→ Respuesta al frontend
    │
    └──→ [Preparar Correo] ──→ SOLO si role='refugee'
              ↓
         [e-mail] ──→ Envía notificación
```

### Código del Nodo "Preparar Correo" (actualizado)

El nodo de función filtra por role para enviar solo a refugiados:

```javascript
// Function: Preparar Alerta de Login (SOLO REFUGIADOS)

const user = msg.payload;
const email = user.email;
const role = user.role;

// FILTRO: Solo enviar email si es refugiado
if (role !== 'refugee') {
    return null; // No enviar email a trabajadores
}

// Validación de seguridad
if (!email) {
    node.warn('Login Email: No hay email en el payload');
    return null;
}

const fullName = user.name || 'Usuario';
const time = new Date().toLocaleTimeString();
const date = new Date().toLocaleDateString();

// Configuración para node-red-node-email
msg.to = email;
msg.topic = 'Alerta de Seguridad: Nuevo inicio de sesión - ShelterAI';

// Cuerpo Texto (Fallback)
msg.payload = `Hola ${fullName},
Se ha detectado un nuevo inicio de sesión en tu cuenta de ShelterAI.
Fecha: ${date}
Hora: ${time}

Si no has sido tú, contacta con un administrador inmediatamente.`;

// Cuerpo HTML (Bonito)
msg.html = `
<h3>Hola, ${fullName}</h3>
<p>Se ha detectado un nuevo acceso a tu cuenta.</p>
<div style="background-color: #fff3cd; color: #856404; padding: 15px; border-radius: 5px; border: 1px solid #ffeeba;">
  <strong>🔐 Nuevo Inicio de Sesión</strong><br>
  <ul>
    <li><strong>Fecha:</strong> ${date}</li>
    <li><strong>Hora:</strong> ${time}</li>
  </ul>
</div>
<p>Si has sido tú, puedes ignorar este mensaje.</p>
<p>Si <strong>NO</strong> has sido tú, contacta con un trabajador inmediatamente.</p>
<p style="font-size: 12px; color: #666;">Equipo de Seguridad ShelterAI</p>
`;

return msg;
```

---

## 🧪 Prueba del Sistema

### 1. Crear un usuario refugiado de prueba

Ejecuta en PostgreSQL (si no existe ya):

```sql
INSERT INTO users (email, password, full_name, role) 
VALUES ('refugiado.test@gmail.com', 'test123', 'Refugiado Test', 'refugee');
```

### 2. Probar login desde Flutter

1. Ejecuta la app Flutter: `flutter run -d edge` (o dispositivo)
2. En la pantalla de login, ingresa:
   - **Email:** refugiado.test@gmail.com
   - **Password:** test123
3. Presiona "Iniciar Sesión"

### 3. Verificar que el email se envió

1. **Revisa la bandeja de entrada** de `refugiado.test@gmail.com`
2. Debería llegar un email con asunto:
   ```
   Alerta de Seguridad: Nuevo inicio de sesión - ShelterAI
   ```

### 4. Probar con trabajador (NO debe enviar email)

1. Login con:
   - **Email:** trabajador@test.com
   - **Password:** pass123
2. El login debe funcionar, **pero NO debe enviar email** (es el comportamiento esperado)

---

## 🐛 Troubleshooting

### Error: "Invalid login: 535-5.7.8 Username and Password not accepted"

**Solución:**
- No estás usando la contraseña de aplicación correcta
- Revisa que copiaste los 16 caracteres sin espacios
- Genera una nueva contraseña de aplicación

### Error: "Connection timeout"

**Solución:**
- Verifica que tienes conexión a Internet
- Comprueba que el puerto 587 no está bloqueado por firewall
- Prueba cambiar el puerto a 465 y activar SSL

### El email no llega

**Solución:**
1. Revisa la **carpeta de Spam** del destinatario
2. En Node-RED, abre la pestaña **Debug** (icono de bicho a la derecha)
3. Añade un nodo **Debug** conectado al nodo "Preparar Correo" para ver si llega el mensaje
4. Verifica los logs del contenedor Docker:
   ```powershell
   docker logs nodered-shelterai
   ```

---

## 📝 Notas Importantes

- ✅ **Solo refugiados reciben email** (trabajadores no)
- ✅ El email se envía **después** de la respuesta HTTP (no bloquea el login)
- ✅ Si falla el envío del email, **el login sigue funcionando**
- ⚠️ En producción, considera usar un servicio profesional como SendGrid, Mailgun o AWS SES
- ⚠️ La contraseña de aplicación debe guardarse de forma segura (no compartir en Git)

---

## 🔐 Seguridad de Credenciales

Las credenciales se almacenan cifradas en:
```
backend/api-service/node-red-data/flows_cred.json
```

**NO compartas este archivo** en repositorios públicos. Está en `.gitignore` por seguridad.

---

## 📚 Referencias

- [Node-RED Email Node](https://flows.nodered.org/node/node-red-node-email)
- [Gmail App Passwords](https://support.google.com/accounts/answer/185833)
- [Node-RED Security](https://nodered.org/docs/user-guide/runtime/securing-node-red)
