from kivy.app import App
from kivy.uix.screenmanager import ScreenManager, Screen
from kivy.uix.boxlayout import BoxLayout
from kivy.uix.popup import Popup
from kivy.uix.label import Label
from kivy.uix.button import Button
from kivy.uix.textinput import TextInput
import mysql.connector

# Configuração do banco
DB_CONFIG = {
    'host': 'mysql-baguncart-sistemabaguncart-19f5.h.aivencloud.com',
    'port': 12983,
    'database': 'defaultdb',
    'user': 'avnadmin',
    'password': 'AVNS_rFX5xGI3Cb0fQMHWAhZ',
    'ssl_disabled': False,
    'autocommit': True
}

# Banco
class Database:
    def __init__(self):
        self.conn = None
    
    def connect(self):
        if not self.conn:
            self.conn = mysql.connector.connect(**DB_CONFIG)
        return self.conn
    
    def query(self, sql, params=None):
        conn = self.connect()
        cursor = conn.cursor(dictionary=True)
        cursor.execute(sql, params or ())
        results = cursor.fetchall()
        cursor.close()
        return results
    
    def execute(self, sql, params=None):
        conn = self.connect()
        cursor = conn.cursor()
        cursor.execute(sql, params or ())
        conn.commit()
        cursor.close()

# Telas
class LoginScreen(Screen):
    def do_login(self):
        cnpj = self.ids.cnpj_input.text
        senha = self.ids.senha_input.text

        if cnpj == "12345678000100" and senha == "admin123":
            self.manager.current = "menu"
        else:
            popup = Popup(title='Erro',
                          content=Label(text='CNPJ ou Senha incorretos!'),
                          size_hint=(0.8, 0.4))
            popup.open()

class MenuScreen(Screen):
    pass

# App principal
class BaguncartApp(App):
    def build(self):
        sm = ScreenManager()
        sm.add_widget(LoginScreen(name='login'))
        sm.add_widget(MenuScreen(name='menu'))
        return sm

if __name__ == '__main__':
    BaguncartApp().run()
