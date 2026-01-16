import json

# Leer flows.json
with open(r"C:\Users\aitzo\1.KUATRI\PBL\ShelterAI\backend\api-service\node-red-data\flows.json", "r", encoding="utf-8") as f:
    flows = json.load(f)

# Actualizar el nodo 5e41704bfdb79d59 para crear también el registro en refugee
updated = False
for node in flows:
    if node.get("id") == "5e41704bfdb79d59":
        new_func = """// El nodo PostgreSQL devuelve un array con las filas insertadas
// gracias al "RETURNING" que pusimos en la query.
var filas = msg.payload;

if (filas && filas.length > 0) {
    var usuarioNuevo = filas[0];
    
    // Guardar el user_id para crear el registro en refugee
    flow.set('newUserId', usuarioNuevo.id);
    
    // Preparar query para insertar en tabla refugee
    msg.topic = `INSERT INTO refugee (user_id, first_name, last_name, age, gender, nationality, created_at, updated_at) 
                 VALUES ($1, $2, $3, $4, $5, $6, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP) 
                 RETURNING id, user_id`;
    
    msg.params = [
        usuarioNuevo.id,
        usuarioNuevo.first_name,
        usuarioNuevo.last_name,
        usuarioNuevo.age,
        usuarioNuevo.gender,
        usuarioNuevo.username // Usamos username como nacionalidad temporal
    ];
    
    // Guardar usuario nuevo para después
    msg.usuarioNuevo = usuarioNuevo;
    
    console.log('[REGISTER] User created:', usuarioNuevo.id);
    console.log('[REGISTER] Creating refugee record for user:', usuarioNuevo.id);
    
    return [msg, null];
} else {
    // Si por lo que sea no devuelve filas (raro si no dio error antes)
    msg.statusCode = 500;
    msg.payload = { "error": "No se pudo crear el usuario" };
    return [null, msg];
}"""
        
        node["func"] = new_func
        # Cambiar outputs de 1 a 2 (success y error)
        node["outputs"] = 2
        node["wires"] = [["register_create_refugee"], ["register_error_response"]]
        print("✓ Actualizado nodo 5e41704bfdb79d59")
        updated = True
        break

if updated:
    # Agregar nuevo nodo para crear el registro en refugee
    new_nodes = [
        {
            "id": "register_create_refugee",
            "type": "postgresql",
            "z": "tab_login",
            "name": "Create Refugee Record",
            "query": "",
            "postgreSQLConfig": "301245f94e1239d9",
            "split": False,
            "outputs": 1,
            "x": 1150,
            "y": 380,
            "wires": [["register_build_response"]]
        },
        {
            "id": "register_build_response",
            "type": "function",
            "z": "tab_login",
            "name": "Build Response",
            "func": """const refugeeData = msg.payload; // Resultado del INSERT en refugee
const usuarioNuevo = msg.usuarioNuevo;

if (refugeeData && Array.isArray(refugeeData) && refugeeData.length > 0) {
    const refugee = refugeeData[0];
    
    // Respuesta con refugee_id
    msg.statusCode = 201;
    msg.payload = {
        "success": true,
        "user_id": usuarioNuevo.id,
        "refugee_id": refugee.id,  // ← NUEVO: Incluir refugee_id
        "name": usuarioNuevo.full_name || usuarioNuevo.first_name,
        "email": usuarioNuevo.email,
        "role": usuarioNuevo.role,
        "token": "simulated_token_" + Date.now()
    };
    
    console.log('[REGISTER] Refugee registered successfully:', {
        user_id: usuarioNuevo.id,
        refugee_id: refugee.id,
        role: usuarioNuevo.role
    });
} else {
    msg.statusCode = 500;
    msg.payload = { "error": "No se pudo crear el registro de refugiado" };
}

return [msg, null];""",
            "outputs": 2,
            "x": 1350,
            "y": 380,
            "wires": [["register_http_response"], ["register_error_response"]]
        },
        {
            "id": "register_http_response",
            "type": "http response",
            "z": "tab_login",
            "name": "HTTP Response",
            "statusCode": "",
            "headers": {},
            "x": 1550,
            "y": 380,
            "wires": []
        },
        {
            "id": "register_error_response",
            "type": "http response",
            "z": "tab_login",
            "name": "Error Response",
            "statusCode": "500",
            "headers": {},
            "x": 1550,
            "y": 420,
            "wires": []
        }
    ]
    
    # Agregar nodos
    flows.extend(new_nodes)
    
    # Actualizar la referencia de cb383e10764124f8 (el nodo http response anterior)
    # Para que NO sea llamado
    for node in flows:
        if node.get("id") == "cb383e10764124f8":
            # Podemos dejarlo como está, no será usado por el flujo de register
            pass
    
    # Guardar
    with open(r"C:\Users\aitzo\1.KUATRI\PBL\ShelterAI\backend\api-service\node-red-data\flows.json", "w", encoding="utf-8") as f:
        json.dump(flows, f, indent=4, ensure_ascii=False)
        print("✓ Archivo flows.json actualizado correctamente")
        print("✓ Flujo de registro ahora crea usuario Y refugiado con refugee_id")
else:
    print("✗ No se pudo actualizar el nodo de registro")
