#!/usr/bin/env python3
# build_apk.py - Gerar APK

import subprocess
import os

print("📱 Gerando APK do BagunçArt...")
print("⏱️ Isso pode demorar 10-30 minutos na primeira vez...")

try:
    # Build debug APK
    result = subprocess.run(["buildozer", "android", "debug"], 
                          capture_output=True, text=True)
    
    if result.returncode == 0:
        print("✅ APK gerado com sucesso!")
        print("📁 Arquivo: bin/baguncart-1.0.0-arm64-v8a-debug.apk")
        print("📱 Transfira para o celular e instale!")
        print("🏪 Para Play Store: buildozer android release")
    else:
        print("❌ Erro no build:")
        print(result.stderr)

except Exception as e:
    print(f"❌ Erro: {e}")
    print("💡 Certifique-se que buildozer está instalado")
