import json

# Leer flows.json
with open(r"C:\Users\aitzo\1.KUATRI\PBL\ShelterAI\backend\api-service\node-red-data\flows.json", "r", encoding="utf-8") as f:
    flows = json.load(f)

# Encontrar el nodo de respuesta de login
updated = False
for node in flows:
    if node.get("name") == "Build Response" and node.get("type") == "function":
        # Verificar que sea el nodo correcto buscando "user_id" en la función
        if "user_id" in node.get("func", ""):
            # Actualizar la función para incluir refugee_id
            new_func = """let response = {
    success: true,
    user_id: msg.user.id,
    refugee_id: msg.user.refugee_id,  // ← NUEVO: Incluir refugee_id
    name: msg.user.name || msg.user.username,
    role: msg.user.role,
    token: msg.token
};

msg.payload = response;
msg.statusCode = 200;

console.log('[LOGIN] User logged in:', {
    user_id: msg.user.id,
    refugee_id: msg.user.refugee_id,
    role: msg.user.role
});

return [msg, null];"""
            
            node["func"] = new_func
            print(f"✓ Nodo de respuesta de login actualizado con refugee_id")
            updated = True
            break

if not updated:
    print("✗ No se encontró el nodo de respuesta de login")
    print("\nBúsqueda alternativa: nodos con 'Build Response'")
    for node in flows:
        if "Build Response" in node.get("name", ""):
            print(f"  - ID: {node.get('id')}, Tipo: {node.get('type')}, Función: {'func' in node}")
else:
    # Guardar el archivo actualizado
    with open(r"C:\Users\aitzo\1.KUATRI\PBL\ShelterAI\backend\api-service\node-red-data\flows.json", "w", encoding="utf-8") as f:
        json.dump(flows, f, indent=4, ensure_ascii=False)
        print("✓ Archivo flows.json actualizado correctamente")
