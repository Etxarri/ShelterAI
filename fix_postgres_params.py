import json

# Leer flows.json
with open(r"C:\Users\aitzo\1.KUATRI\PBL\ShelterAI\backend\api-service\node-red-data\flows.json", "r", encoding="utf-8") as f:
    flows = json.load(f)

# Actualizar el nodo login_get_refugee_id_prepare para usar msg.query
updated1 = False
for node in flows:
    if node.get("id") == "login_get_refugee_id_prepare":
        new_func = """// Buscar refugee_id usando user_id
msg.query = "SELECT id as refugee_id FROM refugee WHERE user_id = $1 LIMIT 1";
msg.params = [msg.user_id];
console.log('[LOGIN] Searching refugee with user_id:', msg.user_id);
return msg;"""
        node["func"] = new_func
        print("✓ Actualizado nodo login_get_refugee_id_prepare")
        updated1 = True
        break

# Actualizar el nodo register_create_refugee para usar msg.query (función de preparación)
updated2 = False
for node in flows:
    if node.get("id") == "5e41704bfdb79d59":
        new_func = """// El nodo PostgreSQL devuelve un array con las filas insertadas
// gracias al "RETURNING" que pusimos en la query.
var filas = msg.payload;

if (filas && filas.length > 0) {
    var usuarioNuevo = filas[0];
    
    // Guardar el user_id para crear el registro en refugee
    flow.set('newUserId', usuarioNuevo.id);
    
    // Preparar query para insertar en tabla refugee - Usar msg.query
    msg.query = `INSERT INTO refugee (user_id, first_name, last_name, age, gender, nationality, created_at, updated_at) 
                 VALUES ($1, $2, $3, $4, $5, $6, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP) 
                 RETURNING id, user_id`;
    
    msg.params = [
        usuarioNuevo.id,
        usuarioNuevo.first_name,
        usuarioNuevo.last_name,
        usuarioNuevo.age,
        usuarioNuevo.gender,
        usuarioNuevo.username
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
        print("✓ Actualizado nodo 5e41704bfdb79d59 para usar msg.query y msg.params")
        updated2 = True
        break

# Guardar si hubo cambios
if updated1 or updated2:
    with open(r"C:\Users\aitzo\1.KUATRI\PBL\ShelterAI\backend\api-service\node-red-data\flows.json", "w", encoding="utf-8") as f:
        json.dump(flows, f, indent=4, ensure_ascii=False)
        print("✓ Archivo flows.json actualizado correctamente")
else:
    print("✗ No se encontraron nodos para actualizar")
