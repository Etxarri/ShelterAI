import json

# Leer flows.json
with open(r"C:\Users\aitzo\1.KUATRI\PBL\ShelterAI\backend\api-service\node-red-data\flows.json", "r", encoding="utf-8") as f:
    flows = json.load(f)

# Función mejorada con refugee_id asegurado
new_func = """if (!msg.payload || msg.payload.length === 0) {
    msg.statusCode = 404;
    msg.payload = { error: 'Refugiado no encontrado' };
    return [null, msg];
}

const refugee = msg.payload[0];

// Calcular family_size, has_children, children_count
let family_size = refugee.family_id ? 2 : 1;
let has_children = refugee.special_needs && refugee.special_needs.includes('children');
let children_count = has_children ? 1 : 0;

// IMPORTANTE: Incluir refugee_id para persistencia
msg.payload = {
    refugee_id: refugee.id,  // ← CRÍTICO para guardar en recommendation_logs
    first_name: refugee.first_name || 'Unknown',
    last_name: refugee.last_name || 'Unknown',
    age: refugee.age || 25,
    gender: (refugee.gender || 'M').substring(0, 1).toUpperCase(),
    nationality: refugee.nationality || 'Unknown',
    family_size: family_size,
    has_children: has_children,
    children_count: children_count,
    medical_conditions: refugee.medical_conditions || null,
    requires_medical_facilities: !!refugee.medical_conditions,
    languages_spoken: refugee.languages_spoken || 'English',
    vulnerability_score: refugee.vulnerability_score || 5.0,
    has_disability: refugee.has_disability || false,
    special_needs: refugee.special_needs || null
};

// Guardar refugee original para la respuesta
flow.set('originalRefugee', refugee);

console.log('[AI] Calling AI service with refugee_id:', refugee.id);

return [msg, null];"""

# Buscar el nodo con id "check_refugee_exists" y actualizar su función
updated = False
for flow_node in flows:
    if flow_node.get("id") == "check_refugee_exists":
        flow_node["func"] = new_func
        print(f"✓ Actualizado nodo check_refugee_exists con refugee_id")
        updated = True
        break

if not updated:
    print("✗ No se encontró el nodo check_refugee_exists")
else:
    # Guardar el archivo actualizado
    with open(r"C:\Users\aitzo\1.KUATRI\PBL\ShelterAI\backend\api-service\node-red-data\flows.json", "w", encoding="utf-8") as f:
        json.dump(flows, f, indent=4, ensure_ascii=False)
        print("✓ Archivo flows.json actualizado correctamente")
