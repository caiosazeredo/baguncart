#!/usr/bin/env python3
# test_baguncart.py - Testes b�sicos

import unittest
import sys
import os

# Adicionar src ao path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

class TestBaguncart(unittest.TestCase):
    """Testes b�sicos do Bagun�Art"""
    
    def test_imports(self):
        """Testar importa��es b�sicas"""
        try:
            import kivy
            import kivymd
            import mysql.connector
            import bcrypt
            self.assertTrue(True)
        except ImportError as e:
            self.fail(f"Erro de importa��o: {e}")
    
    def test_database_config(self):
        """Testar configura��o do banco"""
        from main import DB_CONFIG
        
        required_keys = ['host', 'port', 'database', 'user', 'password']
        for key in required_keys:
            self.assertIn(key, DB_CONFIG)
            self.assertIsNotNone(DB_CONFIG[key])
    
    def test_app_initialization(self):
        """Testar inicializa��o do app"""
        try:
            from main import BaguncartCompleteApp
            app = BaguncartCompleteApp()
            self.assertIsNotNone(app)
        except Exception as e:
            self.fail(f"Erro na inicializa��o: {e}")

if __name__ == '__main__':
    unittest.main()
