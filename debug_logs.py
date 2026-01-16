#!/usr/bin/env python3
import subprocess
import sys

try:
    # Usar encoding UTF-8 explícitamente
    result = subprocess.run(
        ['docker', 'logs', 'shelterai-ai-service'],
        capture_output=True,
        text=True,
        encoding='utf-8',
        errors='replace'  # Reemplazar caracteres inválidos
    )
    
    print("=== DOCKER LOGS OUTPUT ===\n")
    print(result.stdout)
    
    if result.stderr:
        print("\n=== STDERR ===\n")
        print(result.stderr)
        
    # Guardar a archivo también
    with open('ai_service_logs.txt', 'w', encoding='utf-8') as f:
        f.write(result.stdout)
        if result.stderr:
            f.write("\n\n=== STDERR ===\n")
            f.write(result.stderr)
    
    print("\n✓ Logs guardados en ai_service_logs.txt")
    
except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(1)
