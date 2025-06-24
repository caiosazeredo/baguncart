#!/usr/bin/env python3
# test_app.py - Testar antes de gerar APK

import mysql.connector
import bcrypt
from datetime import datetime

DB_CONFIG = {
    'host': 'mysql-baguncart-sistemabaguncart-19f5.h.aivencloud.com',
    'port': 12983,
    'database': 'defaultdb',
    'user': 'avnadmin',
    'password': 'AVNS_rFX5xGI3Cb0fQMHWAhZ',
    'ssl_disabled': False,
    'autocommit': True
}

print("🔗 Testando conexão com banco Aiven...")
try:
    connection = mysql.connector.connect(**DB_CONFIG)
    print("✅ Conexão OK!")
    connection.close()
    print("🚀 Pronto para gerar APK!")
except Exception as e:
    print(f"❌ Erro: {e}")
