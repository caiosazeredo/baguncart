import customtkinter as ctk
import tkinter as tk
from tkinter import messagebox, filedialog
from PIL import Image, ImageTk
import mysql.connector
import bcrypt
import threading
import time
from datetime import datetime, timedelta
import re
import os
import json

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

# Configurar tema
ctk.set_appearance_mode("light")
ctk.set_default_color_theme("blue")

# Cores
COLORS = {
    'primary': '#8B2F8B',
    'secondary': '#FF8C00', 
    'background': '#F8F9FA',
    'surface': '#FFFFFF',
    'text_primary': '#2E2E2E',
    'text_secondary': '#666666',
    'success': '#4CAF50',
    'error': '#F44336'
}

class Database:
    """Classe para gerenciar conexão com MySQL"""
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
            if not self.connection or not self.connection.is_connected():
                self.connect()
            cursor = self.connection.cursor(dictionary=True)
            cursor.execute(query, params)
            result = cursor.fetchall()
            cursor.close()
            return result
        except Exception as e:
            print(f"Erro na query: {e}")
            return []
    
    def execute_insert(self, query, params=None):
        try:
            if not self.connection or not self.connection.is_connected():
                self.connect()
            cursor = self.connection.cursor()
            cursor.execute(query, params)
            insert_id = cursor.lastrowid
            self.connection.commit()
            cursor.close()
            return insert_id
        except Exception as e:
            print(f"Erro no insert: {e}")
            return None
    
    def execute_update(self, query, params=None):
        try:
            if not self.connection or not self.connection.is_connected():
                self.connect()
            cursor = self.connection.cursor()
            cursor.execute(query, params)
            affected_rows = cursor.rowcount
            self.connection.commit()
            cursor.close()
            return affected_rows
        except Exception as e:
            print(f"Erro no update: {e}")
            return 0

    def init_tables(self):
        """Criar tabelas necessárias"""
        tables = [
            """CREATE TABLE IF NOT EXISTS clientes (
                id INT AUTO_INCREMENT PRIMARY KEY,
                nome VARCHAR(255) NOT NULL,
                cpf VARCHAR(14) UNIQUE NOT NULL,
                telefone VARCHAR(20),
                email VARCHAR(255),
                endereco TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )""",
            
            """CREATE TABLE IF NOT EXISTS contratos (
                id INT AUTO_INCREMENT PRIMARY KEY,
                numero VARCHAR(20) UNIQUE NOT NULL,
                cliente_id INT,
                data_evento DATE,
                local_evento TEXT,
                valor_total DECIMAL(10,2),
                status ENUM('pendente', 'confirmado', 'cancelado') DEFAULT 'pendente',
                forma_pagamento VARCHAR(100),
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (cliente_id) REFERENCES clientes(id)
            )""",
            
            """CREATE TABLE IF NOT EXISTS servicos (
                id INT AUTO_INCREMENT PRIMARY KEY,
                nome VARCHAR(255) NOT NULL,
                preco DECIMAL(10,2) NOT NULL,
                ativo BOOLEAN DEFAULT TRUE,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )""",
            
            """CREATE TABLE IF NOT EXISTS contrato_servicos (
                id INT AUTO_INCREMENT PRIMARY KEY,
                contrato_id INT,
                servico_id INT,
                quantidade INT DEFAULT 1,
                preco_unitario DECIMAL(10,2),
                FOREIGN KEY (contrato_id) REFERENCES contratos(id),
                FOREIGN KEY (servico_id) REFERENCES servicos(id)
            )""",
            
            """CREATE TABLE IF NOT EXISTS promocoes (
                id INT AUTO_INCREMENT PRIMARY KEY,
                titulo VARCHAR(255) NOT NULL,
                descricao TEXT,
                valor_desconto DECIMAL(10,2),
                porcentagem_desconto INT,
                data_inicio DATE,
                data_fim DATE,
                ativo BOOLEAN DEFAULT TRUE,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )""",
            
            """CREATE TABLE IF NOT EXISTS notificacoes (
                id INT AUTO_INCREMENT PRIMARY KEY,
                titulo VARCHAR(255) NOT NULL,
                mensagem TEXT NOT NULL,
                cliente_id INT,
                contrato_id INT,
                tipo ENUM('promocao', 'contrato', 'geral') DEFAULT 'geral',
                enviado BOOLEAN DEFAULT FALSE,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (cliente_id) REFERENCES clientes(id),
                FOREIGN KEY (contrato_id) REFERENCES contratos(id)
            )"""
        ]
        
        try:
            if not self.connection or not self.connection.is_connected():
                self.connect()
            
            cursor = self.connection.cursor()
            for table_sql in tables:
                cursor.execute(table_sql)
            
            # Adicionar coluna senha se não existir
            try:
                cursor.execute("ALTER TABLE clientes ADD COLUMN senha VARCHAR(255)")
                print("✅ Coluna senha adicionada")
            except:
                pass  # Coluna já existe
            
            # Inserir serviços padrão apenas se a tabela estiver vazia
            try:
                cursor.execute("SELECT COUNT(*) as count FROM servicos")
                result = cursor.fetchone()
                if result[0] == 0:
                    servicos_padrao = [
                        ('Pula pula', 20.00),
                        ('Garçom', 20.00),
                        ('Barman', 20.00),
                        ('Palhaço', 20.00),
                        ('Recepção', 20.00),
                        ('DJ', 50.00),
                        ('Decoração', 100.00),
                        ('Som e Luz', 80.00)
                    ]
                    
                    for nome, preco in servicos_padrao:
                        cursor.execute("INSERT INTO servicos (nome, preco) VALUES (%s, %s)", (nome, preco))
                    print("✅ Serviços padrão inseridos")
            except Exception as e:
                print(f"Aviso ao inserir serviços: {e}")
            
            self.connection.commit()
            cursor.close()
            print("✅ Tabelas criadas com sucesso")
            
        except Exception as e:
            print(f"Erro ao criar tabelas: {e}")

class ResponsiveFrame:
    """Classe base para frames responsivos"""
    def __init__(self, parent):
        self.parent = parent
        self.update_layout()
        
    def update_layout(self):
        """Atualizar layout baseado no tamanho da tela"""
        width = self.parent.winfo_width()
        
        self.is_mobile = width < 600
        self.is_tablet = 600 <= width < 900
        self.is_desktop = width >= 900
        
    def get_padding(self):
        if self.is_mobile:
            return 10
        elif self.is_tablet:
            return 20
        else:
            return 30
    
    def get_columns(self):
        """Retornar número de colunas baseado no tamanho da tela"""
        if self.is_mobile:
            return 1
        elif self.is_tablet:
            return 2
        else:
            return 3

class LoadingDialog:
    def __init__(self, parent, message="Carregando..."):
        self.window = ctk.CTkToplevel(parent)
        self.window.title("Carregando")
        self.window.geometry("300x150")
        self.window.resizable(False, False)
        self.window.transient(parent)
        self.window.grab_set()
        
        self.center_window()
        
        frame = ctk.CTkFrame(self.window, fg_color=COLORS['surface'])
        frame.pack(fill="both", expand=True, padx=20, pady=20)
        
        label = ctk.CTkLabel(frame, text=message, font=("Arial", 16))
        label.pack(pady=30)
        
        self.progress = ctk.CTkProgressBar(frame, mode="indeterminate")
        self.progress.pack(pady=10)
        self.progress.start()
    
    def center_window(self):
        self.window.update_idletasks()
        x = (self.window.winfo_screenwidth() // 2) - (300 // 2)
        y = (self.window.winfo_screenheight() // 2) - (150 // 2)
        self.window.geometry(f"300x150+{x}+{y}")
    
    def destroy(self):
        self.progress.stop()
        self.window.destroy()

class LoginScreen(ResponsiveFrame):
    def __init__(self, parent, app):
        self.parent = parent
        self.app = app
        self.frame = ctk.CTkFrame(parent, fg_color=COLORS['background'])
        super().__init__(parent)
        self.create_widgets()
        
    def create_widgets(self):
        self.scroll_frame = ctk.CTkScrollableFrame(self.frame, fg_color="transparent")
        self.scroll_frame.pack(fill="both", expand=True)
        
        self.main_container = ctk.CTkFrame(self.scroll_frame, fg_color="transparent")
        self.main_container.pack(fill="both", expand=True, padx=self.get_padding(), pady=self.get_padding())
        
        # Logo
        self.logo_frame = ctk.CTkFrame(self.main_container, fg_color="transparent", height=250)
        self.logo_frame.pack(fill="x", pady=(0, 30))
        self.logo_frame.pack_propagate(False)
        
        # Tentar carregar logo
        try:
            if os.path.exists("assets/bagunca.png"):
                logo_image = Image.open("assets/bagunca.png")
                logo_image = logo_image.resize((150, 100), Image.Resampling.LANCZOS)
                logo_photo = ctk.CTkImage(light_image=logo_image, size=(150, 100))
                
                logo_label = ctk.CTkLabel(self.logo_frame, image=logo_photo, text="")
                logo_label.pack(pady=20)
            else:
                logo_space = ctk.CTkFrame(self.logo_frame, fg_color=COLORS['primary'], 
                                        height=100, corner_radius=15)
                logo_space.pack(pady=10, fill="x")
                
                logo_label = ctk.CTkLabel(logo_space, text="BagunçArt", 
                                        font=("Arial", 24, "bold"), text_color="white")
                logo_label.pack(expand=True)
        except Exception as e:
            print(f"Erro ao carregar logo: {e}")
            logo_space = ctk.CTkFrame(self.logo_frame, fg_color=COLORS['primary'], 
                                    height=100, corner_radius=15)
            logo_space.pack(pady=10, fill="x")
            
            logo_label = ctk.CTkLabel(logo_space, text="BagunçArt", 
                                    font=("Arial", 24, "bold"), text_color="white")
            logo_label.pack(expand=True)
        
        title = ctk.CTkLabel(self.logo_frame, text="Sistema Administrativo", 
                           font=("Arial", 18, "bold"), text_color=COLORS['primary'])
        title.pack(pady=5)
        
        subtitle = ctk.CTkLabel(self.logo_frame, text="Gestão de Eventos", 
                              font=("Arial", 16), text_color=COLORS['text_secondary'])
        subtitle.pack()
        
        # Formulário
        self.create_form()
        
    def create_form(self):
        form_frame = ctk.CTkFrame(self.main_container, fg_color=COLORS['surface'], 
                                corner_radius=20)
        form_frame.pack(fill="x", pady=20)
        
        form_content = ctk.CTkFrame(form_frame, fg_color="transparent")
        form_content.pack(fill="both", padx=30, pady=30)
        
        # Campo CNPJ
        self.cnpj_entry = ctk.CTkEntry(form_content, placeholder_text="CNPJ da Empresa", 
                                     height=50, font=("Arial", 14))
        self.cnpj_entry.pack(fill="x", pady=(0, 15))
        
        # Campo Senha
        senha_frame = ctk.CTkFrame(form_content, fg_color="transparent")
        senha_frame.pack(fill="x", pady=(0, 30))
        
        self.senha_entry = ctk.CTkEntry(senha_frame, placeholder_text="Senha", 
                                      height=50, font=("Arial", 14), show="*")
        self.senha_entry.pack(side="left", fill="x", expand=True)
        
        self.toggle_btn = ctk.CTkButton(senha_frame, text="👁", width=50, height=50,
                                      command=self.toggle_password, 
                                      fg_color=COLORS['surface'],
                                      text_color=COLORS['primary'], 
                                      hover_color=COLORS['background'])
        self.toggle_btn.pack(side="right", padx=(10, 0))
        
        # Botão Login
        self.login_btn = ctk.CTkButton(form_content, text="Entrar", height=50,
                                     font=("Arial", 16, "bold"), 
                                     fg_color=COLORS['secondary'],
                                     hover_color=COLORS['secondary'], 
                                     command=self.login, corner_radius=25)
        self.login_btn.pack(fill="x", pady=10)
        
        # Info padrão
        info_frame = ctk.CTkFrame(self.main_container, fg_color=COLORS['background'], 
                                corner_radius=15)
        info_frame.pack(fill="x", pady=20)
        
        info_content = ctk.CTkFrame(info_frame, fg_color="transparent")
        info_content.pack(fill="both", padx=20, pady=20)
        
        info_title = ctk.CTkLabel(info_content, text="💡 Login Padrão:", 
                                font=("Arial", 14, "bold"), text_color=COLORS['primary'])
        info_title.pack(anchor="w")
        
        ctk.CTkLabel(info_content, text="CNPJ: 12345678000100", 
                   font=("Arial", 12), text_color=COLORS['text_secondary']).pack(anchor="w")
        ctk.CTkLabel(info_content, text="Senha: admin123", 
                   font=("Arial", 12), text_color=COLORS['text_secondary']).pack(anchor="w")
    
    def toggle_password(self):
        if self.senha_entry.cget("show") == "*":
            self.senha_entry.configure(show="")
            self.toggle_btn.configure(text="🙈")
        else:
            self.senha_entry.configure(show="*")
            self.toggle_btn.configure(text="👁")
    
    def login(self):
        cnpj = self.cnpj_entry.get().strip()
        senha = self.senha_entry.get().strip()
        
        if not cnpj or not senha:
            messagebox.showerror("Erro", "Preencha todos os campos!")
            return
        
        cnpj_clean = re.sub(r'\D', '', cnpj)
        loading = LoadingDialog(self.parent, "Autenticando...")
        
        def authenticate():
            time.sleep(1.5)
            
            if cnpj_clean == "12345678000100" and senha == "admin123":
                self.app.current_user = {
                    'id': 1,
                    'cnpj': cnpj_clean,
                    'nome': 'Administrador',
                    'email': 'admin@baguncart.com'
                }
                
                self.parent.after(0, lambda: [
                    loading.destroy(),
                    self.app.show_menu(),
                    messagebox.showinfo("Sucesso", "Login realizado com sucesso!")
                ])
            else:
                self.parent.after(0, lambda: [
                    loading.destroy(),
                    messagebox.showerror("Erro", "CNPJ ou senha incorretos!")
                ])
        
        threading.Thread(target=authenticate, daemon=True).start()
    
    def show(self):
        self.frame.pack(fill="both", expand=True)
        
    def hide(self):
        self.frame.pack_forget()

class MenuScreen(ResponsiveFrame):
    def __init__(self, parent, app):
        self.parent = parent
        self.app = app
        self.frame = ctk.CTkFrame(parent, fg_color=COLORS['background'])
        super().__init__(parent)
        self.create_widgets()
        
    def create_widgets(self):
        self.scroll_frame = ctk.CTkScrollableFrame(self.frame, fg_color="transparent")
        self.scroll_frame.pack(fill="both", expand=True)
        
        self.main_container = ctk.CTkFrame(self.scroll_frame, fg_color="transparent")
        self.main_container.pack(fill="both", expand=True, padx=self.get_padding(), pady=self.get_padding())
        
        # Header com logo e usuário
        header_frame = ctk.CTkFrame(self.main_container, fg_color="transparent")
        header_frame.pack(fill="x", pady=(0, 30))
        
        # Logo pequena no header
        try:
            if os.path.exists("assets/bagunca.png"):
                logo_image = Image.open("assets/bagunca.png")
                logo_image = logo_image.resize((80, 50), Image.Resampling.LANCZOS)
                logo_photo = ctk.CTkImage(light_image=logo_image, size=(80, 50))
                
                logo_label = ctk.CTkLabel(header_frame, image=logo_photo, text="")
                logo_label.pack(side="left")
            else:
                logo_label = ctk.CTkLabel(header_frame, text="BagunçArt", 
                                        font=("Arial", 18, "bold"), text_color=COLORS['primary'])
                logo_label.pack(side="left")
        except:
            logo_label = ctk.CTkLabel(header_frame, text="BagunçArt", 
                                    font=("Arial", 18, "bold"), text_color=COLORS['primary'])
            logo_label.pack(side="left")
        
        # Botão logout
        logout_btn = ctk.CTkButton(header_frame, text="🚪 Sair", width=80, height=40,
                                 fg_color=COLORS['error'], command=self.app.logout)
        logout_btn.pack(side="right")
        
        user_label = ctk.CTkLabel(header_frame, text="👤 Administrador", 
                                font=("Arial", 16), text_color=COLORS['text_primary'])
        user_label.pack(side="right", padx=(0, 20))
        
        # Menu de botões - Layout responsivo
        self.create_menu_buttons(self.main_container)
        
    def create_menu_buttons(self, parent):
        buttons_frame = ctk.CTkFrame(parent, fg_color="transparent")
        buttons_frame.pack(fill="both", expand=True)
        
        cols = self.get_columns()
        
        # Configurar grid
        for i in range(cols):
            buttons_frame.grid_columnconfigure(i, weight=1)
        
        # Botões do menu
        buttons = [
            ("👥", "CLIENTES", self.app.show_clientes),
            ("📄", "CONTRATOS", self.app.show_contratos),
            ("📢", "PROMOÇÃO", self.app.show_promocao),
            ("📝", "CADASTRAR\nCLIENTE", self.app.show_cadastro),
            ("🔔", "NOTIFICAÇÃO", self.app.show_notificacao),
            ("⚙️", "SERVIÇOS", self.app.show_servicos)
        ]
        
        for i, (icon, text, command) in enumerate(buttons):
            row = i // cols
            col = i % cols
            
            height = 100 if self.is_mobile else 120
            
            btn = ctk.CTkButton(buttons_frame, text=f"{icon}\n{text}", 
                              height=height, font=("Arial", 14, "bold"),
                              fg_color=COLORS['secondary'], 
                              hover_color=COLORS['secondary'],
                              command=command, corner_radius=15)
            btn.grid(row=row, column=col, padx=10, pady=10, sticky="ew")
    
    def update_layout(self):
        super().update_layout()
        # Layout responsivo simples - apenas atualiza os atributos
        # Evita conflitos de geometry manager
    
    def show(self):
        self.frame.pack(fill="both", expand=True)
        
    def hide(self):
        self.frame.pack_forget()

class ClientesScreen(ResponsiveFrame):
    def __init__(self, parent, app):
        self.parent = parent
        self.app = app
        self.frame = ctk.CTkFrame(parent, fg_color=COLORS['background'])
        super().__init__(parent)
        self.create_widgets()
        self.load_clientes()
        
    def create_widgets(self):
        # Header
        self.create_header("CLIENTES", "👤")
        
        # Conteúdo
        content = ctk.CTkFrame(self.frame, fg_color="transparent")
        content.pack(fill="both", expand=True, padx=self.get_padding(), pady=(0, self.get_padding()))
        
        # Barra de ferramentas
        toolbar = ctk.CTkFrame(content, fg_color=COLORS['surface'], corner_radius=15)
        toolbar.pack(fill="x", pady=(0, 20))
        
        toolbar_content = ctk.CTkFrame(toolbar, fg_color="transparent")
        toolbar_content.pack(fill="both", padx=20, pady=15)
        
        # Campo de pesquisa
        self.search_entry = ctk.CTkEntry(toolbar_content, placeholder_text="Pesquisar clientes...", 
                                       height=40, font=("Arial", 14))
        self.search_entry.pack(side="left", fill="x", expand=True)
        self.search_entry.bind('<KeyRelease>', self.on_search)
        
        search_btn = ctk.CTkButton(toolbar_content, text="🔍", width=40, height=40,
                                 fg_color=COLORS['primary'], command=self.search_clientes)
        search_btn.pack(side="right", padx=(10, 0))
        
        # Botão adicionar
        add_btn = ctk.CTkButton(toolbar_content, text="➕ Novo", width=80, height=40,
                              fg_color=COLORS['success'], command=self.app.show_cadastro)
        add_btn.pack(side="right", padx=(10, 0))
        
        # Lista de clientes
        self.clientes_frame = ctk.CTkScrollableFrame(content, fg_color="transparent")
        self.clientes_frame.pack(fill="both", expand=True)
        
    def create_header(self, title, icon):
        header = ctk.CTkFrame(self.frame, fg_color=COLORS['primary'], height=80)
        header.pack(fill="x", padx=self.get_padding(), pady=(self.get_padding(), 10))
        header.pack_propagate(False)
        
        header_content = ctk.CTkFrame(header, fg_color="transparent")
        header_content.pack(fill="both", padx=20, pady=20)
        
        back_btn = ctk.CTkButton(header_content, text="← ", width=60, height=40,
                               fg_color="transparent", command=self.app.show_menu,
                               text_color="white", font=("Arial", 16))
        back_btn.pack(side="left")
        
        title_label = ctk.CTkLabel(header_content, text=title, 
                                 font=("Arial", 20, "bold"), text_color="white")
        title_label.pack(expand=True)
        
        icon_label = ctk.CTkLabel(header_content, text=icon, 
                                font=("Arial", 20), text_color="white")
        icon_label.pack(side="right")
    
    def load_clientes(self):
        """Carregar clientes do banco de dados"""
        try:
            self.clientes = self.app.db.execute_query("SELECT * FROM clientes ORDER BY nome")
            print(f"✅ {len(self.clientes)} clientes carregados")
        except Exception as e:
            print(f"❌ Erro ao carregar clientes: {e}")
            self.clientes = []
        self.display_clientes(self.clientes)
    
    def display_clientes(self, clientes):
        # Limpar lista atual
        for widget in self.clientes_frame.winfo_children():
            widget.destroy()
        
        if not clientes:
            no_data = ctk.CTkLabel(self.clientes_frame, text="Nenhum cliente encontrado", 
                                 font=("Arial", 16), text_color=COLORS['text_secondary'])
            no_data.pack(pady=50)
            return
        
        for cliente in clientes:
            self.create_cliente_item(self.clientes_frame, cliente)
    
    def create_cliente_item(self, parent, cliente):
        item = ctk.CTkFrame(parent, fg_color=COLORS['surface'], corner_radius=15)
        item.pack(fill="x", pady=5)
        
        content = ctk.CTkFrame(item, fg_color="transparent")
        content.pack(fill="both", padx=20, pady=20)
        
        # Ícone
        icon = ctk.CTkLabel(content, text="👤", font=("Arial", 24), 
                          text_color=COLORS['primary'])
        icon.pack(side="left", padx=(0, 15))
        
        # Informações
        info_frame = ctk.CTkFrame(content, fg_color="transparent")
        info_frame.pack(side="left", fill="both", expand=True)
        
        ctk.CTkLabel(info_frame, text=cliente['nome'], 
                   font=("Arial", 16, "bold"), text_color=COLORS['text_primary']).pack(anchor="w")
        ctk.CTkLabel(info_frame, text=f"CPF: {cliente['cpf']}", 
                   font=("Arial", 12), text_color=COLORS['text_secondary']).pack(anchor="w")
        if cliente['telefone']:
            ctk.CTkLabel(info_frame, text=f"Tel: {cliente['telefone']}", 
                       font=("Arial", 12), text_color=COLORS['text_secondary']).pack(anchor="w")
        
        # Botões
        btn_frame = ctk.CTkFrame(content, fg_color="transparent")
        btn_frame.pack(side="right")
        
        edit_btn = ctk.CTkButton(btn_frame, text="✏️", width=40, height=40,
                               fg_color=COLORS['primary'], 
                               command=lambda: self.edit_cliente(cliente))
        edit_btn.pack(side="top", pady=2)
        
        contracts_btn = ctk.CTkButton(btn_frame, text="📄", width=40, height=40,
                                    fg_color=COLORS['secondary'],
                                    command=lambda: self.view_contracts(cliente))
        contracts_btn.pack(side="top", pady=2)
    
    def on_search(self, event):
        """Pesquisa em tempo real"""
        search_text = self.search_entry.get().lower()
        if not search_text:
            self.display_clientes(self.clientes)
            return
        
        filtered = [c for c in self.clientes 
                   if search_text in c['nome'].lower() or 
                      search_text in c['cpf'] or
                      (c['telefone'] and search_text in c['telefone']) or
                      (c['email'] and search_text in c['email'].lower())]
        
        self.display_clientes(filtered)
    
    def search_clientes(self):
        self.on_search(None)
    
    def edit_cliente(self, cliente):
        # Abrir janela de edição
        EditClienteDialog(self.parent, self.app, cliente, self.load_clientes)
    
    def view_contracts(self, cliente):
        messagebox.showinfo("Contratos", f"Visualizar contratos de {cliente['nome']}")
    
    def show(self):
        self.frame.pack(fill="both", expand=True)
        
    def hide(self):
        self.frame.pack_forget()

class EditClienteDialog:
    def __init__(self, parent, app, cliente, callback):
        self.app = app
        self.cliente = cliente
        self.callback = callback
        
        self.window = ctk.CTkToplevel(parent)
        self.window.title("Editar Cliente")
        self.window.geometry("500x600")
        self.window.transient(parent)
        self.window.grab_set()
        
        self.create_widgets()
        self.load_data()
        
    def create_widgets(self):
        # Scroll frame
        scroll_frame = ctk.CTkScrollableFrame(self.window, fg_color="transparent")
        scroll_frame.pack(fill="both", expand=True, padx=20, pady=20)
        
        # Título
        title = ctk.CTkLabel(scroll_frame, text="Editar Cliente", 
                           font=("Arial", 20, "bold"), text_color=COLORS['primary'])
        title.pack(pady=(0, 20))
        
        # Campos
        self.nome_entry = ctk.CTkEntry(scroll_frame, placeholder_text="Nome completo", height=50)
        self.nome_entry.pack(fill="x", pady=5)
        
        self.cpf_entry = ctk.CTkEntry(scroll_frame, placeholder_text="CPF", height=50)
        self.cpf_entry.pack(fill="x", pady=5)
        
        self.telefone_entry = ctk.CTkEntry(scroll_frame, placeholder_text="Telefone", height=50)
        self.telefone_entry.pack(fill="x", pady=5)
        
        self.email_entry = ctk.CTkEntry(scroll_frame, placeholder_text="Email", height=50)
        self.email_entry.pack(fill="x", pady=5)
        
        self.endereco_text = ctk.CTkTextbox(scroll_frame, height=100)
        self.endereco_text.pack(fill="x", pady=5)
        
        # Botões
        btn_frame = ctk.CTkFrame(scroll_frame, fg_color="transparent")
        btn_frame.pack(fill="x", pady=20)
        
        cancel_btn = ctk.CTkButton(btn_frame, text="Cancelar", 
                                 fg_color=COLORS['error'], command=self.window.destroy)
        cancel_btn.pack(side="right", padx=5)
        
        save_btn = ctk.CTkButton(btn_frame, text="Salvar", 
                               fg_color=COLORS['success'], command=self.save_cliente)
        save_btn.pack(side="right", padx=5)
    
    def load_data(self):
        """Carregar dados do cliente"""
        self.nome_entry.insert(0, self.cliente['nome'])
        self.cpf_entry.insert(0, self.cliente['cpf'])
        if self.cliente['telefone']:
            self.telefone_entry.insert(0, self.cliente['telefone'])
        if self.cliente['email']:
            self.email_entry.insert(0, self.cliente['email'])
        if self.cliente['endereco']:
            self.endereco_text.insert("1.0", self.cliente['endereco'])
    
    def save_cliente(self):
        """Salvar alterações"""
        nome = self.nome_entry.get().strip()
        cpf = self.cpf_entry.get().strip()
        telefone = self.telefone_entry.get().strip()
        email = self.email_entry.get().strip()
        endereco = self.endereco_text.get("1.0", "end-1c").strip()
        
        if not nome or not cpf:
            messagebox.showerror("Erro", "Nome e CPF são obrigatórios!")
            return
        
        try:
            query = """UPDATE clientes SET nome=%s, cpf=%s, telefone=%s, email=%s, endereco=%s 
                      WHERE id=%s"""
            params = (nome, cpf, telefone, email, endereco, self.cliente['id'])
            
            self.app.db.execute_update(query, params)
            
            messagebox.showinfo("Sucesso", "Cliente atualizado com sucesso!")
            self.callback()  # Recarregar lista
            self.window.destroy()
            
        except Exception as e:
            messagebox.showerror("Erro", f"Erro ao atualizar cliente: {e}")

class CadastroScreen(ResponsiveFrame):
    def __init__(self, parent, app):
        self.parent = parent
        self.app = app
        self.frame = ctk.CTkFrame(parent, fg_color=COLORS['background'])
        super().__init__(parent)
        self.create_widgets()
        
    def create_widgets(self):
        # Header
        self.create_header("CADASTRO CLIENTE", "📝")
        
        # Conteúdo scrollável
        content = ctk.CTkScrollableFrame(self.frame, fg_color="transparent")
        content.pack(fill="both", expand=True, padx=self.get_padding(), pady=(0, self.get_padding()))
        
        # Subtitle
        subtitle = ctk.CTkLabel(content, text="Complete os campos abaixo para cadastrar um novo cliente",
                              font=("Arial", 14), text_color=COLORS['text_secondary'])
        subtitle.pack(pady=(0, 30))
        
        # Formulário
        form_frame = ctk.CTkFrame(content, fg_color="transparent")
        form_frame.pack(fill="both", expand=True)
        
        # Campos
        self.nome_entry = ctk.CTkEntry(form_frame, placeholder_text="Nome completo *", height=50)
        self.nome_entry.pack(fill="x", pady=5)
        
        self.cpf_entry = ctk.CTkEntry(form_frame, placeholder_text="CPF *", height=50)
        self.cpf_entry.pack(fill="x", pady=5)
        
        self.telefone_entry = ctk.CTkEntry(form_frame, placeholder_text="Telefone", height=50)
        self.telefone_entry.pack(fill="x", pady=5)
        
        self.email_entry = ctk.CTkEntry(form_frame, placeholder_text="Email", height=50)
        self.email_entry.pack(fill="x", pady=5)
        
        # Endereço
        endereco_label = ctk.CTkLabel(form_frame, text="Endereço:", font=("Arial", 14))
        endereco_label.pack(anchor="w", pady=(10, 5))
        
        self.endereco_text = ctk.CTkTextbox(form_frame, height=100)
        self.endereco_text.pack(fill="x", pady=5)
        
        # Senha para app cliente
        self.senha_entry = ctk.CTkEntry(form_frame, placeholder_text="Senha para app do cliente", 
                                      height=50, show="*")
        self.senha_entry.pack(fill="x", pady=5)
        
        # Espaço
        ctk.CTkFrame(form_frame, fg_color="transparent", height=30).pack()
        
        # Botões
        btn_frame = ctk.CTkFrame(form_frame, fg_color="transparent")
        btn_frame.pack(fill="x")
        
        voltar_btn = ctk.CTkButton(btn_frame, text="← Voltar", 
                                 fg_color=COLORS['error'], command=self.app.show_menu)
        voltar_btn.pack(side="left")
        
        cadastrar_btn = ctk.CTkButton(btn_frame, text="Cadastrar Cliente", 
                                    fg_color=COLORS['success'], command=self.cadastrar_cliente)
        cadastrar_btn.pack(side="right")
    
    def create_header(self, title, icon):
        header = ctk.CTkFrame(self.frame, fg_color=COLORS['primary'], height=80)
        header.pack(fill="x", padx=self.get_padding(), pady=(self.get_padding(), 10))
        header.pack_propagate(False)
        
        header_content = ctk.CTkFrame(header, fg_color="transparent")
        header_content.pack(fill="both", padx=20, pady=20)
        
        back_btn = ctk.CTkButton(header_content, text="← ", width=60, height=40,
                               fg_color="transparent", command=self.app.show_menu,
                               text_color="white", font=("Arial", 16))
        back_btn.pack(side="left")
        
        title_label = ctk.CTkLabel(header_content, text=title, 
                                 font=("Arial", 20, "bold"), text_color="white")
        title_label.pack(expand=True)
        
        icon_label = ctk.CTkLabel(header_content, text=icon, 
                                font=("Arial", 20), text_color="white")
        icon_label.pack(side="right")
    
    def cadastrar_cliente(self):
        """Cadastrar novo cliente"""
        nome = self.nome_entry.get().strip()
        cpf = self.cpf_entry.get().strip()
        telefone = self.telefone_entry.get().strip()
        email = self.email_entry.get().strip()
        endereco = self.endereco_text.get("1.0", "end-1c").strip()
        senha = self.senha_entry.get().strip()
        
        if not nome or not cpf:
            messagebox.showerror("Erro", "Nome e CPF são obrigatórios!")
            return
        
        # Validar CPF (básico)
        cpf_clean = re.sub(r'\D', '', cpf)
        if len(cpf_clean) != 11:
            messagebox.showerror("Erro", "CPF deve ter 11 dígitos!")
            return
        
        try:
            # Primeiro tenta inserir sem senha
            query = """INSERT INTO clientes (nome, cpf, telefone, email, endereco) 
                      VALUES (%s, %s, %s, %s, %s)"""
            params = (nome, cpf_clean, telefone, email, endereco)
            
            cliente_id = self.app.db.execute_insert(query, params)
            
            # Se deu certo e tem senha, tenta atualizar
            if cliente_id and senha:
                try:
                    senha_hash = bcrypt.hashpw(senha.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
                    update_query = "UPDATE clientes SET senha = %s WHERE id = %s"
                    self.app.db.execute_update(update_query, (senha_hash, cliente_id))
                except Exception as e:
                    print(f"Aviso: Não foi possível salvar a senha: {e}")
            
            if cliente_id:
                messagebox.showinfo("Sucesso", f"Cliente cadastrado com sucesso!\nID: {cliente_id}")
                self.clear_form()
            else:
                messagebox.showerror("Erro", "Erro ao cadastrar cliente!")
                
        except mysql.connector.IntegrityError:
            messagebox.showerror("Erro", "Este CPF já está cadastrado!")
        except Exception as e:
            messagebox.showerror("Erro", f"Erro ao cadastrar: {e}")
    
    def clear_form(self):
        """Limpar formulário"""
        self.nome_entry.delete(0, 'end')
        self.cpf_entry.delete(0, 'end')
        self.telefone_entry.delete(0, 'end')
        self.email_entry.delete(0, 'end')
        self.endereco_text.delete("1.0", "end")
        self.senha_entry.delete(0, 'end')
    
    def show(self):
        self.frame.pack(fill="both", expand=True)
        
    def hide(self):
        self.frame.pack_forget()

class ContratosScreen(ResponsiveFrame):
    def __init__(self, parent, app):
        self.parent = parent
        self.app = app
        self.frame = ctk.CTkFrame(parent, fg_color=COLORS['background'])
        super().__init__(parent)
        self.create_widgets()
        self.load_contratos()
        
    def create_widgets(self):
        # Header
        self.create_header("CONTRATOS", "📄")
        
        # Conteúdo
        content = ctk.CTkFrame(self.frame, fg_color="transparent")
        content.pack(fill="both", expand=True, padx=self.get_padding(), pady=(0, self.get_padding()))
        
        # Toolbar
        toolbar = ctk.CTkFrame(content, fg_color=COLORS['surface'], corner_radius=15)
        toolbar.pack(fill="x", pady=(0, 20))
        
        toolbar_content = ctk.CTkFrame(toolbar, fg_color="transparent")
        toolbar_content.pack(fill="both", padx=20, pady=15)
        
        self.search_entry = ctk.CTkEntry(toolbar_content, placeholder_text="Pesquisar contratos...", 
                                       height=40, font=("Arial", 14))
        self.search_entry.pack(side="left", fill="x", expand=True)
        self.search_entry.bind('<KeyRelease>', self.on_search)
        
        search_btn = ctk.CTkButton(toolbar_content, text="🔍", width=40, height=40,
                                 fg_color=COLORS['primary'])
        search_btn.pack(side="right", padx=(10, 0))
        
        add_btn = ctk.CTkButton(toolbar_content, text="➕ Novo", width=80, height=40,
                              fg_color=COLORS['success'], command=self.novo_contrato)
        add_btn.pack(side="right", padx=(10, 0))
        
        # Lista de contratos
        self.contratos_frame = ctk.CTkScrollableFrame(content, fg_color="transparent")
        self.contratos_frame.pack(fill="both", expand=True)
    
    def create_header(self, title, icon):
        header = ctk.CTkFrame(self.frame, fg_color=COLORS['primary'], height=80)
        header.pack(fill="x", padx=self.get_padding(), pady=(self.get_padding(), 10))
        header.pack_propagate(False)
        
        header_content = ctk.CTkFrame(header, fg_color="transparent")
        header_content.pack(fill="both", padx=20, pady=20)
        
        back_btn = ctk.CTkButton(header_content, text="← ", width=60, height=40,
                               fg_color="transparent", command=self.app.show_menu,
                               text_color="white", font=("Arial", 16))
        back_btn.pack(side="left")
        
        title_label = ctk.CTkLabel(header_content, text=title, 
                                 font=("Arial", 20, "bold"), text_color="white")
        title_label.pack(expand=True)
        
        icon_label = ctk.CTkLabel(header_content, text=icon, 
                                font=("Arial", 20), text_color="white")
        icon_label.pack(side="right")
    
    def load_contratos(self):
        try:
            query = """
            SELECT c.*, cl.nome as cliente_nome, cl.cpf 
            FROM contratos c 
            LEFT JOIN clientes cl ON c.cliente_id = cl.id 
            ORDER BY c.created_at DESC
            """
            self.contratos = self.app.db.execute_query(query)
            print(f"✅ {len(self.contratos)} contratos carregados")
        except Exception as e:
            print(f"❌ Erro ao carregar contratos: {e}")
            self.contratos = []
        self.display_contratos(self.contratos)
    
    def display_contratos(self, contratos):
        for widget in self.contratos_frame.winfo_children():
            widget.destroy()
        
        if not contratos:
            no_data = ctk.CTkLabel(self.contratos_frame, text="Nenhum contrato encontrado", 
                                 font=("Arial", 16), text_color=COLORS['text_secondary'])
            no_data.pack(pady=50)
            return
        
        for contrato in contratos:
            self.create_contrato_item(self.contratos_frame, contrato)
    
    def create_contrato_item(self, parent, contrato):
        item = ctk.CTkFrame(parent, fg_color=COLORS['surface'], corner_radius=15)
        item.pack(fill="x", pady=8)
        
        content = ctk.CTkFrame(item, fg_color="transparent")
        content.pack(fill="both", padx=20, pady=20)
        
        # Informações principais
        info_frame = ctk.CTkFrame(content, fg_color="transparent")
        info_frame.pack(side="left", fill="both", expand=True)
        
        # Status
        status_color = COLORS['success'] if contrato['status'] == 'confirmado' else COLORS['secondary']
        status_text = contrato['status'].upper()
        
        header_frame = ctk.CTkFrame(info_frame, fg_color="transparent")
        header_frame.pack(fill="x")
        
        ctk.CTkLabel(header_frame, text=f"Contrato #{contrato['numero']}", 
                   font=("Arial", 16, "bold"), text_color=COLORS['text_primary']).pack(side="left")
        ctk.CTkLabel(header_frame, text=status_text, 
                   font=("Arial", 12, "bold"), text_color=status_color).pack(side="right")
        
        if contrato['cliente_nome']:
            ctk.CTkLabel(info_frame, text=f"Cliente: {contrato['cliente_nome']}", 
                       font=("Arial", 12), text_color=COLORS['text_secondary']).pack(anchor="w")
        
        if contrato['data_evento']:
            ctk.CTkLabel(info_frame, text=f"Data: {contrato['data_evento']}", 
                       font=("Arial", 12), text_color=COLORS['text_secondary']).pack(anchor="w")
        
        if contrato['valor_total']:
            ctk.CTkLabel(info_frame, text=f"Valor: R$ {contrato['valor_total']:.2f}", 
                       font=("Arial", 12, "bold"), text_color=COLORS['success']).pack(anchor="w")
        
        # Botões de ação
        btn_frame = ctk.CTkFrame(content, fg_color="transparent")
        btn_frame.pack(side="right")
        
        edit_btn = ctk.CTkButton(btn_frame, text="✏️", width=40, height=40,
                               fg_color=COLORS['primary'], 
                               command=lambda: self.edit_contrato(contrato))
        edit_btn.pack(side="top", pady=2)
        
        view_btn = ctk.CTkButton(btn_frame, text="👁", width=40, height=40,
                               fg_color=COLORS['secondary'],
                               command=lambda: self.view_contrato(contrato))
        view_btn.pack(side="top", pady=2)
    
    def on_search(self, event):
        search_text = self.search_entry.get().lower()
        if not search_text:
            self.display_contratos(self.contratos)
            return
        
        filtered = [c for c in self.contratos 
                   if search_text in c['numero'].lower() or 
                      (c['cliente_nome'] and search_text in c['cliente_nome'].lower())]
        
        self.display_contratos(filtered)
    
    def novo_contrato(self):
        ContratoDialog(self.parent, self.app, None, self.load_contratos)
    
    def edit_contrato(self, contrato):
        ContratoDialog(self.parent, self.app, contrato, self.load_contratos)
    
    def view_contrato(self, contrato):
        messagebox.showinfo("Detalhes", f"Visualizar detalhes do contrato {contrato['numero']}")
    
    def show(self):
        self.frame.pack(fill="both", expand=True)
        
    def hide(self):
        self.frame.pack_forget()

class ContratoDialog:
    def __init__(self, parent, app, contrato, callback):
        self.app = app
        self.contrato = contrato
        self.callback = callback
        
        self.window = ctk.CTkToplevel(parent)
        self.window.title("Novo Contrato" if not contrato else "Editar Contrato")
        self.window.geometry("600x700")
        self.window.transient(parent)
        self.window.grab_set()
        
        self.create_widgets()
        if contrato:
            self.load_data()
        
        self.load_clientes()
        self.load_servicos()
        
    def create_widgets(self):
        scroll_frame = ctk.CTkScrollableFrame(self.window, fg_color="transparent")
        scroll_frame.pack(fill="both", expand=True, padx=20, pady=20)
        
        title = ctk.CTkLabel(scroll_frame, 
                           text="Novo Contrato" if not self.contrato else "Editar Contrato", 
                           font=("Arial", 20, "bold"), text_color=COLORS['primary'])
        title.pack(pady=(0, 20))
        
        # Número do contrato
        self.numero_entry = ctk.CTkEntry(scroll_frame, placeholder_text="Número do contrato", height=50)
        self.numero_entry.pack(fill="x", pady=5)
        
        # Cliente
        ctk.CTkLabel(scroll_frame, text="Cliente:", font=("Arial", 14)).pack(anchor="w", pady=(10, 5))
        self.cliente_var = ctk.StringVar()
        self.cliente_combo = ctk.CTkComboBox(scroll_frame, variable=self.cliente_var, 
                                           values=[], height=50)
        self.cliente_combo.pack(fill="x", pady=5)
        
        # Data do evento
        self.data_entry = ctk.CTkEntry(scroll_frame, placeholder_text="Data do evento (DD/MM/AAAA)", height=50)
        self.data_entry.pack(fill="x", pady=5)
        
        # Local do evento
        ctk.CTkLabel(scroll_frame, text="Local do evento:", font=("Arial", 14)).pack(anchor="w", pady=(10, 5))
        self.local_text = ctk.CTkTextbox(scroll_frame, height=80)
        self.local_text.pack(fill="x", pady=5)
        
        # Forma de pagamento
        self.pagamento_entry = ctk.CTkEntry(scroll_frame, placeholder_text="Forma de pagamento", height=50)
        self.pagamento_entry.pack(fill="x", pady=5)
        
        # Serviços
        ctk.CTkLabel(scroll_frame, text="Serviços:", font=("Arial", 14, "bold")).pack(anchor="w", pady=(20, 10))
        
        self.servicos_frame = ctk.CTkFrame(scroll_frame, fg_color=COLORS['background'])
        self.servicos_frame.pack(fill="x", pady=5)
        
        # Valor total
        self.valor_entry = ctk.CTkEntry(scroll_frame, placeholder_text="Valor total (R$)", height=50)
        self.valor_entry.pack(fill="x", pady=5)
        
        # Status
        ctk.CTkLabel(scroll_frame, text="Status:", font=("Arial", 14)).pack(anchor="w", pady=(10, 5))
        self.status_var = ctk.StringVar(value="pendente")
        self.status_combo = ctk.CTkComboBox(scroll_frame, variable=self.status_var,
                                          values=["pendente", "confirmado", "cancelado"], height=50)
        self.status_combo.pack(fill="x", pady=5)
        
        # Botões
        btn_frame = ctk.CTkFrame(scroll_frame, fg_color="transparent")
        btn_frame.pack(fill="x", pady=20)
        
        cancel_btn = ctk.CTkButton(btn_frame, text="Cancelar", 
                                 fg_color=COLORS['error'], command=self.window.destroy)
        cancel_btn.pack(side="right", padx=5)
        
        save_btn = ctk.CTkButton(btn_frame, text="Salvar", 
                               fg_color=COLORS['success'], command=self.save_contrato)
        save_btn.pack(side="right", padx=5)
    
    def load_clientes(self):
        clientes = self.app.db.execute_query("SELECT id, nome FROM clientes ORDER BY nome")
        cliente_values = [f"{c['id']} - {c['nome']}" for c in clientes]
        self.cliente_combo.configure(values=cliente_values)
    
    def load_servicos(self):
        servicos = self.app.db.execute_query("SELECT * FROM servicos WHERE ativo = TRUE ORDER BY nome")
        
        for widget in self.servicos_frame.winfo_children():
            widget.destroy()
        
        self.servico_vars = {}
        for servico in servicos:
            frame = ctk.CTkFrame(self.servicos_frame, fg_color="transparent")
            frame.pack(fill="x", pady=2)
            
            var = ctk.BooleanVar()
            checkbox = ctk.CTkCheckBox(frame, text=f"{servico['nome']} - R$ {servico['preco']:.2f}", 
                                     variable=var, command=self.calcular_total)
            checkbox.pack(side="left")
            
            self.servico_vars[servico['id']] = {'var': var, 'preco': servico['preco']}
    
    def calcular_total(self):
        """Calcular valor total baseado nos serviços selecionados"""
        total = 0
        for servico_id, data in self.servico_vars.items():
            if data['var'].get():
                total += data['preco']
        
        # Atualizar campo de valor
        self.valor_entry.delete(0, 'end')
        self.valor_entry.insert(0, f"{total:.2f}")
    
    def load_data(self):
        """Carregar dados do contrato para edição"""
        self.numero_entry.insert(0, self.contrato['numero'])
        
        if self.contrato['cliente_id']:
            # Buscar nome do cliente
            cliente = self.app.db.execute_query("SELECT nome FROM clientes WHERE id = %s", 
                                               (self.contrato['cliente_id'],))
            if cliente:
                self.cliente_var.set(f"{self.contrato['cliente_id']} - {cliente[0]['nome']}")
        
        if self.contrato['data_evento']:
            self.data_entry.insert(0, self.contrato['data_evento'].strftime('%d/%m/%Y'))
        
        if self.contrato['local_evento']:
            self.local_text.insert("1.0", self.contrato['local_evento'])
        
        if self.contrato['forma_pagamento']:
            self.pagamento_entry.insert(0, self.contrato['forma_pagamento'])
        
        if self.contrato['valor_total']:
            self.valor_entry.insert(0, str(self.contrato['valor_total']))
        
        self.status_var.set(self.contrato['status'])
    
    def save_contrato(self):
        numero = self.numero_entry.get().strip()
        cliente_text = self.cliente_var.get()
        data_text = self.data_entry.get().strip()
        local = self.local_text.get("1.0", "end-1c").strip()
        pagamento = self.pagamento_entry.get().strip()
        valor_text = self.valor_entry.get().strip()
        status = self.status_var.get()
        
        if not numero or not cliente_text:
            messagebox.showerror("Erro", "Número do contrato e cliente são obrigatórios!")
            return
        
        try:
            # Extrair ID do cliente
            cliente_id = int(cliente_text.split(' - ')[0])
            
            # Converter data
            data_evento = None
            if data_text:
                data_evento = datetime.strptime(data_text, '%d/%m/%Y').date()
            
            # Converter valor
            valor_total = None
            if valor_text:
                valor_total = float(valor_text.replace(',', '.'))
            
            if self.contrato:
                # Atualizar
                query = """UPDATE contratos SET numero=%s, cliente_id=%s, data_evento=%s, 
                          local_evento=%s, valor_total=%s, status=%s, forma_pagamento=%s 
                          WHERE id=%s"""
                params = (numero, cliente_id, data_evento, local, valor_total, status, 
                         pagamento, self.contrato['id'])
                self.app.db.execute_update(query, params)
            else:
                # Inserir
                query = """INSERT INTO contratos (numero, cliente_id, data_evento, local_evento, 
                          valor_total, status, forma_pagamento) 
                          VALUES (%s, %s, %s, %s, %s, %s, %s)"""
                params = (numero, cliente_id, data_evento, local, valor_total, status, pagamento)
                self.app.db.execute_insert(query, params)
            
            messagebox.showinfo("Sucesso", "Contrato salvo com sucesso!")
            self.callback()
            self.window.destroy()
            
        except Exception as e:
            messagebox.showerror("Erro", f"Erro ao salvar contrato: {e}")

class PromocaoScreen(ResponsiveFrame):
    def __init__(self, parent, app):
        self.parent = parent
        self.app = app
        self.frame = ctk.CTkFrame(parent, fg_color=COLORS['background'])
        super().__init__(parent)
        self.create_widgets()
        self.load_promocoes()
        
    def create_widgets(self):
        # Header
        self.create_header("PROMOÇÕES", "📢")
        
        # Conteúdo
        content = ctk.CTkScrollableFrame(self.frame, fg_color="transparent")
        content.pack(fill="both", expand=True, padx=self.get_padding(), pady=(0, self.get_padding()))
        
        # Toolbar
        toolbar = ctk.CTkFrame(content, fg_color=COLORS['surface'], corner_radius=15)
        toolbar.pack(fill="x", pady=(0, 20))
        
        toolbar_content = ctk.CTkFrame(toolbar, fg_color="transparent")
        toolbar_content.pack(fill="both", padx=20, pady=15)
        
        add_btn = ctk.CTkButton(toolbar_content, text="➕ Nova Promoção", 
                              fg_color=COLORS['success'], command=self.nova_promocao)
        add_btn.pack(side="left")
        
        # Lista de promoções
        self.promocoes_frame = ctk.CTkFrame(content, fg_color="transparent")
        self.promocoes_frame.pack(fill="both", expand=True)
    
    def create_header(self, title, icon):
        header = ctk.CTkFrame(self.frame, fg_color=COLORS['primary'], height=80)
        header.pack(fill="x", padx=self.get_padding(), pady=(self.get_padding(), 10))
        header.pack_propagate(False)
        
        header_content = ctk.CTkFrame(header, fg_color="transparent")
        header_content.pack(fill="both", padx=20, pady=20)
        
        back_btn = ctk.CTkButton(header_content, text="← ", width=60, height=40,
                               fg_color="transparent", command=self.app.show_menu,
                               text_color="white", font=("Arial", 16))
        back_btn.pack(side="left")
        
        title_label = ctk.CTkLabel(header_content, text=title, 
                                 font=("Arial", 20, "bold"), text_color="white")
        title_label.pack(expand=True)
        
        icon_label = ctk.CTkLabel(header_content, text=icon, 
                                font=("Arial", 20), text_color="white")
        icon_label.pack(side="right")
    
    def load_promocoes(self):
        try:
            self.promocoes = self.app.db.execute_query("SELECT * FROM promocoes ORDER BY created_at DESC")
        except:
            self.promocoes = []
            print("Aviso: Tabela promocoes não encontrada")
        self.display_promocoes()
    
    def display_promocoes(self):
        for widget in self.promocoes_frame.winfo_children():
            widget.destroy()
        
        if not self.promocoes:
            no_data = ctk.CTkLabel(self.promocoes_frame, text="Nenhuma promoção cadastrada", 
                                 font=("Arial", 16), text_color=COLORS['text_secondary'])
            no_data.pack(pady=50)
            return
        
        for promocao in self.promocoes:
            self.create_promocao_item(promocao)
    
    def create_promocao_item(self, promocao):
        item = ctk.CTkFrame(self.promocoes_frame, fg_color=COLORS['surface'], corner_radius=15)
        item.pack(fill="x", pady=8)
        
        content = ctk.CTkFrame(item, fg_color="transparent")
        content.pack(fill="both", padx=20, pady=20)
        
        # Informações
        info_frame = ctk.CTkFrame(content, fg_color="transparent")
        info_frame.pack(side="left", fill="both", expand=True)
        
        ctk.CTkLabel(info_frame, text=promocao['titulo'], 
                   font=("Arial", 16, "bold"), text_color=COLORS['text_primary']).pack(anchor="w")
        
        if promocao['descricao']:
            ctk.CTkLabel(info_frame, text=promocao['descricao'], 
                       font=("Arial", 12), text_color=COLORS['text_secondary']).pack(anchor="w")
        
        # Valor da promoção
        if promocao['valor_desconto']:
            valor_text = f"Desconto: R$ {promocao['valor_desconto']:.2f}"
        elif promocao['porcentagem_desconto']:
            valor_text = f"Desconto: {promocao['porcentagem_desconto']}%"
        else:
            valor_text = "Desconto não especificado"
        
        ctk.CTkLabel(info_frame, text=valor_text, 
                   font=("Arial", 12, "bold"), text_color=COLORS['success']).pack(anchor="w")
        
        # Datas
        if promocao['data_inicio'] and promocao['data_fim']:
            periodo = f"Válido: {promocao['data_inicio']} até {promocao['data_fim']}"
            ctk.CTkLabel(info_frame, text=periodo, 
                       font=("Arial", 10), text_color=COLORS['text_secondary']).pack(anchor="w")
        
        # Status
        status_text = "ATIVA" if promocao['ativo'] else "INATIVA"
        status_color = COLORS['success'] if promocao['ativo'] else COLORS['error']
        
        ctk.CTkLabel(content, text=status_text, 
                   font=("Arial", 12, "bold"), text_color=status_color).pack(side="right")
    
    def nova_promocao(self):
        PromocaoDialog(self.parent, self.app, None, self.load_promocoes)
    
    def show(self):
        self.frame.pack(fill="both", expand=True)
        
    def hide(self):
        self.frame.pack_forget()

class PromocaoDialog:
    def __init__(self, parent, app, promocao, callback):
        self.app = app
        self.promocao = promocao
        self.callback = callback
        
        self.window = ctk.CTkToplevel(parent)
        self.window.title("Nova Promoção" if not promocao else "Editar Promoção")
        self.window.geometry("500x600")
        self.window.transient(parent)
        self.window.grab_set()
        
        self.create_widgets()
        
    def create_widgets(self):
        scroll_frame = ctk.CTkScrollableFrame(self.window, fg_color="transparent")
        scroll_frame.pack(fill="both", expand=True, padx=20, pady=20)
        
        title = ctk.CTkLabel(scroll_frame, text="Nova Promoção", 
                           font=("Arial", 20, "bold"), text_color=COLORS['primary'])
        title.pack(pady=(0, 20))
        
        # Campos
        self.titulo_entry = ctk.CTkEntry(scroll_frame, placeholder_text="Título da promoção", height=50)
        self.titulo_entry.pack(fill="x", pady=5)
        
        ctk.CTkLabel(scroll_frame, text="Descrição:", font=("Arial", 14)).pack(anchor="w", pady=(10, 5))
        self.descricao_text = ctk.CTkTextbox(scroll_frame, height=100)
        self.descricao_text.pack(fill="x", pady=5)
        
        # Tipo de desconto
        ctk.CTkLabel(scroll_frame, text="Tipo de desconto:", font=("Arial", 14)).pack(anchor="w", pady=(10, 5))
        
        self.tipo_desconto = ctk.StringVar(value="valor")
        tipo_frame = ctk.CTkFrame(scroll_frame, fg_color="transparent")
        tipo_frame.pack(fill="x", pady=5)
        
        ctk.CTkRadioButton(tipo_frame, text="Valor fixo (R$)", variable=self.tipo_desconto, 
                         value="valor").pack(side="left", padx=(0, 20))
        ctk.CTkRadioButton(tipo_frame, text="Porcentagem (%)", variable=self.tipo_desconto, 
                         value="porcentagem").pack(side="left")
        
        # Valor do desconto
        self.desconto_entry = ctk.CTkEntry(scroll_frame, placeholder_text="Valor do desconto", height=50)
        self.desconto_entry.pack(fill="x", pady=5)
        
        # Datas
        data_frame = ctk.CTkFrame(scroll_frame, fg_color="transparent")
        data_frame.pack(fill="x", pady=10)
        
        data_frame.grid_columnconfigure((0, 1), weight=1)
        
        ctk.CTkLabel(data_frame, text="Data início:", font=("Arial", 12)).grid(row=0, column=0, sticky="w")
        self.data_inicio_entry = ctk.CTkEntry(data_frame, placeholder_text="DD/MM/AAAA", height=40)
        self.data_inicio_entry.grid(row=1, column=0, sticky="ew", padx=(0, 5))
        
        ctk.CTkLabel(data_frame, text="Data fim:", font=("Arial", 12)).grid(row=0, column=1, sticky="w")
        self.data_fim_entry = ctk.CTkEntry(data_frame, placeholder_text="DD/MM/AAAA", height=40)
        self.data_fim_entry.grid(row=1, column=1, sticky="ew", padx=(5, 0))
        
        # Status
        self.ativo_var = ctk.BooleanVar(value=True)
        ctk.CTkCheckBox(scroll_frame, text="Promoção ativa", variable=self.ativo_var).pack(pady=10)
        
        # Botões
        btn_frame = ctk.CTkFrame(scroll_frame, fg_color="transparent")
        btn_frame.pack(fill="x", pady=20)
        
        cancel_btn = ctk.CTkButton(btn_frame, text="Cancelar", 
                                 fg_color=COLORS['error'], command=self.window.destroy)
        cancel_btn.pack(side="right", padx=5)
        
        save_btn = ctk.CTkButton(btn_frame, text="Salvar", 
                               fg_color=COLORS['success'], command=self.save_promocao)
        save_btn.pack(side="right", padx=5)
    
    def save_promocao(self):
        titulo = self.titulo_entry.get().strip()
        descricao = self.descricao_text.get("1.0", "end-1c").strip()
        desconto_text = self.desconto_entry.get().strip()
        data_inicio_text = self.data_inicio_entry.get().strip()
        data_fim_text = self.data_fim_entry.get().strip()
        ativo = self.ativo_var.get()
        
        if not titulo or not desconto_text:
            messagebox.showerror("Erro", "Título e valor do desconto são obrigatórios!")
            return
        
        try:
            # Processar desconto
            valor_desconto = None
            porcentagem_desconto = None
            
            if self.tipo_desconto.get() == "valor":
                valor_desconto = float(desconto_text.replace(',', '.'))
            else:
                porcentagem_desconto = int(desconto_text)
            
            # Processar datas
            data_inicio = None
            data_fim = None
            
            if data_inicio_text:
                data_inicio = datetime.strptime(data_inicio_text, '%d/%m/%Y').date()
            if data_fim_text:
                data_fim = datetime.strptime(data_fim_text, '%d/%m/%Y').date()
            
            query = """INSERT INTO promocoes (titulo, descricao, valor_desconto, porcentagem_desconto, 
                      data_inicio, data_fim, ativo) VALUES (%s, %s, %s, %s, %s, %s, %s)"""
            params = (titulo, descricao, valor_desconto, porcentagem_desconto, 
                     data_inicio, data_fim, ativo)
            
            self.app.db.execute_insert(query, params)
            
            messagebox.showinfo("Sucesso", "Promoção salva com sucesso!")
            self.callback()
            self.window.destroy()
            
        except Exception as e:
            messagebox.showerror("Erro", f"Erro ao salvar promoção: {e}")

class ServicosScreen(ResponsiveFrame):
    def __init__(self, parent, app):
        self.parent = parent
        self.app = app
        self.frame = ctk.CTkFrame(parent, fg_color=COLORS['background'])
        super().__init__(parent)
        self.create_widgets()
        self.load_servicos()
        
    def create_widgets(self):
        # Header
        self.create_header("SERVIÇOS", "⚙️")
        
        # Conteúdo
        content = ctk.CTkScrollableFrame(self.frame, fg_color="transparent")
        content.pack(fill="both", expand=True, padx=self.get_padding(), pady=(0, self.get_padding()))
        
        # Toolbar
        toolbar = ctk.CTkFrame(content, fg_color=COLORS['surface'], corner_radius=15)
        toolbar.pack(fill="x", pady=(0, 20))
        
        toolbar_content = ctk.CTkFrame(toolbar, fg_color="transparent")
        toolbar_content.pack(fill="both", padx=20, pady=15)
        
        add_btn = ctk.CTkButton(toolbar_content, text="➕ Novo Serviço", 
                              fg_color=COLORS['success'], command=self.novo_servico)
        add_btn.pack(side="left")
        
        # Lista de serviços
        self.servicos_frame = ctk.CTkFrame(content, fg_color="transparent")
        self.servicos_frame.pack(fill="both", expand=True)
    
    def create_header(self, title, icon):
        header = ctk.CTkFrame(self.frame, fg_color=COLORS['primary'], height=80)
        header.pack(fill="x", padx=self.get_padding(), pady=(self.get_padding(), 10))
        header.pack_propagate(False)
        
        header_content = ctk.CTkFrame(header, fg_color="transparent")
        header_content.pack(fill="both", padx=20, pady=20)
        
        back_btn = ctk.CTkButton(header_content, text="← ", width=60, height=40,
                               fg_color="transparent", command=self.app.show_menu,
                               text_color="white", font=("Arial", 16))
        back_btn.pack(side="left")
        
        title_label = ctk.CTkLabel(header_content, text=title, 
                                 font=("Arial", 20, "bold"), text_color="white")
        title_label.pack(expand=True)
        
        icon_label = ctk.CTkLabel(header_content, text=icon, 
                                font=("Arial", 20), text_color="white")
        icon_label.pack(side="right")
    
    def load_servicos(self):
        try:
            self.servicos = self.app.db.execute_query("SELECT * FROM servicos ORDER BY nome")
        except:
            self.servicos = []
            print("Aviso: Erro ao carregar serviços")
        self.display_servicos()
    
    def display_servicos(self):
        for widget in self.servicos_frame.winfo_children():
            widget.destroy()
        
        if not self.servicos:
            no_data = ctk.CTkLabel(self.servicos_frame, text="Nenhum serviço cadastrado", 
                                 font=("Arial", 16), text_color=COLORS['text_secondary'])
            no_data.pack(pady=50)
            return
        
        for servico in self.servicos:
            self.create_servico_item(servico)
    
    def create_servico_item(self, servico):
        item = ctk.CTkFrame(self.servicos_frame, fg_color=COLORS['surface'], corner_radius=15)
        item.pack(fill="x", pady=8)
        
        content = ctk.CTkFrame(item, fg_color="transparent")
        content.pack(fill="both", padx=20, pady=20)
        
        # Informações
        info_frame = ctk.CTkFrame(content, fg_color="transparent")
        info_frame.pack(side="left", fill="both", expand=True)
        
        ctk.CTkLabel(info_frame, text=servico['nome'], 
                   font=("Arial", 16, "bold"), text_color=COLORS['text_primary']).pack(anchor="w")
        
        ctk.CTkLabel(info_frame, text=f"Preço: R$ {servico['preco']:.2f}", 
                   font=("Arial", 12, "bold"), text_color=COLORS['success']).pack(anchor="w")
        
        # Status
        status_text = "ATIVO" if servico['ativo'] else "INATIVO"
        status_color = COLORS['success'] if servico['ativo'] else COLORS['error']
        
        status_label = ctk.CTkLabel(content, text=status_text, 
                                  font=("Arial", 12, "bold"), text_color=status_color)
        status_label.pack(side="right", padx=(0, 10))
        
        # Botões
        btn_frame = ctk.CTkFrame(content, fg_color="transparent")
        btn_frame.pack(side="right")
        
        edit_btn = ctk.CTkButton(btn_frame, text="✏️", width=40, height=40,
                               fg_color=COLORS['primary'], 
                               command=lambda: self.edit_servico(servico))
        edit_btn.pack(side="top", pady=2)
        
        delete_btn = ctk.CTkButton(btn_frame, text="🗑️", width=40, height=40,
                                 fg_color=COLORS['error'],
                                 command=lambda: self.delete_servico(servico))
        delete_btn.pack(side="top", pady=2)
    
    def novo_servico(self):
        ServicoDialog(self.parent, self.app, None, self.load_servicos)
    
    def edit_servico(self, servico):
        ServicoDialog(self.parent, self.app, servico, self.load_servicos)
    
    def delete_servico(self, servico):
        if messagebox.askyesno("Confirmar", f"Deseja excluir o serviço '{servico['nome']}'?"):
            try:
                self.app.db.execute_update("DELETE FROM servicos WHERE id = %s", (servico['id'],))
                messagebox.showinfo("Sucesso", "Serviço excluído com sucesso!")
                self.load_servicos()
            except Exception as e:
                messagebox.showerror("Erro", f"Erro ao excluir serviço: {e}")
    
    def show(self):
        self.frame.pack(fill="both", expand=True)
        
    def hide(self):
        self.frame.pack_forget()

class ServicoDialog:
    def __init__(self, parent, app, servico, callback):
        self.app = app
        self.servico = servico
        self.callback = callback
        
        self.window = ctk.CTkToplevel(parent)
        self.window.title("Novo Serviço" if not servico else "Editar Serviço")
        self.window.geometry("400x350")
        self.window.transient(parent)
        self.window.grab_set()
        
        self.create_widgets()
        if servico:
            self.load_data()
    
    def create_widgets(self):
        # Main frame
        main_frame = ctk.CTkFrame(self.window, fg_color="transparent")
        main_frame.pack(fill="both", expand=True, padx=20, pady=20)
        
        title = ctk.CTkLabel(main_frame, 
                           text="Novo Serviço" if not self.servico else "Editar Serviço", 
                           font=("Arial", 20, "bold"), text_color=COLORS['primary'])
        title.pack(pady=(0, 20))
        
        # Nome do serviço
        self.nome_entry = ctk.CTkEntry(main_frame, placeholder_text="Nome do serviço", height=50)
        self.nome_entry.pack(fill="x", pady=5)
        
        # Preço
        self.preco_entry = ctk.CTkEntry(main_frame, placeholder_text="Preço (R$)", height=50)
        self.preco_entry.pack(fill="x", pady=5)
        
        # Status ativo
        self.ativo_var = ctk.BooleanVar(value=True)
        ctk.CTkCheckBox(main_frame, text="Serviço ativo", variable=self.ativo_var).pack(pady=15)
        
        # Botões
        btn_frame = ctk.CTkFrame(main_frame, fg_color="transparent")
        btn_frame.pack(fill="x", pady=20)
        
        cancel_btn = ctk.CTkButton(btn_frame, text="Cancelar", 
                                 fg_color=COLORS['error'], command=self.window.destroy)
        cancel_btn.pack(side="right", padx=5)
        
        save_btn = ctk.CTkButton(btn_frame, text="Salvar", 
                               fg_color=COLORS['success'], command=self.save_servico)
        save_btn.pack(side="right", padx=5)
    
    def load_data(self):
        """Carregar dados do serviço para edição"""
        self.nome_entry.insert(0, self.servico['nome'])
        self.preco_entry.insert(0, str(self.servico['preco']))
        self.ativo_var.set(self.servico['ativo'])
    
    def save_servico(self):
        nome = self.nome_entry.get().strip()
        preco_text = self.preco_entry.get().strip()
        ativo = self.ativo_var.get()
        
        if not nome or not preco_text:
            messagebox.showerror("Erro", "Nome e preço são obrigatórios!")
            return
        
        try:
            preco = float(preco_text.replace(',', '.'))
            
            if self.servico:
                # Atualizar
                query = "UPDATE servicos SET nome=%s, preco=%s, ativo=%s WHERE id=%s"
                params = (nome, preco, ativo, self.servico['id'])
                self.app.db.execute_update(query, params)
            else:
                # Inserir
                query = "INSERT INTO servicos (nome, preco, ativo) VALUES (%s, %s, %s)"
                params = (nome, preco, ativo)
                self.app.db.execute_insert(query, params)
            
            messagebox.showinfo("Sucesso", "Serviço salvo com sucesso!")
            self.callback()
            self.window.destroy()
            
        except ValueError:
            messagebox.showerror("Erro", "Preço deve ser um número válido!")
        except Exception as e:
            messagebox.showerror("Erro", f"Erro ao salvar serviço: {e}")

class NotificacaoScreen(ResponsiveFrame):
    def __init__(self, parent, app):
        self.parent = parent
        self.app = app
        self.frame = ctk.CTkFrame(parent, fg_color=COLORS['background'])
        super().__init__(parent)
        self.create_widgets()
        
    def create_widgets(self):
        # Header
        self.create_header("NOTIFICAÇÕES", "🔔")
        
        # Conteúdo
        content = ctk.CTkScrollableFrame(self.frame, fg_color="transparent")
        content.pack(fill="both", expand=True, padx=self.get_padding(), pady=(0, self.get_padding()))
        
        # Formulário de envio
        form_frame = ctk.CTkFrame(content, fg_color=COLORS['surface'], corner_radius=15)
        form_frame.pack(fill="x", pady=(0, 20))
        
        form_content = ctk.CTkFrame(form_frame, fg_color="transparent")
        form_content.pack(fill="both", padx=20, pady=20)
        
        ctk.CTkLabel(form_content, text="Enviar Nova Notificação", 
                   font=("Arial", 18, "bold"), text_color=COLORS['primary']).pack(pady=(0, 15))
        
        # Título
        self.titulo_entry = ctk.CTkEntry(form_content, placeholder_text="Título da notificação", height=50)
        self.titulo_entry.pack(fill="x", pady=5)
        
        # Cliente (opcional)
        ctk.CTkLabel(form_content, text="Cliente (deixe vazio para enviar para todos):", 
                   font=("Arial", 12)).pack(anchor="w", pady=(10, 5))
        
        self.cliente_var = ctk.StringVar()
        self.cliente_combo = ctk.CTkComboBox(form_content, variable=self.cliente_var, 
                                           values=[], height=50)
        self.cliente_combo.pack(fill="x", pady=5)
        
        # Tipo
        ctk.CTkLabel(form_content, text="Tipo:", font=("Arial", 12)).pack(anchor="w", pady=(10, 5))
        self.tipo_var = ctk.StringVar(value="geral")
        tipo_combo = ctk.CTkComboBox(form_content, variable=self.tipo_var,
                                   values=["geral", "promocao", "contrato"], height=50)
        tipo_combo.pack(fill="x", pady=5)
        
        # Mensagem
        ctk.CTkLabel(form_content, text="Mensagem:", font=("Arial", 12)).pack(anchor="w", pady=(10, 5))
        self.mensagem_text = ctk.CTkTextbox(form_content, height=150)
        self.mensagem_text.pack(fill="x", pady=5)
        
        # Botão enviar
        enviar_btn = ctk.CTkButton(form_content, text="📤 Enviar Notificação", 
                                 fg_color=COLORS['success'], command=self.enviar_notificacao)
        enviar_btn.pack(pady=15)
        
        # Histórico
        historico_frame = ctk.CTkFrame(content, fg_color=COLORS['surface'], corner_radius=15)
        historico_frame.pack(fill="both", expand=True)
        
        historico_content = ctk.CTkFrame(historico_frame, fg_color="transparent")
        historico_content.pack(fill="both", padx=20, pady=20)
        
        ctk.CTkLabel(historico_content, text="Histórico de Notificações", 
                   font=("Arial", 18, "bold"), text_color=COLORS['primary']).pack(pady=(0, 15))
        
        self.historico_frame = ctk.CTkScrollableFrame(historico_content, fg_color="transparent")
        self.historico_frame.pack(fill="both", expand=True)
        
        self.load_clientes()
        self.load_historico()
    
    def create_header(self, title, icon):
        header = ctk.CTkFrame(self.frame, fg_color=COLORS['primary'], height=80)
        header.pack(fill="x", padx=self.get_padding(), pady=(self.get_padding(), 10))
        header.pack_propagate(False)
        
        header_content = ctk.CTkFrame(header, fg_color="transparent")
        header_content.pack(fill="both", padx=20, pady=20)
        
        back_btn = ctk.CTkButton(header_content, text="← ", width=60, height=40,
                               fg_color="transparent", command=self.app.show_menu,
                               text_color="white", font=("Arial", 16))
        back_btn.pack(side="left")
        
        title_label = ctk.CTkLabel(header_content, text=title, 
                                 font=("Arial", 20, "bold"), text_color="white")
        title_label.pack(expand=True)
        
        icon_label = ctk.CTkLabel(header_content, text=icon, 
                                font=("Arial", 20), text_color="white")
        icon_label.pack(side="right")
    
    def load_clientes(self):
        try:
            clientes = self.app.db.execute_query("SELECT id, nome FROM clientes ORDER BY nome")
            cliente_values = [""] + [f"{c['id']} - {c['nome']}" for c in clientes]
            self.cliente_combo.configure(values=cliente_values)
        except Exception as e:
            print(f"Erro ao carregar clientes: {e}")
            self.cliente_combo.configure(values=[""])
    
    def load_historico(self):
        try:
            query = """
            SELECT n.*, c.nome as cliente_nome 
            FROM notificacoes n 
            LEFT JOIN clientes c ON n.cliente_id = c.id 
            ORDER BY n.created_at DESC 
            LIMIT 20
            """
            notificacoes = self.app.db.execute_query(query)
        except:
            notificacoes = []
            print("Aviso: Tabela notificacoes não encontrada")
        
        for widget in self.historico_frame.winfo_children():
            widget.destroy()
        
        for notif in notificacoes:
            self.create_notificacao_item(notif)
    
    def create_notificacao_item(self, notif):
        item = ctk.CTkFrame(self.historico_frame, fg_color=COLORS['background'], corner_radius=10)
        item.pack(fill="x", pady=5)
        
        content = ctk.CTkFrame(item, fg_color="transparent")
        content.pack(fill="both", padx=15, pady=15)
        
        # Header
        header_frame = ctk.CTkFrame(content, fg_color="transparent")
        header_frame.pack(fill="x")
        
        ctk.CTkLabel(header_frame, text=notif['titulo'], 
                   font=("Arial", 14, "bold"), text_color=COLORS['text_primary']).pack(side="left")
        
        status_text = "✅ Enviado" if notif['enviado'] else "⏳ Pendente"
        ctk.CTkLabel(header_frame, text=status_text, 
                   font=("Arial", 10), text_color=COLORS['success']).pack(side="right")
        
        # Detalhes
        if notif['cliente_nome']:
            ctk.CTkLabel(content, text=f"Para: {notif['cliente_nome']}", 
                       font=("Arial", 11), text_color=COLORS['text_secondary']).pack(anchor="w")
        else:
            ctk.CTkLabel(content, text="Para: Todos os clientes", 
                       font=("Arial", 11), text_color=COLORS['text_secondary']).pack(anchor="w")
        
        ctk.CTkLabel(content, text=f"Tipo: {notif['tipo'].title()}", 
                   font=("Arial", 11), text_color=COLORS['text_secondary']).pack(anchor="w")
        
        # Mensagem (truncada)
        mensagem = notif['mensagem'][:100] + "..." if len(notif['mensagem']) > 100 else notif['mensagem']
        ctk.CTkLabel(content, text=mensagem, 
                   font=("Arial", 10), text_color=COLORS['text_secondary']).pack(anchor="w")
    
    def enviar_notificacao(self):
        titulo = self.titulo_entry.get().strip()
        mensagem = self.mensagem_text.get("1.0", "end-1c").strip()
        cliente_text = self.cliente_var.get()
        tipo = self.tipo_var.get()
        
        if not titulo or not mensagem:
            messagebox.showerror("Erro", "Título e mensagem são obrigatórios!")
            return
        
        try:
            cliente_id = None
            if cliente_text:
                cliente_id = int(cliente_text.split(' - ')[0])
            
            query = """INSERT INTO notificacoes (titulo, mensagem, cliente_id, tipo, enviado) 
                      VALUES (%s, %s, %s, %s, %s)"""
            params = (titulo, mensagem, cliente_id, tipo, True)
            
            self.app.db.execute_insert(query, params)
            
            messagebox.showinfo("Sucesso", "Notificação enviada com sucesso!")
            
            # Limpar formulário
            self.titulo_entry.delete(0, 'end')
            self.mensagem_text.delete("1.0", "end")
            self.cliente_var.set("")
            
            # Recarregar histórico
            self.load_historico()
            
        except Exception as e:
            messagebox.showerror("Erro", f"Erro ao enviar notificação: {e}")
    
    def show(self):
        self.frame.pack(fill="both", expand=True)
        
    def hide(self):
        self.frame.pack_forget()

class BaguncartAdminApp:
    """Aplicação principal do admin"""
    def __init__(self):
        self.root = ctk.CTk()
        self.root.title("BagunçArt - Sistema Administrativo")
        self.root.geometry("900x700")
        self.root.minsize(400, 500)
        
        # Variáveis
        self.current_user = None
        self.db = Database()
        
        # Configurar
        self.root.configure(fg_color=COLORS['background'])
        
        # Bind para responsividade
        self.root.bind('<Configure>', self.on_window_resize)
        
        # Criar telas
        self.login_screen = LoginScreen(self.root, self)
        self.menu_screen = MenuScreen(self.root, self)
        self.clientes_screen = ClientesScreen(self.root, self)
        self.cadastro_screen = CadastroScreen(self.root, self)
        self.contratos_screen = ContratosScreen(self.root, self)
        self.promocao_screen = PromocaoScreen(self.root, self)
        self.notificacao_screen = NotificacaoScreen(self.root, self)
        self.servicos_screen = ServicosScreen(self.root, self)
        
        # Inicializar
        self.init_database()
        self.show_login()
        
    def on_window_resize(self, event):
        """Callback para redimensionamento"""
        if event.widget == self.root:
            # Atualização simples apenas dos atributos de layout
            try:
                for screen in [self.login_screen, self.menu_screen, self.clientes_screen, 
                              self.cadastro_screen, self.contratos_screen, self.promocao_screen, 
                              self.notificacao_screen, self.servicos_screen]:
                    if hasattr(screen, 'update_layout'):
                        screen.update_layout()
            except Exception as e:
                # Evita erros de callback
                pass
    
    def init_database(self):
        """Inicializar banco"""
        try:
            if self.db.connect():
                print("✅ Conectado ao banco MySQL")
                self.db.init_tables()
            else:
                print("⚠️ Erro na conexão")
        except Exception as e:
            print(f"⚠️ Erro: {e}")
    
    def hide_all_screens(self):
        """Ocultar todas as telas"""
        for screen in [self.login_screen, self.menu_screen, self.clientes_screen, 
                      self.cadastro_screen, self.contratos_screen, self.promocao_screen, 
                      self.notificacao_screen, self.servicos_screen]:
            screen.hide()
    
    def show_login(self):
        self.hide_all_screens()
        self.login_screen.show()
    
    def show_menu(self):
        self.hide_all_screens()
        self.menu_screen.show()
    
    def show_clientes(self):
        self.hide_all_screens()
        self.clientes_screen.show()
    
    def show_cadastro(self):
        self.hide_all_screens()
        self.cadastro_screen.show()
    
    def show_contratos(self):
        self.hide_all_screens()
        self.contratos_screen.show()
    
    def show_promocao(self):
        self.hide_all_screens()
        self.promocao_screen.show()
    
    def show_notificacao(self):
        self.hide_all_screens()
        self.notificacao_screen.show()
    
    def show_servicos(self):
        self.hide_all_screens()
        self.servicos_screen.show()
    
    def logout(self):
        self.current_user = None
        self.show_login()
        messagebox.showinfo("Logout", "Logout realizado com sucesso!")
    
    def run(self):
        print("🎉 BagunçArt Admin iniciado!")
        print("📱 Layout responsivo: 1, 2 ou 3 colunas")
        print("💾 Sistema funcional com MySQL")
        print("🏢 Gerenciamento completo de clientes")
        self.root.mainloop()

if __name__ == "__main__":
    try:
        import customtkinter
        from PIL import Image
    except ImportError as e:
        print(f"❌ Biblioteca não encontrada: {e}")
        print("📦 Instale com: pip install customtkinter pillow")
        exit(1)
    
    app = BaguncartAdminApp()
    app.run()