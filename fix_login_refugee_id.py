import json

# Leer flows.json
with open(r"C:\Users\aitzo\1.KUATRI\PBL\ShelterAI\backend\api-service\node-red-data\flows.json", "r", encoding="utf-8") as f:
    flows = json.load(f)

# El flujo debe ser:
# 1. Consultar usuarios para obtener user_id
# 2. Consultar tabla refugee con WHERE user_id = $1 para obtener refugee_id
# 3. Devolver ambos

# Primero, necesito encontrar el nodo login_db_query para ver la estructura
updated = False
for node in flows:
    if node.get("id") == "login_verify":
        # Actualizar la función para buscar el refugee_id
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
  
  // Comparar contraseña
  if (user.password !== passwordFromRequest) {
    msg.statusCode = 401;
    msg.payload = {
      success: false,
      message: 'Email o contraseña incorrectos'
    };
    return msg;
  }
  
  // ÉXITO: Guardar user_id para siguiente query
  msg.user_id = user.id;
  msg.user_full = user;
  
  console.log('[LOGIN] User authenticated:', user.id);
  
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
        print(f"✓ Nodo login_verify actualizado")
        updated = True
        break

if updated:
    # Ahora buscar el nodo login_http_response y agregar un nodo de query antes
    for node in flows:
        if node.get("id") == "login_http_response":
            # Este es el nodo final, necesito agregar uno antes que busque el refugee_id
            print("✓ Encontrado nodo de respuesta HTTP")
            break
    
    # Agregar nodos nuevos para consultar refugee_id
    new_nodes = [
        {
            "id": "login_get_refugee_id_prepare",
            "type": "function",
            "z": "tab_login",
            "name": "Prepare Refugee Query",
            "func": """// Buscar refugee_id usando user_id
msg.topic = "SELECT id as refugee_id FROM refugee WHERE user_id = $1 LIMIT 1";
msg.queryParams = [msg.user_id];
console.log('[LOGIN] Searching refugee with user_id:', msg.user_id);
return msg;""",
            "outputs": 1,
            "x": 1050,
            "y": 80,
            "wires": [["login_get_refugee_id_query"]]
        },
        {
            "id": "login_get_refugee_id_query",
            "type": "postgresql",
            "z": "tab_login",
            "name": "Get Refugee ID",
            "query": "",
            "postgreSQLConfig": "301245f94e1239d9",
            "split": False,
            "outputs": 1,
            "x": 1200,
            "y": 80,
            "wires": [["login_build_final_response"]]
        },
        {
            "id": "login_build_final_response",
            "type": "function",
            "z": "tab_login",
            "name": "Build Final Response",
            "func": """const user = msg.user_full;
let refugee_id = null;

// Si es refugiado, obtener su refugee_id
if (user.role === 'refugee' && msg.payload && Array.isArray(msg.payload) && msg.payload.length > 0) {
    refugee_id = msg.payload[0].refugee_id;
}

msg.statusCode = 200;
msg.payload = {
    success: true,
    user_id: user.id,
    refugee_id: refugee_id,  // null para workers, id para refugees
    name: user.full_name,
    email: user.email,
    role: user.role,
    token: 'simulated_token_' + Date.now()
};

console.log('[LOGIN] Final response:', {
    user_id: user.id,
    refugee_id: refugee_id,
    role: user.role
});

return msg;""",
            "outputs": 1,
            "x": 1350,
            "y": 80,
            "wires": [["login_http_response"]]
        }
    ]
    
    # Agregar los nuevos nodos
    flows.extend(new_nodes)
    
    # Actualizar las conexiones de login_verify para apuntar al nuevo nodo
    for node in flows:
        if node.get("id") == "login_verify":
            node["wires"] = [["login_get_refugee_id_prepare"]]
            node["x"] = 880
            node["y"] = 80
            print("✓ Actualizado login_verify para apuntar a nueva query")
            break
    
    # Actualizar login_http_response para que no tenga conexión entrante anterior
    for node in flows:
        if node.get("id") == "login_http_response":
            node["x"] = 1500
            node["y"] = 80
            print("✓ Posición de login_http_response actualizada")
            break
    
    # Guardar
    with open(r"C:\Users\aitzo\1.KUATRI\PBL\ShelterAI\backend\api-service\node-red-data\flows.json", "w", encoding="utf-8") as f:
        json.dump(flows, f, indent=4, ensure_ascii=False)
        print("✓ Archivo flows.json actualizado correctamente")
else:
    print("✗ No se pudo actualizar el nodo login_verify")
