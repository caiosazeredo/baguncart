#!/usr/bin/env python3
# main.py - BagunçArt App Final - Exatamente como as imagens

from kivy.app import App
from kivy.uix.screenmanager import ScreenManager, Screen
from kivy.uix.boxlayout import BoxLayout
from kivy.uix.gridlayout import GridLayout
from kivy.uix.label import Label
from kivy.uix.textinput import TextInput
from kivy.uix.button import Button
from kivy.uix.popup import Popup
from kivy.uix.scrollview import ScrollView
from kivy.uix.floatlayout import FloatLayout
from kivy.uix.widget import Widget
from kivy.metrics import dp
from kivy.core.window import Window
from kivy.clock import Clock
from kivy.graphics import Color, Rectangle, RoundedRectangle
import mysql.connector
import bcrypt
import re
from datetime import datetime

# Configuração do banco Aiven
DB_CONFIG = {
    'host': 'mysql-baguncart-sistemabaguncart-19f5.h.aivencloud.com',
    'port': 12983,
    'database': 'defaultdb',
    'user': 'avnadmin',
    'password': 'AVNS_rFX5xGI3Cb0fQMHWAhZ',
    'ssl_disabled': False,
    'autocommit': True
}

# Cores do BagunçArt
COLORS = {
    'primary': (0.545, 0.184, 0.545, 1),  # Roxo #8B2F8B
    'secondary': (1, 0.549, 0, 1),        # Laranja #FF8C00
    'white': (1, 1, 1, 1),
    'light_gray': (0.96, 0.96, 0.96, 1),
    'dark_gray': (0.2, 0.2, 0.2, 1),
    'text_gray': (0.5, 0.5, 0.5, 1)
}

class Database:
    def __init__(self):
        self.connection = None
    
    def connect(self):
        try:
            self.connection = mysql.connector.connect(**DB_CONFIG)
            return True
        except Exception as e:
            print(f"Erro ao conectar: {e}")
            return False
    
    def execute_query(self, query, params=None):
        try:
            cursor = self.connection.cursor(dictionary=True)
            cursor.execute(query, params)
            result = cursor.fetchall()
            cursor.close()
            return result
        except Exception as e:
            print(f"Erro na query: {e}")
            return None
    
    def execute_insert(self, query, params=None):
        try:
            cursor = self.connection.cursor()
            cursor.execute(query, params)
            insert_id = cursor.lastrowid
            cursor.close()
            return insert_id
        except Exception as e:
            print(f"Erro no insert: {e}")
            return None

class CustomTextInput(TextInput):
    def __init__(self, placeholder_text="", **kwargs):
        super().__init__(**kwargs)
        self.placeholder_text = placeholder_text
        self.multiline = False
        self.size_hint_y = None
        self.height = dp(60)
        self.font_size = dp(16)
        self.padding = [dp(20), dp(15)]
        self.background_color = COLORS['light_gray']
        self.foreground_color = COLORS['dark_gray']
        self.cursor_color = COLORS['primary']
        self.hint_text = placeholder_text

class CustomButton(Button):
    def __init__(self, text, bg_color=COLORS['primary'], **kwargs):
        super().__init__(**kwargs)
        self.text = text
        self.background_color = bg_color
        self.color = COLORS['white']
        self.font_size = dp(16)
        self.bold = True
        self.size_hint_y = None
        self.height = dp(60)

class LoginScreen(Screen):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.db = Database()
        self.build_ui()
    
    def build_ui(self):
        main_layout = BoxLayout(orientation='vertical', padding=dp(40), spacing=dp(30))
        
        # Espaçador superior
        main_layout.add_widget(Widget(size_hint_y=None, height=dp(80)))
        
        # Logo BagunçArt
        logo = Label(
            text='BagunçArt',
            font_size=dp(48),
            bold=True,
            color=COLORS['primary'],
            size_hint_y=None,
            height=dp(100),
            halign='center'
        )
        logo.bind(size=logo.setter('text_size'))
        
        # Campos de entrada
        self.cnpj_input = CustomTextInput(placeholder_text="CNPJ")
        self.senha_input = CustomTextInput(placeholder_text="Senha")
        self.senha_input.password = True
        
        # Botão Entrar
        login_btn = CustomButton(
            "Entrar",
            bg_color=COLORS['secondary'],
            size_hint_y=None,
            height=dp(60)
        )
        login_btn.bind(on_press=self.login)
        
        # Esqueceu a senha
        forgot_label = Label(
            text='Esqueceu a senha?',
            color=COLORS['text_gray'],
            font_size=dp(14),
            size_hint_y=None,
            height=dp(40)
        )
        
        # Montagem
        main_layout.add_widget(logo)
        main_layout.add_widget(self.cnpj_input)
        main_layout.add_widget(self.senha_input)
        main_layout.add_widget(login_btn)
        main_layout.add_widget(forgot_label)
        main_layout.add_widget(Widget())  # Espaçador
        
        self.add_widget(main_layout)
    
    def login(self, instance):
        cnpj = re.sub(r'\\D', '', self.cnpj_input.text)
        senha = self.senha_input.text
        
        if not cnpj or not senha:
            self.show_popup('Erro', 'Preencha todos os campos!')
            return
        
        if not self.db.connect():
            self.show_popup('Erro', 'Erro de conexão!')
            return
        
        user = self.authenticate(cnpj, senha)
        if user:
            self.manager.current = 'dashboard'
            self.manager.get_screen('dashboard').set_user(user)
        else:
            self.show_popup('Erro', 'CNPJ ou senha incorretos!')
    
    def authenticate(self, cnpj, senha):
        try:
            result = self.db.execute_query("SELECT * FROM usuarios WHERE cnpj = %s", (cnpj,))
            if result:
                user = result[0]
                stored_password = user['senha']
                if isinstance(stored_password, str):
                    stored_password = stored_password.encode('utf-8')
                
                if bcrypt.checkpw(senha.encode('utf-8'), stored_password):
                    return user
            return None
        except Exception as e:
            print(f"Erro na autenticação: {e}")
            return None
    
    def show_popup(self, title, message):
        popup = Popup(
            title=title,
            content=Label(text=message),
            size_hint=(0.8, 0.4)
        )
        popup.open()

class DashboardScreen(Screen):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.user = None
        self.build_ui()
    
    def set_user(self, user):
        self.user = user
        self.user_label.text = f'👤 {user["nome"]}'
    
    def build_ui(self):
        main_layout = BoxLayout(orientation='vertical', padding=dp(30), spacing=dp(40))
        
        # Logo
        logo = Label(
            text='BagunçArt',
            font_size=dp(40),
            bold=True,
            color=COLORS['primary'],
            size_hint_y=None,
            height=dp(120),
            halign='center'
        )
        logo.bind(size=logo.setter('text_size'))
        
        # User info
        self.user_label = Label(
            text='👤 Administrador',
            font_size=dp(16),
            color=COLORS['dark_gray'],
            size_hint_y=None,
            height=dp(40),
            halign='center'
        )
        self.user_label.bind(size=self.user_label.setter('text_size'))
        
        # Menu Grid
        menu_grid = GridLayout(cols=3, spacing=dp(20), size_hint_y=None)
        menu_grid.bind(minimum_height=menu_grid.setter('height'))
        
        # Botões do menu
        menu_items = [
            ('👥\\nCLIENTES', 'clientes'),
            ('📋\\nCONTRATOS', 'contratos'),
            ('📢\\nPROMOÇÃO', 'promocao'),
            ('👤\\nCADASTRAR\\nCLIENTE', 'cadastro_cliente'),
            ('🔔\\nNOTIFICAÇÃO', 'notificacao'),
            ('', '')  # Espaço vazio
        ]
        
        for text, screen in menu_items:
            if text:
                btn = CustomButton(
                    text,
                    bg_color=COLORS['secondary'],
                    size_hint_y=None,
                    height=dp(120)
                )
                btn.bind(on_press=lambda x, s=screen: self.navigate_to(s))
            else:
                btn = Widget()
            menu_grid.add_widget(btn)
        
        # Montagem
        main_layout.add_widget(logo)
        main_layout.add_widget(self.user_label)
        main_layout.add_widget(menu_grid)
        main_layout.add_widget(Widget())  # Espaçador
        
        self.add_widget(main_layout)
    
    def navigate_to(self, screen_name):
        self.manager.current = screen_name

class ClientesScreen(Screen):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.build_ui()
    
    def build_ui(self):
        main_layout = BoxLayout(orientation='vertical', padding=dp(20), spacing=dp(20))
        
        # Header
        header = BoxLayout(orientation='horizontal', size_hint_y=None, height=dp(60))
        
        back_btn = Button(
            text='<',
            size_hint_x=None,
            width=dp(40),
            font_size=dp(20),
            color=COLORS['primary'],
            background_color=(0, 0, 0, 0)
        )
        back_btn.bind(on_press=lambda x: setattr(self.manager, 'current', 'dashboard'))
        
        title = Label(
            text='CLIENTES',
            font_size=dp(24),
            bold=True,
            color=COLORS['primary'],
            halign='center'
        )
        title.bind(size=title.setter('text_size'))
        
        user_icon = Label(
            text='👤',
            font_size=dp(24),
            size_hint_x=None,
            width=dp(40)
        )
        
        header.add_widget(back_btn)
        header.add_widget(title)
        header.add_widget(user_icon)
        
        # Campo de pesquisa
        search_input = CustomTextInput(placeholder_text="Pesquisar")
        
        # Lista de clientes simulada
        scroll = ScrollView()
        clients_layout = BoxLayout(orientation='vertical', spacing=dp(15), size_hint_y=None)
        clients_layout.bind(minimum_height=clients_layout.setter('height'))
        
        # Clientes exemplo
        for i in range(4):
            client_card = BoxLayout(
                orientation='horizontal',
                size_hint_y=None,
                height=dp(80),
                padding=dp(15),
                spacing=dp(15)
            )
            
            # Fundo do card
            with client_card.canvas.before:
                Color(*COLORS['light_gray'])
                client_card.rect = RoundedRectangle(
                    pos=client_card.pos,
                    size=client_card.size,
                    radius=[dp(10)]
                )
            client_card.bind(pos=self.update_card_graphics, size=self.update_card_graphics)
            
            # Ícone
            icon = Label(
                text='👤',
                font_size=dp(24),
                size_hint_x=None,
                width=dp(40)
            )
            
            # Info
            info_layout = BoxLayout(orientation='vertical', spacing=dp(2))
            
            name = Label(
                text='Gabriel Oliveira',
                font_size=dp(16),
                bold=True,
                color=COLORS['dark_gray'],
                halign='left'
            )
            name.bind(size=name.setter('text_size'))
            
            phone = Label(
                text='(21)99999-9999',
                font_size=dp(14),
                color=COLORS['text_gray'],
                halign='left'
            )
            phone.bind(size=phone.setter('text_size'))
            
            email = Label(
                text='gabriel.oliveira@gmail.com',
                font_size=dp(12),
                color=COLORS['text_gray'],
                halign='left'
            )
            email.bind(size=email.setter('text_size'))
            
            info_layout.add_widget(name)
            info_layout.add_widget(phone)
            info_layout.add_widget(email)
            
            client_card.add_widget(icon)
            client_card.add_widget(info_layout)
            
            clients_layout.add_widget(client_card)
        
        scroll.add_widget(clients_layout)
        
        # Montagem
        main_layout.add_widget(header)
        main_layout.add_widget(search_input)
        main_layout.add_widget(scroll)
        
        self.add_widget(main_layout)
    
    def update_card_graphics(self, instance, value):
        instance.rect.pos = instance.pos
        instance.rect.size = instance.size

class ContratosScreen(Screen):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.build_ui()
    
    def build_ui(self):
        main_layout = BoxLayout(orientation='vertical', padding=dp(20), spacing=dp(20))
        
        # Header
        header = BoxLayout(orientation='horizontal', size_hint_y=None, height=dp(60))
        
        back_btn = Button(
            text='<',
            size_hint_x=None,
            width=dp(40),
            font_size=dp(20),
            color=COLORS['primary'],
            background_color=(0, 0, 0, 0)
        )
        back_btn.bind(on_press=lambda x: setattr(self.manager, 'current', 'dashboard'))
        
        title = Label(
            text='CONTRATOS',
            font_size=dp(24),
            bold=True,
            color=COLORS['primary'],
            halign='center'
        )
        title.bind(size=title.setter('text_size'))
        
        contract_icon = Label(
            text='📋',
            font_size=dp(24),
            size_hint_x=None,
            width=dp(40)
        )
        
        header.add_widget(back_btn)
        header.add_widget(title)
        header.add_widget(contract_icon)
        
        # Campo de pesquisa
        search_input = CustomTextInput(placeholder_text="Pesquisar")
        
        # Lista de contratos
        scroll = ScrollView()
        contracts_layout = BoxLayout(orientation='vertical', spacing=dp(15), size_hint_y=None)
        contracts_layout.bind(minimum_height=contracts_layout.setter('height'))
        
        # Contratos exemplo
        contract_data = [
            ('7.589', '25/05/25'),
            ('7.709', '30/06/25'),
            ('7.852', '30/09/25'),
            ('7.287', '25/01/26')
        ]
        
        for number, date in contract_data:
            contract_card = BoxLayout(
                orientation='horizontal',
                size_hint_y=None,
                height=dp(80),
                padding=dp(15),
                spacing=dp(15)
            )
            
            # Fundo do card
            with contract_card.canvas.before:
                Color(*COLORS['light_gray'])
                contract_card.rect = RoundedRectangle(
                    pos=contract_card.pos,
                    size=contract_card.size,
                    radius=[dp(10)]
                )
            contract_card.bind(pos=self.update_card_graphics, size=self.update_card_graphics)
            
            # Info
            info_layout = BoxLayout(orientation='vertical', spacing=dp(2))
            
            contract_title = Label(
                text=f'Contrato - {number}',
                font_size=dp(16),
                bold=True,
                color=COLORS['dark_gray'],
                halign='left'
            )
            contract_title.bind(size=contract_title.setter('text_size'))
            
            contractor = Label(
                text='Contratante: Gabriel Oliveira',
                font_size=dp(14),
                color=COLORS['text_gray'],
                halign='left'
            )
            contractor.bind(size=contractor.setter('text_size'))
            
            date_label = Label(
                text=f'Data: {date}',
                font_size=dp(14),
                color=COLORS['text_gray'],
                halign='left'
            )
            date_label.bind(size=date_label.setter('text_size'))
            
            info_layout.add_widget(contract_title)
            info_layout.add_widget(contractor)
            info_layout.add_widget(date_label)
            
            # Ícone download
            download_icon = Label(
                text='📥',
                font_size=dp(24),
                color=COLORS['primary'],
                size_hint_x=None,
                width=dp(40)
            )
            
            contract_card.add_widget(info_layout)
            contract_card.add_widget(download_icon)
            
            contracts_layout.add_widget(contract_card)
        
        scroll.add_widget(contracts_layout)
        
        # Montagem
        main_layout.add_widget(header)
        main_layout.add_widget(search_input)
        main_layout.add_widget(scroll)
        
        self.add_widget(main_layout)
    
    def update_card_graphics(self, instance, value):
        instance.rect.pos = instance.pos
        instance.rect.size = instance.size

class CadastroClienteScreen(Screen):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.build_ui()
    
    def build_ui(self):
        main_layout = BoxLayout(orientation='vertical', padding=dp(20), spacing=dp(20))
        
        # Header
        header = BoxLayout(orientation='horizontal', size_hint_y=None, height=dp(60))
        
        back_btn = Button(
            text='<',
            size_hint_x=None,
            width=dp(40),
            font_size=dp(20),
            color=COLORS['primary'],
            background_color=(0, 0, 0, 0)
        )
        back_btn.bind(on_press=lambda x: setattr(self.manager, 'current', 'dashboard'))
        
        title = Label(
            text='CADASTRO CLIENTE',
            font_size=dp(20),
            bold=True,
            color=COLORS['primary'],
            halign='center'
        )
        title.bind(size=title.setter('text_size'))
        
        user_icon = Label(
            text='👤',
            font_size=dp(24),
            size_hint_x=None,
            width=dp(40)
        )
        
        header.add_widget(back_btn)
        header.add_widget(title)
        header.add_widget(user_icon)
        
        # Subtítulo
        subtitle = Label(
            text='Complete os campos abaixo para prosseguir\\ncom o cadastro.',
            font_size=dp(14),
            color=COLORS['text_gray'],
            size_hint_y=None,
            height=dp(50),
            halign='center'
        )
        subtitle.bind(size=subtitle.setter('text_size'))
        
        # Formulário
        scroll = ScrollView()
        form_layout = BoxLayout(orientation='vertical', spacing=dp(20), size_hint_y=None)
        form_layout.bind(minimum_height=form_layout.setter('height'))
        
        # Campos
        self.nome_input = CustomTextInput(placeholder_text="NOME")
        self.cpf_input = CustomTextInput(placeholder_text="CPF")
        self.endereco_input = CustomTextInput(placeholder_text="ENDEREÇO")
        self.contrato_input = CustomTextInput(placeholder_text="Nº CONTRATO")
        self.data_input = CustomTextInput(placeholder_text="DATA DO EVENTO")
        
        # Campo forma de pagamento com botão +
        pagamento_layout = BoxLayout(orientation='horizontal', spacing=dp(10), size_hint_y=None, height=dp(60))
        self.pagamento_input = CustomTextInput(placeholder_text="FORMA DE PAGAMENTO")
        add_btn = Button(
            text='+',
            size_hint_x=None,
            width=dp(60),
            background_color=COLORS['primary'],
            color=COLORS['white'],
            font_size=dp(24)
        )
        pagamento_layout.add_widget(self.pagamento_input)
        pagamento_layout.add_widget(add_btn)
        
        # Botão avançar
        avancar_btn = CustomButton(
            "AVANÇAR",
            bg_color=COLORS['primary'],
            size_hint_y=None,
            height=dp(60)
        )
        avancar_btn.bind(on_press=lambda x: setattr(self.manager, 'current', 'servicos'))
        
        # Montagem do formulário
        form_layout.add_widget(self.nome_input)
        form_layout.add_widget(self.cpf_input)
        form_layout.add_widget(self.endereco_input)
        form_layout.add_widget(self.contrato_input)
        form_layout.add_widget(self.data_input)
        form_layout.add_widget(pagamento_layout)
        form_layout.add_widget(Widget(size_hint_y=None, height=dp(40)))
        form_layout.add_widget(avancar_btn)
        
        scroll.add_widget(form_layout)
        
        # Montagem principal
        main_layout.add_widget(header)
        main_layout.add_widget(subtitle)
        main_layout.add_widget(scroll)
        
        self.add_widget(main_layout)

class ServicosScreen(Screen):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.build_ui()
    
    def build_ui(self):
        main_layout = BoxLayout(orientation='vertical', padding=dp(20), spacing=dp(20))
        
        # Header
        header = BoxLayout(orientation='horizontal', size_hint_y=None, height=dp(60))
        
        back_btn = Button(
            text='<',
            size_hint_x=None,
            width=dp(40),
            font_size=dp(20),
            color=COLORS['primary'],
            background_color=(0, 0, 0, 0)
        )
        back_btn.bind(on_press=lambda x: setattr(self.manager, 'current', 'cadastro_cliente'))
        
        title = Label(
            text='SERVIÇOS',
            font_size=dp(24),
            bold=True,
            color=COLORS['primary'],
            halign='center'
        )
        title.bind(size=title.setter('text_size'))
        
        service_icon = Label(
            text='🛠️',
            font_size=dp(24),
            size_hint_x=None,
            width=dp(40)
        )
        
        header.add_widget(back_btn)
        header.add_widget(title)
        header.add_widget(service_icon)
        
        # Subtítulo
        subtitle = Label(
            text='Complete os campos abaixo para prosseguir\\ncom o cadastro.',
            font_size=dp(14),
            color=COLORS['text_gray'],
            size_hint_y=None,
            height=dp(50),
            halign='center'
        )
        subtitle.bind(size=subtitle.setter('text_size'))
        
        # Formulário
        form_layout = BoxLayout(orientation='vertical', spacing=dp(20))
        
        # Campo serviços com botão +
        servicos_layout = BoxLayout(orientation='horizontal', spacing=dp(10), size_hint_y=None, height=dp(60))
        self.servicos_input = CustomTextInput(placeholder_text="SERVIÇOS")
        add_servicos_btn = Button(
            text='+',
            size_hint_x=None,
            width=dp(60),
            background_color=COLORS['primary'],
            color=COLORS['white'],
            font_size=dp(24)
        )
        servicos_layout.add_widget(self.servicos_input)
        servicos_layout.add_widget(add_servicos_btn)
        
        # Outros campos
        self.valor_input = CustomTextInput(placeholder_text="VALOR R$")
        self.desconto_input = CustomTextInput(placeholder_text="DESCONTO")
        self.valor_total_input = CustomTextInput(placeholder_text="VALOR TOTAL R$")
        
        # Botão cadastrar
        cadastrar_btn = CustomButton(
            "CADASTRAR",
            bg_color=COLORS['primary'],
            size_hint_y=None,
            height=dp(60)
        )
        
        # Montagem
        form_layout.add_widget(servicos_layout)
        form_layout.add_widget(self.valor_input)
        form_layout.add_widget(self.desconto_input)
        form_layout.add_widget(self.valor_total_input)
        form_layout.add_widget(Widget())  # Espaçador
        form_layout.add_widget(cadastrar_btn)
        
        main_layout.add_widget(header)
        main_layout.add_widget(subtitle)
        main_layout.add_widget(form_layout)
        
        self.add_widget(main_layout)

class PromocaoScreen(Screen):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.build_ui()
    
    def build_ui(self):
        main_layout = BoxLayout(orientation='vertical', padding=dp(20), spacing=dp(20))
        
        # Header
        header = BoxLayout(orientation='horizontal', size_hint_y=None, height=dp(60))
        
        back_btn = Button(
            text='<',
            size_hint_x=None,
            width=dp(40),
            font_size=dp(20),
            color=COLORS['primary'],
            background_color=(0, 0, 0, 0)
        )
        back_btn.bind(on_press=lambda x: setattr(self.manager, 'current', 'dashboard'))
        
        title = Label(
            text='PROMOÇÃO',
            font_size=dp(24),
            bold=True,
            color=COLORS['primary'],
            halign='center'
        )
        title.bind(size=title.setter('text_size'))
        
        promo_icon = Label(
            text='📢',
            font_size=dp(24),
            size_hint_x=None,
            width=dp(40)
        )
        
        header.add_widget(back_btn)
        header.add_widget(title)
        header.add_widget(promo_icon)
        
        # Subtítulo
        subtitle = Label(
            text='Complete os campos obrigatórios para\\nprosseguir com a promoção.',
            font_size=dp(14),
            color=COLORS['text_gray'],
            size_hint_y=None,
            height=dp(50),
            halign='center'
        )
        subtitle.bind(size=subtitle.setter('text_size'))
        
        # Formulário
        scroll = ScrollView()
        form_layout = BoxLayout(orientation='vertical', spacing=dp(20), size_hint_y=None)
        form_layout.bind(minimum_height=form_layout.setter('height'))
        
        # Campo cliente com botão +
        cliente_layout = BoxLayout(orientation='horizontal', spacing=dp(10), size_hint_y=None, height=dp(60))
        self.cliente_input = CustomTextInput(placeholder_text="CLIENTE *")
        add_cliente_btn = Button(
            text='+',
            size_hint_x=None,
            width=dp(60),
            background_color=COLORS['primary'],
            color=COLORS['white'],
            font_size=dp(24)
        )
        cliente_layout.add_widget(self.cliente_input)
        cliente_layout.add_widget(add_cliente_btn)
        
        # Campo contrato com botão +
        contrato_layout = BoxLayout(orientation='horizontal', spacing=dp(10), size_hint_y=None, height=dp(60))
        self.contrato_input = CustomTextInput(placeholder_text="CONTRATO")
        add_contrato_btn = Button(
            text='+',
            size_hint_x=None,
            width=dp(60),
            background_color=COLORS['primary'],
            color=COLORS['white'],
            font_size=dp(24)
        )
        contrato_layout.add_widget(self.contrato_input)
        contrato_layout.add_widget(add_contrato_btn)
        
        # Campo serviços com botão +
        servicos_layout = BoxLayout(orientation='horizontal', spacing=dp(10), size_hint_y=None, height=dp(60))
        self.servicos_input = CustomTextInput(placeholder_text="SERVIÇOS *")
        add_servicos_btn = Button(
            text='+',
            size_hint_x=None,
            width=dp(60),
            background_color=COLORS['primary'],
            color=COLORS['white'],
            font_size=dp(24)
        )
        servicos_layout.add_widget(self.servicos_input)
        servicos_layout.add_widget(add_servicos_btn)
        
        # Outros campos
        self.valor_promocional_input = CustomTextInput(placeholder_text="VALOR PROMOCIONAL R$ *")
        
        # Campo validade com ícone
        validade_layout = BoxLayout(orientation='horizontal', spacing=dp(10), size_hint_y=None, height=dp(60))
        self.validade_input = CustomTextInput(placeholder_text="VALIDADE PROMOÇÃO *")
        calendar_icon = Label(
            text='📅',
            font_size=dp(24),
            size_hint_x=None,
            width=dp(40)
        )
        validade_layout.add_widget(self.validade_input)
        validade_layout.add_widget(calendar_icon)
        
        # Botão enviar
        enviar_btn = CustomButton(
            "ENVIAR",
            bg_color=COLORS['primary'],
            size_hint_y=None,
            height=dp(60)
        )
        
        # Montagem
        form_layout.add_widget(cliente_layout)
        form_layout.add_widget(contrato_layout)
        form_layout.add_widget(servicos_layout)
        form_layout.add_widget(self.valor_promocional_input)
        form_layout.add_widget(validade_layout)
        form_layout.add_widget(Widget(size_hint_y=None, height=dp(40)))
        form_layout.add_widget(enviar_btn)
        
        scroll.add_widget(form_layout)
        
        main_layout.add_widget(header)
        main_layout.add_widget(subtitle)
        main_layout.add_widget(scroll)
        
        self.add_widget(main_layout)

class NotificacaoScreen(Screen):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.build_ui()
    
    def build_ui(self):
        main_layout = BoxLayout(orientation='vertical', padding=dp(20), spacing=dp(20))
        
        # Header
        header = BoxLayout(orientation='horizontal', size_hint_y=None, height=dp(60))
        
        back_btn = Button(
            text='<',
            size_hint_x=None,
            width=dp(40),
            font_size=dp(20),
            color=COLORS['primary'],
            background_color=(0, 0, 0, 0)
        )
        back_btn.bind(on_press=lambda x: setattr(self.manager, 'current', 'dashboard'))
        
        title = Label(
            text='NOTIFICAÇÃO',
            font_size=dp(24),
            bold=True,
            color=COLORS['primary'],
            halign='center'
        )
        title.bind(size=title.setter('text_size'))
        
        notif_icon = Label(
            text='🔔',
            font_size=dp(24),
            size_hint_x=None,
            width=dp(40)
        )
        
        header.add_widget(back_btn)
        header.add_widget(title)
        header.add_widget(notif_icon)
        
        # Subtítulo
        subtitle = Label(
            text='Complete os campos para prosseguir.',
            font_size=dp(14),
            color=COLORS['text_gray'],
            size_hint_y=None,
            height=dp(40),
            halign='center'
        )
        subtitle.bind(size=subtitle.setter('text_size'))
        
        # Formulário
        form_layout = BoxLayout(orientation='vertical', spacing=dp(20))
        
        # Campo cliente com botão +
        cliente_layout = BoxLayout(orientation='horizontal', spacing=dp(10), size_hint_y=None, height=dp(60))
        self.cliente_input = CustomTextInput(placeholder_text="CLIENTE")
        add_cliente_btn = Button(
            text='+',
            size_hint_x=None,
            width=dp(60),
            background_color=COLORS['primary'],
            color=COLORS['white'],
            font_size=dp(24)
        )
        cliente_layout.add_widget(self.cliente_input)
        cliente_layout.add_widget(add_cliente_btn)
        
        # Campo contrato com botão +
        contrato_layout = BoxLayout(orientation='horizontal', spacing=dp(10), size_hint_y=None, height=dp(60))
        self.contrato_input = CustomTextInput(placeholder_text="CONTRATO")
        add_contrato_btn = Button(
            text='+',
            size_hint_x=None,
            width=dp(60),
            background_color=COLORS['primary'],
            color=COLORS['white'],
            font_size=dp(24)
        )
        contrato_layout.add_widget(self.contrato_input)
        contrato_layout.add_widget(add_contrato_btn)
        
        # Campo serviços com botão +
        servicos_layout = BoxLayout(orientation='horizontal', spacing=dp(10), size_hint_y=None, height=dp(60))
        self.servicos_input = CustomTextInput(placeholder_text="SERVIÇOS *")
        add_servicos_btn = Button(
            text='+',
            size_hint_x=None,
            width=dp(60),
            background_color=COLORS['primary'],
            color=COLORS['white'],
            font_size=dp(24)
        )
        servicos_layout.add_widget(self.servicos_input)
        servicos_layout.add_widget(add_servicos_btn)
        
        # Campo mensagem com ícone
        mensagem_layout = BoxLayout(orientation='horizontal', spacing=dp(10), size_hint_y=None, height=dp(200))
        self.mensagem_input = TextInput(
            hint_text="MENSAGEM",
            multiline=True,
            font_size=dp(16),
            padding=[dp(20), dp(15)],
            background_color=COLORS['light_gray'],
            foreground_color=COLORS['dark_gray']
        )
        edit_icon = Label(
            text='✏️',
            font_size=dp(24),
            size_hint_x=None,
            width=dp(40),
            valign='top'
        )
        edit_icon.bind(size=edit_icon.setter('text_size'))
        mensagem_layout.add_widget(self.mensagem_input)
        mensagem_layout.add_widget(edit_icon)
        
        # Botão notificar
        notificar_btn = CustomButton(
            "NOTIFICAR",
            bg_color=COLORS['primary'],
            size_hint_y=None,
            height=dp(60)
        )
        
        # Montagem
        form_layout.add_widget(cliente_layout)
        form_layout.add_widget(contrato_layout)
        form_layout.add_widget(servicos_layout)
        form_layout.add_widget(mensagem_layout)
        form_layout.add_widget(Widget())  # Espaçador
        form_layout.add_widget(notificar_btn)
        
        main_layout.add_widget(header)
        main_layout.add_widget(subtitle)
        main_layout.add_widget(form_layout)
        
        self.add_widget(main_layout)

class BaguncartApp(App):
    def build(self):
        # Configurar janela
        Window.size = (360, 640)
        Window.clearcolor = COLORS['white']
        
        # Inicializar banco
        Clock.schedule_once(lambda dt: self.init_database(), 0.1)
        
        # Screen Manager
        sm = ScreenManager()
        
        # Adicionar telas
        sm.add_widget(LoginScreen(name='login'))
        sm.add_widget(DashboardScreen(name='dashboard'))
        sm.add_widget(ClientesScreen(name='clientes'))
        sm.add_widget(ContratosScreen(name='contratos'))
        sm.add_widget(CadastroClienteScreen(name='cadastro_cliente'))
        sm.add_widget(ServicosScreen(name='servicos'))
        sm.add_widget(PromocaoScreen(name='promocao'))
        sm.add_widget(NotificacaoScreen(name='notificacao'))
        
        return sm
    
    def init_database(self):
        """Inicializar banco de dados"""
        try:
            db = Database()
            if db.connect():
                cursor = db.connection.cursor()
                
                # Criar tabelas
                cursor.execute("""
                    CREATE TABLE IF NOT EXISTS usuarios (
                        id INT AUTO_INCREMENT PRIMARY KEY,
                        cnpj VARCHAR(14) UNIQUE NOT NULL,
                        senha VARCHAR(255) NOT NULL,
                        nome VARCHAR(100) NOT NULL,
                        email VARCHAR(100),
                        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                    )
                """)
                
                cursor.execute("""
                    CREATE TABLE IF NOT EXISTS clientes (
                        id INT AUTO_INCREMENT PRIMARY KEY,
                        nome VARCHAR(100) NOT NULL,
                        cpf VARCHAR(11) UNIQUE NOT NULL,
                        endereco TEXT,
                        telefone VARCHAR(15),
                        email VARCHAR(100),
                        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                    )
                """)
                
                # Verificar/criar usuário admin
                cursor.execute("SELECT * FROM usuarios WHERE cnpj = %s", ("12345678000100",))
                if not cursor.fetchone():
                    senha_hash = bcrypt.hashpw("admin123".encode('utf-8'), bcrypt.gensalt())
                    cursor.execute(
                        "INSERT INTO usuarios (cnpj, senha, nome, email, created_at) VALUES (%s, %s, %s, %s, %s)",
                        ("12345678000100", senha_hash, "Administrador", "admin@baguncart.com", datetime.now())
                    )
                    print("✅ Usuário admin criado")
                
                cursor.close()
                print("✅ Banco inicializado")
                
        except Exception as e:
            print(f"❌ Erro ao inicializar banco: {e}")

if __name__ == '__main__':
    BaguncartApp().run()