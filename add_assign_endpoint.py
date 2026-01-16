import json

with open(r"C:\Users\aitzo\1.KUATRI\PBL\ShelterAI\backend\api-service\node-red-data\flows.json", "r", encoding="utf-8") as f:
    flows = json.load(f)

# Encontrar el tab de AI Integration
ai_tab_id = None
for flow in flows:
    if flow.get("type") == "tab" and flow.get("label") == "AI Integration":
        ai_tab_id = flow.get("id")
        break

if not ai_tab_id:
    print("✗ No se encontró el tab 'AI Integration'")
    exit(1)

# IDs únicos para los nuevos nodos
http_in_id = "assign_shelter_http_in"
function_id = "assign_shelter_function"
postgres_update_id = "assign_shelter_postgres"
http_response_id = "assign_shelter_http_response"

# Nodos nuevos para el endpoint POST /api/ai/assign-shelter
new_nodes = [
    {
        "id": http_in_id,
        "type": "http in",
        "z": ai_tab_id,
        "name": "POST /api/ai/assign-shelter",
        "url": "/api/ai/assign-shelter",
        "method": "post",
        "upload": False,
        "swaggerDoc": "",
        "x": 200,
        "y": 500,
        "wires": [[function_id]]
    },
    {
        "id": function_id,
        "type": "function",
        "z": ai_tab_id,
        "name": "Prepare Update Query",
        "func": """const { refugee_id, shelter_id, recommendation_log_id } = msg.payload;

if (!refugee_id || !shelter_id) {
    msg.statusCode = 400;
    msg.payload = { error: 'refugee_id y shelter_id son requeridos' };
    return [null, msg];
}

// Query para actualizar el refugiado con el shelter asignado
msg.topic = `
    UPDATE refugee 
    SET assigned_shelter_id = $1, 
        status = 'assigned',
        updated_at = NOW()
    WHERE id = $2
    RETURNING id, first_name, last_name, assigned_shelter_id
`;

msg.payload = [shelter_id, refugee_id];

// Guardar para la respuesta
flow.set('refugee_id', refugee_id);
flow.set('shelter_id', shelter_id);
flow.set('recommendation_log_id', recommendation_log_id);

console.log(`[ASSIGN] Assigning shelter ${shelter_id} to refugee ${refugee_id}`);

return [msg, null];""",
        "outputs": 2,
        "noerr": 0,
        "x": 450,
        "y": 500,
        "wires": [[postgres_update_id], [http_response_id]]
    },
    {
        "id": postgres_update_id,
        "type": "postgresql",
        "z": ai_tab_id,
        "name": "Update Refugee",
        "query": "",
        "postgreSQLConfig": "postgres_config",
        "split": False,
        "rowsPerMsg": 1,
        "outputs": 1,
        "x": 700,
        "y": 500,
        "wires": [[http_response_id]]
    },
    {
        "id": http_response_id,
        "type": "http response",
        "z": ai_tab_id,
        "name": "Response",
        "statusCode": "",
        "headers": {},
        "x": 920,
        "y": 500,
        "wires": []
    }
]

# Agregar nodos al flows.json
flows.extend(new_nodes)

# Guardar
with open(r"C:\Users\aitzo\1.KUATRI\PBL\ShelterAI\backend\api-service\node-red-data\flows.json", "w", encoding="utf-8") as f:
    json.dump(flows, f, indent=4, ensure_ascii=False)
    print("✓ Endpoint POST /api/ai/assign-shelter agregado correctamente")