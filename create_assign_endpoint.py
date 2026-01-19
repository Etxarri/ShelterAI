import json

# Leer flows.json
with open(r"C:\Users\aitzo\1.KUATRI\PBL\ShelterAI\backend\api-service\node-red-data\flows.json", "r", encoding="utf-8") as f:
    flows = json.load(f)

# Encontrar y eliminar los nodos del flujo anterior
node_ids_to_remove = [
    "ai_assign_shelter_endpoint",
    "ai_prepare_request", 
    "ai_call_service"
]

flows = [node for node in flows if node.get("id") not in node_ids_to_remove]

# Crear nuevo flujo para asignar shelter
# Encontrar el tab de AI Integration
ai_tab_id = None
for node in flows:
    if node.get("type") == "tab" and node.get("label") == "AI Integration":
        ai_tab_id = node.get("id")
        break

if not ai_tab_id:
    print("✗ No se encontró el tab 'AI Integration'")
    exit(1)

new_nodes = [
    {
        "id": "assign_shelter_http_in",
        "type": "http in",
        "z": ai_tab_id,
        "name": "POST /api/ai/assign-shelter",
        "url": "/api/ai/assign-shelter",
        "method": "post",
        "upload": False,
        "x": 150,
        "y": 800,
        "wires": [["assign_shelter_prepare"]]
    },
    {
        "id": "assign_shelter_prepare",
        "type": "function",
        "z": ai_tab_id,
        "name": "Prepare Update",
        "func": """const { refugee_id, shelter_id } = msg.payload;

if (!refugee_id || !shelter_id) {
    msg.statusCode = 400;
    msg.payload = { error: 'refugee_id y shelter_id son requeridos' };
    return [null, msg];
}

// Preparar query para actualizar refugiado
msg.query = `UPDATE refugee 
             SET assigned_shelter_id = $1, 
                 status = 'assigned',
                 updated_at = NOW()
             WHERE id = $2
             RETURNING id, assigned_shelter_id, status`;

msg.params = [shelter_id, refugee_id];

console.log('[ASSIGN] Updating refugee', refugee_id, 'with shelter', shelter_id);

return [msg, null];""",
        "outputs": 2,
        "x": 400,
        "y": 800,
        "wires": [["assign_shelter_query"], ["assign_shelter_error"]]
    },
    {
        "id": "assign_shelter_query",
        "type": "postgresql",
        "z": ai_tab_id,
        "name": "Update Refugee",
        "query": "",
        "postgreSQLConfig": "301245f94e1239d9",
        "split": False,
        "outputs": 1,
        "x": 650,
        "y": 800,
        "wires": [["assign_shelter_response"]]
    },
    {
        "id": "assign_shelter_response",
        "type": "function",
        "z": ai_tab_id,
        "name": "Format Response",
        "func": """if (!msg.payload || msg.payload.length === 0) {
    msg.statusCode = 404;
    msg.payload = { error: 'Refugiado no encontrado' };
    return [null, msg];
}

const result = msg.payload[0];

msg.statusCode = 200;
msg.payload = {
    success: true,
    refugee_id: result.id,
    assigned_shelter_id: result.assigned_shelter_id,
    status: result.status,
    message: 'Refugiado asignado exitosamente'
};

console.log('[ASSIGN] Refugiado asignado:', result.id, 'Shelter:', result.assigned_shelter_id);

return [msg, null];""",
        "outputs": 2,
        "x": 900,
        "y": 800,
        "wires": [["assign_shelter_http_response"], ["assign_shelter_error"]]
    },
    {
        "id": "assign_shelter_http_response",
        "type": "http response",
        "z": ai_tab_id,
        "name": "Success Response",
        "statusCode": "200",
        "x": 1150,
        "y": 780,
        "wires": []
    },
    {
        "id": "assign_shelter_error",
        "type": "http response",
        "z": ai_tab_id,
        "name": "Error Response",
        "statusCode": "400",
        "x": 1150,
        "y": 820,
        "wires": []
    }
]

flows.extend(new_nodes)

# Guardar
with open(r"C:\Users\aitzo\1.KUATRI\PBL\ShelterAI\backend\api-service\node-red-data\flows.json", "w", encoding="utf-8") as f:
    json.dump(flows, f, indent=4, ensure_ascii=False)
    print("✓ Flujo de assign-shelter creado correctamente")
    print(f"✓ Removidos {len(node_ids_to_remove)} nodos anteriores")
