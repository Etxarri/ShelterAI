import json

# Leer flows.json
with open(r"C:\Users\aitzo\1.KUATRI\PBL\ShelterAI\backend\api-service\node-red-data\flows.json", "r", encoding="utf-8") as f:
    flows = json.load(f)

# Encontrar el nodo login_verify
updated = False
for node in flows:
    if node.get("id") == "login_verify":
        # Nueva función que incluye refugee_id
        new_func = """try {
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
  
  // ÉXITO: Credentials válidas, devolver role + refugee_id
  msg.statusCode = 200;
  msg.payload = {
    success: true,
    user_id: user.id,
    refugee_id: user.refugee_id,  // ← NUEVO: Incluir refugee_id para refugiados
    name: user.full_name,
    email: user.email,
    role: user.role, // 'worker' o 'refugee'
    token: 'simulated_token_' + Date.now()
  };
  
  console.log('[LOGIN] User logged in:', {
    user_id: user.id,
    refugee_id: user.refugee_id,
    role: user.role
  });
  
  // Limpiar datos sensibles
  delete msg.passwordToVerify;
  
  return msg;
  
} catch (err) {
  msg.statusCode = 500;
  msg.payload = {
    success: false,
    message: 'Error procesando login'
  };
  return msg;
}"""
        
        node["func"] = new_func
        print(f"✓ Nodo login_verify actualizado con refugee_id")
        updated = True
        break

if not updated:
    print("✗ No se encontró el nodo login_verify")
else:
    # Guardar el archivo actualizado
    with open(r"C:\Users\aitzo\1.KUATRI\PBL\ShelterAI\backend\api-service\node-red-data\flows.json", "w", encoding="utf-8") as f:
        json.dump(flows, f, indent=4, ensure_ascii=False)
        print("✓ Archivo flows.json actualizado correctamente")
