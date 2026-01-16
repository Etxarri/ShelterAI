import json

# Leer flows.json
with open(r"C:\Users\aitzo\1.KUATRI\PBL\ShelterAI\backend\api-service\node-red-data\flows.json", "r", encoding="utf-8") as f:
    flows = json.load(f)

# Actualizar el nodo 9e799a512b71a198 (función de validación y preparación)
# Para que use msg.query y msg.params correctamente
updated = False
for node in flows:
    if node.get("id") == "9e799a512b71a198":
        new_func = """// 1. Extraemos los datos que vienen del formulario (Frontend)
var nombre = msg.payload.first_name;
var apellido = msg.payload.last_name;
var username = msg.payload.username;
var email = msg.payload.email;
var password = msg.payload.password;
var phone = msg.payload.phone_number;
var address = msg.payload.address;
var age = msg.payload.age;
var gender = msg.payload.gender;

// 2. Validación básica de seguridad
if (!username || !password || !nombre || !address || !age) {
    msg.statusCode = 400;
    msg.payload = { error: "Faltan datos: nombre, email o contraseña" };
    return msg;
}

// 3. Preparamos la Query SQL (INSERT) - Usar msg.query
msg.query = "INSERT INTO users (first_name, last_name, username, email, password, phone_number, address, age, gender, role) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10) RETURNING id, first_name, last_name, username, email, password, phone_number, address, age, gender, role";

// 4. Preparamos los parámetros (Array) - Usar msg.params
msg.params = [nombre, apellido, username, email, password, phone, address, age, gender, 'refugee'];

console.log('[REGISTER] Creating user with:', {
    username: username,
    email: email,
    age: age,
    params_count: msg.params.length
});

return msg;"""
        
        node["func"] = new_func
        print("✓ Actualizado nodo 9e799a512b71a198 para usar msg.query y msg.params")
        updated = True
        break

if not updated:
    print("✗ No se encontró el nodo 9e799a512b71a198")
else:
    # Guardar
    with open(r"C:\Users\aitzo\1.KUATRI\PBL\ShelterAI\backend\api-service\node-red-data\flows.json", "w", encoding="utf-8") as f:
        json.dump(flows, f, indent=4, ensure_ascii=False)
        print("✓ Archivo flows.json actualizado correctamente")
