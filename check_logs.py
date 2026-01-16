import subprocess
import sys

result = subprocess.run(['docker', 'logs', 'shelterai-ai-service'], 
                       capture_output=True, text=True)
lines = result.stderr.split('\n') + result.stdout.split('\n')
for line in lines[-100:]:
    print(line)
