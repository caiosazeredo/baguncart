#!/usr/bin/env python3
# baguncart_cliente.py - Aplicação do Cliente BagunçArt

import customtkinter as ctk
import tkinter as tk
from tkinter import messagebox
from PIL import Image, ImageTk
import mysql.connector
import bcrypt
import threading
import time
from datetime import datetime, timedelta
import re
import os
import webbrowser

# Configuração do banco (mesmo do admin)
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

class LoginScreen:
    def __init__(self, parent, app):
        self.parent = parent
        self.app = app
        self.frame = ctk.CTkFrame(parent, fg_color=COLORS['background'])
        self.create_widgets()
        
    def create_widgets(self):
        main_container = ctk.CTkFrame(self.frame, fg_color="transparent")
        main_container.pack(fill="both", expand=True, padx=40, pady=40)
        
        # Logo - espaço para imagem
        logo_frame = ctk.CTkFrame(main_container, fg_color="transparent", height=300)
        logo_frame.pack(fill="x", pady=(0, 50))
        logo_frame.pack_propagate(False)
        
        # Tentar carregar logo
        try:
            if os.path.exists("assets/bagunca.png"):
                logo_image = Image.open("assets/bagunca.png")
                logo_image = logo_image.resize((200, 150), Image.Resampling.LANCZOS)
                logo_photo = ctk.CTkImage(light_image=logo_image, size=(200, 150))
                
                logo_label = ctk.CTkLabel(logo_frame, image=logo_photo, text="")
                logo_label.pack(pady=30)
            else:
                # Logo placeholder com cores da imagem 5
                logo_space = ctk.CTkFrame(logo_frame, fg_color="transparent", height=150)
                logo_space.pack(pady=30, fill="x")
                
                logo_text = ctk.CTkLabel(logo_space, text="BagunçArt", 
                                       font=("Arial", 32, "bold"), text_color=COLORS['primary'])
                logo_text.pack(expand=True)
        except Exception as e:
            print(f"Erro ao carregar logo: {e}")
            logo_space = ctk.CTkFrame(logo_frame, fg_color="transparent", height=150)
            logo_space.pack(pady=30, fill="x")
            
            logo_text = ctk.CTkLabel(logo_space, text="BagunçArt", 
                                   font=("Arial", 32, "bold"), text_color=COLORS['primary'])
            logo_text.pack(expand=True)
        
        # Formulário simples como na imagem 5
        form_frame = ctk.CTkFrame(main_container, fg_color="transparent")
        form_frame.pack(fill="x", pady=50)
        
        # Campo CPF
        self.cpf_entry = ctk.CTkEntry(form_frame, placeholder_text="CPF", 
                                    height=60, font=("Arial", 16),
                                    corner_radius=15, border_width=2)
        self.cpf_entry.pack(fill="x", pady=(0, 20))
        
        # Campo Senha com toggle
        senha_frame = ctk.CTkFrame(form_frame, fg_color="transparent")
        senha_frame.pack(fill="x", pady=(0, 40))
        
        self.senha_entry = ctk.CTkEntry(senha_frame, placeholder_text="Senha", 
                                      height=60, font=("Arial", 16), show="*",
                                      corner_radius=15, border_width=2)
        self.senha_entry.pack(side="left", fill="x", expand=True)
        
        self.toggle_btn = ctk.CTkButton(senha_frame, text="👁", width=60, height=60,
                                      command=self.toggle_password, 
                                      fg_color=COLORS['surface'],
                                      text_color=COLORS['primary'], 
                                      hover_color=COLORS['background'],
                                      corner_radius=15, border_width=2,
                                      border_color=COLORS['primary'])
        self.toggle_btn.pack(side="right", padx=(15, 0))
        
        # Botão Entrar - laranja como na imagem
        self.login_btn = ctk.CTkButton(form_frame, text="Entrar", height=60,
                                     font=("Arial", 18, "bold"), 
                                     fg_color=COLORS['secondary'],
                                     hover_color=COLORS['secondary'], 
                                     command=self.login, corner_radius=30)
        self.login_btn.pack(fill="x", pady=20)
        
        # Link esqueceu senha
        forgot_btn = ctk.CTkButton(form_frame, text="Esqueceu a senha?", 
                                 fg_color="transparent", 
                                 text_color=COLORS['text_secondary'],
                                 hover_color=COLORS['background'],
                                 command=self.forgot_password)
        forgot_btn.pack(pady=20)
    
    def toggle_password(self):
        if self.senha_entry.cget("show") == "*":
            self.senha_entry.configure(show="")
            self.toggle_btn.configure(text="🙈")
        else:
            self.senha_entry.configure(show="*")
            self.toggle_btn.configure(text="👁")
    
    def login(self):
        cpf = self.cpf_entry.get().strip()
        senha = self.senha_entry.get().strip()
        
        if not cpf or not senha:
            messagebox.showerror("Erro", "Preencha todos os campos!")
            return
        
        cpf_clean = re.sub(r'\D', '', cpf)
        loading = LoadingDialog(self.parent, "Autenticando...")
        
        def authenticate():
            time.sleep(1.5)
            
            # Buscar cliente no banco
            query = "SELECT * FROM clientes WHERE cpf = %s"
            cliente = self.app.db.execute_query(query, (cpf_clean,))
            
            if cliente and cliente[0]['senha']:
                # Verificar senha
                senha_hash = cliente[0]['senha']
                if bcrypt.checkpw(senha.encode('utf-8'), senha_hash.encode('utf-8')):
                    self.app.current_user = cliente[0]
                    
                    self.parent.after(0, lambda: [
                        loading.destroy(),
                        self.app.show_home(),
                        messagebox.showinfo("Sucesso", f"Bem-vindo, {cliente[0]['nome']}!")
                    ])
                else:
                    self.parent.after(0, lambda: [
                        loading.destroy(),
                        messagebox.showerror("Erro", "CPF ou senha incorretos!")
                    ])
            else:
                self.parent.after(0, lambda: [
                    loading.destroy(),
                    messagebox.showerror("Erro", "Cliente não encontrado ou sem senha cadastrada!")
                ])
        
        threading.Thread(target=authenticate, daemon=True).start()
    
    def forgot_password(self):
        messagebox.showinfo("Esqueceu a senha", "Entre em contato com a BagunçArt para redefinir sua senha.")
    
    def show(self):
        self.frame.pack(fill="both", expand=True)
        
    def hide(self):
        self.frame.pack_forget()

class HomeScreen:
    def __init__(self, parent, app):
        self.parent = parent
        self.app = app
        self.frame = ctk.CTkFrame(parent, fg_color=COLORS['background'])
        self.create_widgets()
        
    def create_widgets(self):
        # Container principal
        main_container = ctk.CTkScrollableFrame(self.frame, fg_color="transparent")
        main_container.pack(fill="both", expand=True)
        
        # Header com logo
        self.create_header(main_container)
        
        # Nome do usuário
        user_frame = ctk.CTkFrame(main_container, fg_color="transparent")
        user_frame.pack(fill="x", padx=20, pady=(20, 0))
        
        user_label = ctk.CTkLabel(user_frame, text="👤 Carregando...", 
                                font=("Arial", 18), text_color=COLORS['text_primary'])
        user_label.pack(side="left")
        
        # Card principal de contagem regressiva (baseado na imagem 4)
        self.create_countdown_card(main_container)
        
        # Navigation bar
        self.create_bottom_nav()
        
        # Footer com redes sociais
        self.create_footer(main_container)
        
        # Atualizar dados do usuário
        if self.app.current_user:
            user_label.configure(text=f"👤 {self.app.current_user['nome']}")
            self.load_next_event()
    
    def create_header(self, parent):
        """Criar header com logo"""
        header_frame = ctk.CTkFrame(parent, fg_color="transparent", height=100)
        header_frame.pack(fill="x", padx=20, pady=20)
        header_frame.pack_propagate(False)
        
        # Botão voltar
        back_btn = ctk.CTkButton(header_frame, text="←", width=40, height=40,
                               fg_color=COLORS['primary'], command=self.app.show_login,
                               font=("Arial", 20))
        back_btn.pack(side="left", pady=20)
        
        # Logo centralizada
        try:
            if os.path.exists("assets/bagunca.png"):
                logo_image = Image.open("assets/bagunca.png")
                logo_image = logo_image.resize((150, 80), Image.Resampling.LANCZOS)
                logo_photo = ctk.CTkImage(light_image=logo_image, size=(150, 80))
                
                logo_label = ctk.CTkLabel(header_frame, image=logo_photo, text="")
                logo_label.pack(expand=True, pady=20)
            else:
                logo_label = ctk.CTkLabel(header_frame, text="BagunçArt", 
                                        font=("Arial", 24, "bold"), text_color=COLORS['primary'])
                logo_label.pack(expand=True, pady=20)
        except:
            logo_label = ctk.CTkLabel(header_frame, text="BagunçArt", 
                                    font=("Arial", 24, "bold"), text_color=COLORS['primary'])
            logo_label.pack(expand=True, pady=20)
    
    def create_countdown_card(self, parent):
        """Criar card de contagem regressiva (baseado na imagem 4)"""
        self.countdown_frame = ctk.CTkFrame(parent, fg_color=COLORS['primary'], 
                                          corner_radius=20, height=300)
        self.countdown_frame.pack(fill="x", padx=20, pady=30)
        self.countdown_frame.pack_propagate(False)
        
        content_frame = ctk.CTkFrame(self.countdown_frame, fg_color="transparent")
        content_frame.pack(fill="both", expand=True, padx=30, pady=30)
        
        # Texto de boas-vindas
        welcome_label = ctk.CTkLabel(content_frame, text="Seja Bem Vindo a", 
                                   font=("Arial", 16), text_color="white")
        welcome_label.pack()
        
        company_label = ctk.CTkLabel(content_frame, text="BAGUNÇART EVENTOS", 
                                   font=("Arial", 20, "bold"), text_color=COLORS['secondary'])
        company_label.pack(pady=5)
        
        # Contagem regressiva
        self.countdown_number = ctk.CTkLabel(content_frame, text="--", 
                                           font=("Arial", 60, "bold"), text_color=COLORS['secondary'])
        self.countdown_number.pack(pady=10)
        
        self.countdown_text = ctk.CTkLabel(content_frame, text="DIAS\nPara o melhor dia de todos", 
                                         font=("Arial", 16), text_color="white")
        self.countdown_text.pack()
        
        # Data do evento
        self.event_info = ctk.CTkLabel(content_frame, text="", 
                                     font=("Arial", 14, "bold"), text_color="white")
        self.event_info.pack(pady=10)
    
    def create_bottom_nav(self):
        """Criar navegação inferior (baseado nas imagens)"""
        nav_frame = ctk.CTkFrame(self.frame, fg_color=COLORS['surface'], height=80)
        nav_frame.pack(side="bottom", fill="x")
        nav_frame.pack_propagate(False)
        
        nav_content = ctk.CTkFrame(nav_frame, fg_color="transparent")
        nav_content.pack(fill="both", expand=True, padx=20, pady=10)
        
        # Configurar grid
        nav_content.grid_columnconfigure((0, 1, 2), weight=1)
        
        # Botão HOME (roxo quando ativo)
        home_btn = ctk.CTkButton(nav_content, text="🏠\nHOME", 
                               font=("Arial", 12, "bold"), 
                               fg_color=COLORS['primary'],
                               text_color="white", corner_radius=10)
        home_btn.grid(row=0, column=0, padx=5, sticky="ew")
        
        # Botão CONTRATO (laranja)
        contrato_btn = ctk.CTkButton(nav_content, text="📄\nCONTRATO", 
                                   font=("Arial", 12, "bold"),
                                   fg_color=COLORS['secondary'],
                                   text_color="white", corner_radius=10,
                                   command=self.app.show_contratos)
        contrato_btn.grid(row=0, column=1, padx=5, sticky="ew")
        
        # Botão NOTIFICAÇÃO (laranja)
        notif_btn = ctk.CTkButton(nav_content, text="🔔\nNOTIFICAÇÃO", 
                                font=("Arial", 12, "bold"),
                                fg_color=COLORS['secondary'],
                                text_color="white", corner_radius=10,
                                command=self.app.show_notificacoes)
        notif_btn.grid(row=0, column=2, padx=5, sticky="ew")
    
    def create_footer(self, parent):
        """Criar footer com redes sociais (baseado nas imagens)"""
        footer_frame = ctk.CTkFrame(parent, fg_color=COLORS['secondary'], height=80)
        footer_frame.pack(fill="x", side="bottom")
        footer_frame.pack_propagate(False)
        
        footer_content = ctk.CTkFrame(footer_frame, fg_color="transparent")
        footer_content.pack(fill="both", expand=True, padx=20, pady=15)
        
        # Configurar grid para 4 botões
        footer_content.grid_columnconfigure((0, 1, 2, 3), weight=1)
        
        # Botões de redes sociais
        whatsapp_btn = ctk.CTkButton(footer_content, text="📱", width=50, height=50,
                                   fg_color=COLORS['surface'], text_color=COLORS['secondary'],
                                   corner_radius=10, command=lambda: self.open_social("whatsapp"))
        whatsapp_btn.grid(row=0, column=0, padx=5)
        
        instagram_btn = ctk.CTkButton(footer_content, text="📷", width=50, height=50,
                                    fg_color=COLORS['surface'], text_color=COLORS['secondary'],
                                    corner_radius=10, command=lambda: self.open_social("instagram"))
        instagram_btn.grid(row=0, column=1, padx=5)
        
        facebook_btn = ctk.CTkButton(footer_content, text="🅵", width=50, height=50,
                                   fg_color=COLORS['surface'], text_color=COLORS['secondary'],
                                   corner_radius=10, command=lambda: self.open_social("facebook"))
        facebook_btn.grid(row=0, column=2, padx=5)
        
        youtube_btn = ctk.CTkButton(footer_content, text="▶️", width=50, height=50,
                                  fg_color=COLORS['surface'], text_color=COLORS['secondary'],
                                  corner_radius=10, command=lambda: self.open_social("youtube"))
        youtube_btn.grid(row=0, column=3, padx=5)
    
    def load_next_event(self):
        """Carregar próximo evento do cliente"""
        if not self.app.current_user:
            return
        
        query = """
        SELECT * FROM contratos 
        WHERE cliente_id = %s AND data_evento >= CURDATE() 
        ORDER BY data_evento ASC 
        LIMIT 1
        """
        contratos = self.app.db.execute_query(query, (self.app.current_user['id'],))
        
        if contratos:
            contrato = contratos[0]
            data_evento = contrato['data_evento']
            
            # Calcular dias restantes
            hoje = datetime.now().date()
            dias_restantes = (data_evento - hoje).days
            
            self.countdown_number.configure(text=str(dias_restantes))
            self.event_info.configure(text=f"DIA ESPECIAL\n{data_evento.strftime('%d/%m/%y')}")
            
            # Atualizar contagem a cada segundo
            self.update_countdown()
        else:
            self.countdown_number.configure(text="--")
            self.countdown_text.configure(text="Nenhum evento agendado")
            self.event_info.configure(text="")
    
    def update_countdown(self):
        """Atualizar contagem regressiva em tempo real"""
        # Agendar próxima atualização
        self.parent.after(60000, self.update_countdown)  # Atualizar a cada minuto
    
    def open_social(self, platform):
        """Abrir redes sociais"""
        urls = {
            "whatsapp": "https://wa.me/5521999999999",
            "instagram": "https://instagram.com/baguncart",
            "facebook": "https://facebook.com/baguncart",
            "youtube": "https://youtube.com/@baguncart"
        }
        
        try:
            webbrowser.open(urls.get(platform, ""))
        except:
            messagebox.showinfo("Redes Sociais", f"Abrir {platform.title()}")
    
    def show(self):
        self.frame.pack(fill="both", expand=True)
        
    def hide(self):
        self.frame.pack_forget()

class ContratosScreen:
    def __init__(self, parent, app):
        self.parent = parent
        self.app = app
        self.frame = ctk.CTkFrame(parent, fg_color=COLORS['background'])
        self.current_contrato = None
        self.create_widgets()
        
    def create_widgets(self):
        # Container principal
        main_container = ctk.CTkScrollableFrame(self.frame, fg_color="transparent")
        main_container.pack(fill="both", expand=True)
        
        # Header com logo e voltar
        self.create_header(main_container)
        
        # Container para alternar entre lista e detalhes
        self.content_frame = ctk.CTkFrame(main_container, fg_color="transparent")
        self.content_frame.pack(fill="both", expand=True, padx=20)
        
        # Tela de lista de contratos
        self.lista_frame = ctk.CTkFrame(self.content_frame, fg_color="transparent")
        self.criar_lista_contratos()
        
        # Tela de detalhes do contrato
        self.detalhes_frame = ctk.CTkFrame(self.content_frame, fg_color="transparent")
        self.criar_detalhes_contrato()
        
        # Navigation bar
        self.create_bottom_nav()
        
        # Footer
        self.create_footer(main_container)
        
        # Mostrar lista inicialmente
        self.show_lista()
    
    def create_header(self, parent):
        """Criar header"""
        header_frame = ctk.CTkFrame(parent, fg_color="transparent", height=100)
        header_frame.pack(fill="x", padx=20, pady=20)
        header_frame.pack_propagate(False)
        
        # Botão voltar
        back_btn = ctk.CTkButton(header_frame, text="←", width=40, height=40,
                               fg_color=COLORS['primary'], command=self.app.show_home,
                               font=("Arial", 20))
        back_btn.pack(side="left", pady=20)
        
        # Logo
        try:
            if os.path.exists("assets/bagunca.png"):
                logo_image = Image.open("assets/bagunca.png")
                logo_image = logo_image.resize((150, 80), Image.Resampling.LANCZOS)
                logo_photo = ctk.CTkImage(light_image=logo_image, size=(150, 80))
                
                logo_label = ctk.CTkLabel(header_frame, image=logo_photo, text="")
                logo_label.pack(expand=True, pady=20)
            else:
                logo_label = ctk.CTkLabel(header_frame, text="BagunçArt", 
                                        font=("Arial", 24, "bold"), text_color=COLORS['primary'])
                logo_label.pack(expand=True, pady=20)
        except:
            logo_label = ctk.CTkLabel(header_frame, text="BagunçArt", 
                                    font=("Arial", 24, "bold"), text_color=COLORS['primary'])
            logo_label.pack(expand=True, pady=20)
    
    def criar_lista_contratos(self):
        """Criar lista de contratos (baseado na imagem 3)"""
        # Título
        titulo = ctk.CTkLabel(self.lista_frame, text="CONTRATOS", 
                            font=("Arial", 24, "bold"), text_color=COLORS['primary'])
        titulo.pack(pady=20)
        
        # Lista de contratos
        self.contratos_list_frame = ctk.CTkFrame(self.lista_frame, fg_color="transparent")
        self.contratos_list_frame.pack(fill="both", expand=True)
    
    def criar_detalhes_contrato(self):
        """Criar tela de detalhes do contrato (baseado na imagem 2)"""
        # Título
        titulo = ctk.CTkLabel(self.detalhes_frame, text="CONTRATO", 
                            font=("Arial", 24, "bold"), text_color=COLORS['secondary'])
        titulo.pack(pady=20)
        
        # Card principal do contrato
        self.contrato_card = ctk.CTkFrame(self.detalhes_frame, fg_color=COLORS['primary'], 
                                        corner_radius=20)
        self.contrato_card.pack(fill="x", pady=20)
        
        # Conteúdo do card será preenchido dinamicamente
    
    def create_bottom_nav(self):
        """Criar navegação inferior"""
        nav_frame = ctk.CTkFrame(self.frame, fg_color=COLORS['surface'], height=80)
        nav_frame.pack(side="bottom", fill="x")
        nav_frame.pack_propagate(False)
        
        nav_content = ctk.CTkFrame(nav_frame, fg_color="transparent")
        nav_content.pack(fill="both", expand=True, padx=20, pady=10)
        
        nav_content.grid_columnconfigure((0, 1, 2), weight=1)
        
        # Botão HOME (laranja)
        home_btn = ctk.CTkButton(nav_content, text="🏠\nHOME", 
                               font=("Arial", 12, "bold"), 
                               fg_color=COLORS['secondary'],
                               text_color="white", corner_radius=10,
                               command=self.app.show_home)
        home_btn.grid(row=0, column=0, padx=5, sticky="ew")
        
        # Botão CONTRATO (roxo quando ativo)
        contrato_btn = ctk.CTkButton(nav_content, text="📄\nCONTRATO", 
                                   font=("Arial", 12, "bold"),
                                   fg_color=COLORS['primary'],
                                   text_color="white", corner_radius=10)
        contrato_btn.grid(row=0, column=1, padx=5, sticky="ew")
        
        # Botão NOTIFICAÇÃO (laranja)
        notif_btn = ctk.CTkButton(nav_content, text="🔔\nNOTIFICAÇÃO", 
                                font=("Arial", 12, "bold"),
                                fg_color=COLORS['secondary'],
                                text_color="white", corner_radius=10,
                                command=self.app.show_notificacoes)
        notif_btn.grid(row=0, column=2, padx=5, sticky="ew")
    
    def create_footer(self, parent):
        """Criar footer com redes sociais"""
        footer_frame = ctk.CTkFrame(parent, fg_color=COLORS['secondary'], height=80)
        footer_frame.pack(fill="x", side="bottom")
        footer_frame.pack_propagate(False)
        
        footer_content = ctk.CTkFrame(footer_frame, fg_color="transparent")
        footer_content.pack(fill="both", expand=True, padx=20, pady=15)
        
        footer_content.grid_columnconfigure((0, 1, 2, 3), weight=1)
        
        # Botões de redes sociais
        social_buttons = ["📱", "📷", "🅵", "▶️"]
        for i, icon in enumerate(social_buttons):
            btn = ctk.CTkButton(footer_content, text=icon, width=50, height=50,
                              fg_color=COLORS['surface'], text_color=COLORS['secondary'],
                              corner_radius=10)
            btn.grid(row=0, column=i, padx=5)
    
    def show_lista(self):
        """Mostrar lista de contratos"""
        self.detalhes_frame.pack_forget()
        self.lista_frame.pack(fill="both", expand=True)
        self.load_contratos()
    
    def show_detalhes(self, contrato):
        """Mostrar detalhes do contrato"""
        self.current_contrato = contrato
        self.lista_frame.pack_forget()
        self.detalhes_frame.pack(fill="both", expand=True)
        self.load_contrato_detalhes()
    
    def load_contratos(self):
        """Carregar contratos do cliente"""
        if not self.app.current_user:
            return
        
        query = """
        SELECT c.*, 
               GROUP_CONCAT(s.nome SEPARATOR ', ') as servicos,
               SUM(cs.preco_unitario * cs.quantidade) as valor_servicos
        FROM contratos c
        LEFT JOIN contrato_servicos cs ON c.id = cs.contrato_id
        LEFT JOIN servicos s ON cs.servico_id = s.id
        WHERE c.cliente_id = %s
        GROUP BY c.id
        ORDER BY c.data_evento DESC
        """
        
        contratos = self.app.db.execute_query(query, (self.app.current_user['id'],))
        
        # Limpar lista atual
        for widget in self.contratos_list_frame.winfo_children():
            widget.destroy()
        
        if not contratos:
            no_data = ctk.CTkLabel(self.contratos_list_frame, text="Nenhum contrato encontrado", 
                                 font=("Arial", 16), text_color=COLORS['text_secondary'])
            no_data.pack(pady=50)
            return
        
        # Criar itens da lista (baseado na imagem 3)
        for contrato in contratos:
            self.create_contrato_item(contrato)
    
    def create_contrato_item(self, contrato):
        """Criar item de contrato na lista"""
        item = ctk.CTkFrame(self.contratos_list_frame, fg_color=COLORS['secondary'], 
                          corner_radius=15, height=100)
        item.pack(fill="x", pady=10)
        item.pack_propagate(False)
        
        # Tornar clicável
        item.bind("<Button-1>", lambda e: self.show_detalhes(contrato))
        
        content = ctk.CTkFrame(item, fg_color="transparent")
        content.pack(fill="both", padx=20, pady=15)
        
        # Informações do contrato
        info_frame = ctk.CTkFrame(content, fg_color="transparent")
        info_frame.pack(side="left", fill="both", expand=True)
        
        ctk.CTkLabel(info_frame, text=f"Contrato - {contrato['numero']}", 
                   font=("Arial", 16, "bold"), text_color="white").pack(anchor="w")
        ctk.CTkLabel(info_frame, text=f"Contratante - {self.app.current_user['nome']}", 
                   font=("Arial", 12), text_color="white").pack(anchor="w")
        if contrato['data_evento']:
            ctk.CTkLabel(info_frame, text=f"Data: {contrato['data_evento'].strftime('%d/%m/%y')}", 
                       font=("Arial", 12), text_color="white").pack(anchor="w")
        
        # Ícone de download
        download_btn = ctk.CTkButton(content, text="📄", width=50, height=50,
                                   fg_color="white", text_color=COLORS['secondary'],
                                   command=lambda: self.download_contrato(contrato))
        download_btn.pack(side="right")
    
    def load_contrato_detalhes(self):
        """Carregar detalhes do contrato (baseado na imagem 2)"""
        if not self.current_contrato:
            return
        
        # Limpar card atual
        for widget in self.contrato_card.winfo_children():
            widget.destroy()
        
        # Preencher card com detalhes
        content = ctk.CTkFrame(self.contrato_card, fg_color="transparent")
        content.pack(fill="both", padx=30, pady=30)
        
        # Informações básicas
        ctk.CTkLabel(content, text=f"Contrato: {self.current_contrato['numero']}", 
                   font=("Arial", 16, "bold"), text_color="white").pack(anchor="w")
        ctk.CTkLabel(content, text=f"Contratante: {self.app.current_user['nome']}", 
                   font=("Arial", 14), text_color="white").pack(anchor="w", pady=5)
        
        if self.current_contrato['data_evento']:
            ctk.CTkLabel(content, text=f"Data do Evento: {self.current_contrato['data_evento'].strftime('%d/%m/%Y')}", 
                       font=("Arial", 14), text_color="white").pack(anchor="w", pady=5)
        
        if self.current_contrato['local_evento']:
            ctk.CTkLabel(content, text=f"Local do Evento: {self.current_contrato['local_evento']}", 
                       font=("Arial", 14), text_color="white").pack(anchor="w", pady=5)
        
        # Serviços contratados
        ctk.CTkLabel(content, text="Serviços contratados:", 
                   font=("Arial", 14, "bold"), text_color="white").pack(anchor="w", pady=(15, 5))
        
        # Buscar serviços do contrato
        servicos_query = """
        SELECT s.nome, cs.preco_unitario, cs.quantidade
        FROM contrato_servicos cs
        JOIN servicos s ON cs.servico_id = s.id
        WHERE cs.contrato_id = %s
        """
        servicos = self.app.db.execute_query(servicos_query, (self.current_contrato['id'],))
        
        # Mostrar serviços como na imagem 2
        for servico in servicos:
            servico_text = f"• {servico['nome']}"
            if servico['preco_unitario']:
                servico_text += f" - R${servico['preco_unitario']:.2f}"
            
            ctk.CTkLabel(content, text=servico_text, 
                       font=("Arial", 12), text_color="white").pack(anchor="w")
        
        # Valor total
        if self.current_contrato['valor_total']:
            ctk.CTkLabel(content, text=f"Valor Total: R${self.current_contrato['valor_total']:.2f}", 
                       font=("Arial", 16, "bold"), text_color="white").pack(anchor="w", pady=(15, 0))
        
        # Botão voltar para lista
        voltar_btn = ctk.CTkButton(content, text="← Voltar para Lista", 
                                 fg_color=COLORS['secondary'], command=self.show_lista)
        voltar_btn.pack(pady=20)
    
    def download_contrato(self, contrato):
        """Simular download do contrato"""
        messagebox.showinfo("Download", f"Download do contrato {contrato['numero']} iniciado!")
    
    def show(self):
        self.frame.pack(fill="both", expand=True)
        
    def hide(self):
        self.frame.pack_forget()

class NotificacoesScreen:
    def __init__(self, parent, app):
        self.parent = parent
        self.app = app
        self.frame = ctk.CTkFrame(parent, fg_color=COLORS['background'])
        self.create_widgets()
        
    def create_widgets(self):
        # Container principal
        main_container = ctk.CTkScrollableFrame(self.frame, fg_color="transparent")
        main_container.pack(fill="both", expand=True)
        
        # Header
        self.create_header(main_container)
        
        # Container de notificações
        self.notif_container = ctk.CTkFrame(main_container, fg_color="transparent")
        self.notif_container.pack(fill="both", expand=True, padx=20)
        
        # Navigation bar
        self.create_bottom_nav()
        
        # Footer
        self.create_footer(main_container)
        
        # Carregar notificações
        self.load_notificacoes()
    
    def create_header(self, parent):
        """Criar header"""
        header_frame = ctk.CTkFrame(parent, fg_color="transparent", height=100)
        header_frame.pack(fill="x", padx=20, pady=20)
        header_frame.pack_propagate(False)
        
        # Botão voltar
        back_btn = ctk.CTkButton(header_frame, text="←", width=40, height=40,
                               fg_color=COLORS['primary'], command=self.app.show_home,
                               font=("Arial", 20))
        back_btn.pack(side="left", pady=20)
        
        # Logo
        try:
            if os.path.exists("assets/bagunca.png"):
                logo_image = Image.open("assets/bagunca.png")
                logo_image = logo_image.resize((150, 80), Image.Resampling.LANCZOS)
                logo_photo = ctk.CTkImage(light_image=logo_image, size=(150, 80))
                
                logo_label = ctk.CTkLabel(header_frame, image=logo_photo, text="")
                logo_label.pack(expand=True, pady=20)
            else:
                logo_label = ctk.CTkLabel(header_frame, text="BagunçArt", 
                                        font=("Arial", 24, "bold"), text_color=COLORS['primary'])
                logo_label.pack(expand=True, pady=20)
        except:
            logo_label = ctk.CTkLabel(header_frame, text="BagunçArt", 
                                    font=("Arial", 24, "bold"), text_color=COLORS['primary'])
            logo_label.pack(expand=True, pady=20)
    
    def create_bottom_nav(self):
        """Criar navegação inferior"""
        nav_frame = ctk.CTkFrame(self.frame, fg_color=COLORS['surface'], height=80)
        nav_frame.pack(side="bottom", fill="x")
        nav_frame.pack_propagate(False)
        
        nav_content = ctk.CTkFrame(nav_frame, fg_color="transparent")
        nav_content.pack(fill="both", expand=True, padx=20, pady=10)
        
        nav_content.grid_columnconfigure((0, 1, 2), weight=1)
        
        # Botão HOME (laranja)
        home_btn = ctk.CTkButton(nav_content, text="🏠\nHOME", 
                               font=("Arial", 12, "bold"), 
                               fg_color=COLORS['secondary'],
                               text_color="white", corner_radius=10,
                               command=self.app.show_home)
        home_btn.grid(row=0, column=0, padx=5, sticky="ew")
        
        # Botão CONTRATO (laranja)
        contrato_btn = ctk.CTkButton(nav_content, text="📄\nCONTRATO", 
                                   font=("Arial", 12, "bold"),
                                   fg_color=COLORS['secondary'],
                                   text_color="white", corner_radius=10,
                                   command=self.app.show_contratos)
        contrato_btn.grid(row=0, column=1, padx=5, sticky="ew")
        
        # Botão NOTIFICAÇÃO (roxo quando ativo)
        notif_btn = ctk.CTkButton(nav_content, text="🔔\nNOTIFICAÇÃO", 
                                font=("Arial", 12, "bold"),
                                fg_color=COLORS['primary'],
                                text_color="white", corner_radius=10)
        notif_btn.grid(row=0, column=2, padx=5, sticky="ew")
    
    def create_footer(self, parent):
        """Criar footer com redes sociais"""
        footer_frame = ctk.CTkFrame(parent, fg_color=COLORS['secondary'], height=80)
        footer_frame.pack(fill="x", side="bottom")
        footer_frame.pack_propagate(False)
        
        footer_content = ctk.CTkFrame(footer_frame, fg_color="transparent")
        footer_content.pack(fill="both", expand=True, padx=20, pady=15)
        
        footer_content.grid_columnconfigure((0, 1, 2, 3), weight=1)
        
        # Botões de redes sociais
        social_buttons = ["📱", "📷", "🅵", "▶️"]
        for i, icon in enumerate(social_buttons):
            btn = ctk.CTkButton(footer_content, text=icon, width=50, height=50,
                              fg_color=COLORS['surface'], text_color=COLORS['secondary'],
                              corner_radius=10)
            btn.grid(row=0, column=i, padx=5)
    
    def load_notificacoes(self):
        """Carregar notificações do cliente"""
        if not self.app.current_user:
            return
        
        # Buscar notificações gerais e específicas do cliente
        query = """
        (SELECT * FROM notificacoes WHERE cliente_id = %s)
        UNION
        (SELECT * FROM notificacoes WHERE cliente_id IS NULL AND tipo = 'promocao')
        ORDER BY created_at DESC
        LIMIT 20
        """
        
        notificacoes = self.app.db.execute_query(query, (self.app.current_user['id'],))
        
        # Buscar também promoções ativas como notificações
        promocoes_query = """
        SELECT titulo, descricao, valor_desconto, porcentagem_desconto, data_fim
        FROM promocoes 
        WHERE ativo = TRUE AND (data_fim IS NULL OR data_fim >= CURDATE())
        ORDER BY created_at DESC
        """
        promocoes = self.app.db.execute_query(promocoes_query)
        
        # Limpar container
        for widget in self.notif_container.winfo_children():
            widget.destroy()
        
        # Mostrar promoções como na imagem 6
        if promocoes:
            for promocao in promocoes:
                self.create_promocao_card(promocao)
        
        # Mostrar notificações regulares
        if notificacoes:
            for notif in notificacoes:
                self.create_notificacao_item(notif)
        
        if not promocoes and not notificacoes:
            no_data = ctk.CTkLabel(self.notif_container, text="Nenhuma notificação encontrada", 
                                 font=("Arial", 16), text_color=COLORS['text_secondary'])
            no_data.pack(pady=50)
    
    def create_promocao_card(self, promocao):
        """Criar card de promoção (baseado na imagem 6)"""
        # Card de atenção/promoção
        promo_card = ctk.CTkFrame(self.notif_container, fg_color=COLORS['primary'], 
                                corner_radius=20, height=120)
        promo_card.pack(fill="x", pady=10)
        promo_card.pack_propagate(False)
        
        content = ctk.CTkFrame(promo_card, fg_color="transparent")
        content.pack(fill="both", padx=30, pady=20)
        
        # Título
        ctk.CTkLabel(content, text="ATENÇÃO", 
                   font=("Arial", 18, "bold"), text_color=COLORS['secondary']).pack()
        ctk.CTkLabel(content, text="PROMOÇÃO RELÂMPAGO", 
                   font=("Arial", 14), text_color="white").pack()
        
        # Descrição da promoção
        if promocao['valor_desconto']:
            desconto_text = f"R${promocao['valor_desconto']:.2f}"
        elif promocao['porcentagem_desconto']:
            desconto_text = f"{promocao['porcentagem_desconto']}%"
        else:
            desconto_text = "Desconto especial"
        
        promo_text = f"{promocao['titulo']}: {desconto_text}"
        ctk.CTkLabel(content, text=promo_text, 
                   font=("Arial", 12, "bold"), text_color=COLORS['secondary']).pack(pady=5)
        
        # Validade
        if promocao['data_fim']:
            ctk.CTkLabel(content, text=f"VÁLIDO ATÉ {promocao['data_fim'].strftime('%d/%m/%y')}", 
                       font=("Arial", 11), text_color="white").pack()
        
        # Card informativo adicional (baseado na imagem 6)
        if len(self.notif_container.winfo_children()) == 1:  # Só no primeiro
            info_card = ctk.CTkFrame(self.notif_container, fg_color=COLORS['primary'], 
                                   corner_radius=20, height=150)
            info_card.pack(fill="x", pady=10)
            info_card.pack_propagate(False)
            
            info_content = ctk.CTkFrame(info_card, fg_color="transparent")
            info_content.pack(fill="both", padx=30, pady=20)
            
            ctk.CTkLabel(info_content, text="FALTAM SÓ 15 DIAS", 
                       font=("Arial", 20, "bold"), text_color=COLORS['secondary']).pack()
            ctk.CTkLabel(info_content, text="Seu evento está prestes a acontecer!\nQualquer ajuda que precisar, entre em\ncontato conosco.", 
                       font=("Arial", 12), text_color="white").pack(pady=10)
    
    def create_notificacao_item(self, notif):
        """Criar item de notificação regular"""
        item = ctk.CTkFrame(self.notif_container, fg_color=COLORS['surface'], 
                          corner_radius=15)
        item.pack(fill="x", pady=5)
        
        content = ctk.CTkFrame(item, fg_color="transparent")
        content.pack(fill="both", padx=20, pady=15)
        
        ctk.CTkLabel(content, text=notif['titulo'], 
                   font=("Arial", 14, "bold"), text_color=COLORS['text_primary']).pack(anchor="w")
        ctk.CTkLabel(content, text=notif['mensagem'], 
                   font=("Arial", 12), text_color=COLORS['text_secondary']).pack(anchor="w")
        
        # Data
        data_texto = notif['created_at'].strftime('%d/%m/%Y %H:%M')
        ctk.CTkLabel(content, text=data_texto, 
                   font=("Arial", 10), text_color=COLORS['text_secondary']).pack(anchor="e")
    
    def show(self):
        self.frame.pack(fill="both", expand=True)
        
    def hide(self):
        self.frame.pack_forget()

class BaguncartClienteApp:
    """Aplicação do cliente"""
    def __init__(self):
        self.root = ctk.CTk()
        self.root.title("BagunçArt - Portal do Cliente")
        self.root.geometry("400x700")
        self.root.minsize(350, 600)
        
        # Variáveis
        self.current_user = None
        self.db = Database()
        
        # Configurar
        self.root.configure(fg_color=COLORS['background'])
        
        # Criar telas
        self.login_screen = LoginScreen(self.root, self)
        self.home_screen = HomeScreen(self.root, self)
        self.contratos_screen = ContratosScreen(self.root, self)
        self.notificacoes_screen = NotificacoesScreen(self.root, self)
        
        # Inicializar
        self.init_database()
        self.show_login()
        
    def init_database(self):
        """Inicializar banco"""
        try:
            if self.db.connect():
                print("✅ Cliente conectado ao banco MySQL")
            else:
                print("⚠️ Erro na conexão")
        except Exception as e:
            print(f"⚠️ Erro: {e}")
    
    def hide_all_screens(self):
        """Ocultar todas as telas"""
        for screen in [self.login_screen, self.home_screen, self.contratos_screen, self.notificacoes_screen]:
            screen.hide()
    
    def show_login(self):
        self.hide_all_screens()
        self.login_screen.show()
    
    def show_home(self):
        self.hide_all_screens()
        self.home_screen.show()
    
    def show_contratos(self):
        self.hide_all_screens()
        self.contratos_screen.show()
    
    def show_notificacoes(self):
        self.hide_all_screens()
        self.notificacoes_screen.show()
    
    def logout(self):
        self.current_user = None
        self.show_login()
        messagebox.showinfo("Logout", "Logout realizado com sucesso!")
    
    def run(self):
        print("🎉 BagunçArt Cliente iniciado!")
        print("📱 Portal do cliente")
        print("🔐 Login com CPF e senha")
        print("📊 Visualização de contratos e notificações")
        self.root.mainloop()

if __name__ == "__main__":
    try:
        import customtkinter
        from PIL import Image
    except ImportError as e:
        print(f"❌ Biblioteca não encontrada: {e}")
        print("📦 Instale com: pip install customtkinter pillow")
        exit(1)
    
    app = BaguncartClienteApp()
    app.run()