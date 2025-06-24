#!/usr/bin/env python3
# main.py - BagunçArt Aplicação Principal

import flet as ft
from flet import icons
import asyncio
from src.config.database import Database
from src.config.database_init import init_database
from src.utils.colors import Colors
from src.views.login_view import LoginView
from src.views.dashboard_view import DashboardView
from src.views.clientes_view import ClientesView
from src.views.cadastro_cliente_view import CadastroClienteView
from src.views.servicos_view import ServicosView
from src.views.contratos_view import ContratosView
from src.views.promocao_view import PromocaoView
from src.views.notificacao_view import NotificacaoView

class BaguncartApp:
    def __init__(self, page: ft.Page):
        self.page = page
        self.db = Database()
        self.current_user = None
        self.current_view = None
        
        # Configurações da página
        self.setup_page()
        
        # Conectar ao banco e inicializar
        self.connect_database()
        
        # Inicializar com tela de login
        self.show_login()

    def setup_page(self):
        """Configurações iniciais da página"""
        self.page.title = "BagunçArt - Gestão de Eventos"
        self.page.theme_mode = ft.ThemeMode.LIGHT
        self.page.padding = 0
        self.page.bgcolor = Colors.WHITE
        
        # Configurações para mobile
        self.page.window.width = 400
        self.page.window.height = 800
        self.page.window.resizable = False
        
        # StatusBar
        self.page.appbar = ft.AppBar(
            title=ft.Text("BagunçArt", color=Colors.WHITE, weight=ft.FontWeight.BOLD),
            bgcolor=Colors.PRIMARY,
            automatically_imply_leading=False,
        )

    def connect_database(self):
        """Conectar ao banco de dados e inicializar tabelas"""
        try:
            if self.db.connect():
                print("✅ Conectado ao banco de dados MySQL")
                
                # Inicializar tabelas
                if init_database(self.db):
                    print("✅ Banco de dados inicializado")
                else:
                    print("⚠️ Erro ao inicializar banco de dados")
                    
                # Criar usuário admin
                from src.services.auth_service import AuthService
                auth_service = AuthService(self.db)
                # O usuário admin já é criado no AuthService
                    
            else:
                print("❌ Erro ao conectar ao banco de dados")
                self.show_error("Erro de conexão com o banco de dados")
        except Exception as e:
            print(f"❌ Erro de conexão: {e}")
            self.show_error("Erro de conexão com o banco de dados")

    def show_error(self, message):
        """Mostrar mensagem de erro"""
        dlg = ft.AlertDialog(
            title=ft.Text("Erro"),
            content=ft.Text(message),
            actions=[
                ft.TextButton("OK", on_click=lambda _: self.close_dialog())
            ],
        )
        self.page.dialog = dlg
        dlg.open = True
        self.page.update()

    def show_success(self, message):
        """Mostrar mensagem de sucesso"""
        dlg = ft.AlertDialog(
            title=ft.Text("Sucesso"),
            content=ft.Text(message),
            actions=[
                ft.TextButton("OK", on_click=lambda _: self.close_dialog())
            ],
        )
        self.page.dialog = dlg
        dlg.open = True
        self.page.update()

    def close_dialog(self):
        """Fechar diálogo"""
        if self.page.dialog:
            self.page.dialog.open = False
            self.page.update()

    def navigate_to(self, view_name, **kwargs):
        """Navegar para uma view específica"""
        if view_name == "login":
            self.show_login()
        elif view_name == "dashboard":
            self.show_dashboard()
        elif view_name == "clientes":
            self.show_clientes()
        elif view_name == "cadastro_cliente":
            self.show_cadastro_cliente(**kwargs)
        elif view_name == "servicos":
            self.show_servicos(**kwargs)
        elif view_name == "contratos":
            self.show_contratos()
        elif view_name == "promocao":
            self.show_promocao()
        elif view_name == "notificacao":
            self.show_notificacao()

    def show_login(self):
        """Mostrar tela de login"""
        self.page.appbar.title = ft.Text("BagunçArt", color=Colors.WHITE, weight=ft.FontWeight.BOLD)
        self.page.appbar.actions = []
        
        self.current_view = LoginView(self.page, self.db, self.on_login_success)
        self.page.clean()
        self.page.add(self.current_view.build())
        self.page.update()

    def on_login_success(self, user_data):
        """Callback para login bem-sucedido"""
        self.current_user = user_data
        self.show_dashboard()

    def show_dashboard(self):
        """Mostrar dashboard principal"""
        self.page.appbar.title = ft.Text("Dashboard", color=Colors.WHITE, weight=ft.FontWeight.BOLD)
        self.page.appbar.actions = [
            ft.IconButton(
                icons.LOGOUT,
                icon_color=Colors.WHITE,
                on_click=lambda _: self.logout()
            )
        ]
        
        self.current_view = DashboardView(self.page, self.db, self.navigate_to, self.current_user)
        self.page.clean()
        self.page.add(self.current_view.build())
        self.page.update()

    def show_clientes(self):
        """Mostrar lista de clientes"""
        self.page.appbar.title = ft.Text("Clientes", color=Colors.WHITE, weight=ft.FontWeight.BOLD)
        self.page.appbar.actions = [
            ft.IconButton(
                icons.PERSON_ADD,
                icon_color=Colors.WHITE,
                on_click=lambda _: self.navigate_to("cadastro_cliente")
            ),
            ft.IconButton(
                icons.HOME,
                icon_color=Colors.WHITE,
                on_click=lambda _: self.navigate_to("dashboard")
            )
        ]
        
        self.current_view = ClientesView(self.page, self.db, self.navigate_to)
        self.page.clean()
        self.page.add(self.current_view.build())
        self.page.update()

    def show_cadastro_cliente(self, cliente=None):
        """Mostrar cadastro de cliente"""
        title = "Editar Cliente" if cliente else "Cadastro Cliente"
        self.page.appbar.title = ft.Text(title, color=Colors.WHITE, weight=ft.FontWeight.BOLD)
        self.page.appbar.actions = [
            ft.IconButton(
                icons.ARROW_BACK,
                icon_color=Colors.WHITE,
                on_click=lambda _: self.navigate_to("clientes")
            )
        ]
        
        self.current_view = CadastroClienteView(
            self.page, self.db, self.navigate_to, 
            self.show_success, self.show_error, cliente
        )
        self.page.clean()
        self.page.add(self.current_view.build())
        self.page.update()

    def show_servicos(self, cliente_data=None):
        """Mostrar seleção de serviços"""
        self.page.appbar.title = ft.Text("Serviços", color=Colors.WHITE, weight=ft.FontWeight.BOLD)
        self.page.appbar.actions = [
            ft.IconButton(
                icons.ARROW_BACK,
                icon_color=Colors.WHITE,
                on_click=lambda _: self.navigate_to("cadastro_cliente")
            )
        ]
        
        self.current_view = ServicosView(
            self.page, self.db, self.navigate_to, 
            self.show_success, self.show_error, cliente_data
        )
        self.page.clean()
        self.page.add(self.current_view.build())
        self.page.update()

    def show_contratos(self):
        """Mostrar lista de contratos"""
        self.page.appbar.title = ft.Text("Contratos", color=Colors.WHITE, weight=ft.FontWeight.BOLD)
        self.page.appbar.actions = [
            ft.IconButton(
                icons.ADD,
                icon_color=Colors.WHITE,
                on_click=lambda _: self.navigate_to("cadastro_cliente")
            ),
            ft.IconButton(
                icons.HOME,
                icon_color=Colors.WHITE,
                on_click=lambda _: self.navigate_to("dashboard")
            )
        ]
        
        self.current_view = ContratosView(self.page, self.db, self.navigate_to)
        self.page.clean()
        self.page.add(self.current_view.build())
        self.page.update()

    def show_promocao(self):
        """Mostrar criação de promoção"""
        self.page.appbar.title = ft.Text("Promoção", color=Colors.WHITE, weight=ft.FontWeight.BOLD)
        self.page.appbar.actions = [
            ft.IconButton(
                icons.ARROW_BACK,
                icon_color=Colors.WHITE,
                on_click=lambda _: self.navigate_to("dashboard")
            )
        ]
        
        self.current_view = PromocaoView(
            self.page, self.db, self.navigate_to, 
            self.show_success, self.show_error
        )
        self.page.clean()
        self.page.add(self.current_view.build())
        self.page.update()

    def show_notificacao(self):
        """Mostrar envio de notificação"""
        self.page.appbar.title = ft.Text("Notificação", color=Colors.WHITE, weight=ft.FontWeight.BOLD)
        self.page.appbar.actions = [
            ft.IconButton(
                icons.ARROW_BACK,
                icon_color=Colors.WHITE,
                on_click=lambda _: self.navigate_to("dashboard")
            )
        ]
        
        self.current_view = NotificacaoView(
            self.page, self.db, self.navigate_to, 
            self.show_success, self.show_error
        )
        self.page.clean()
        self.page.add(self.current_view.build())
        self.page.update()

    def logout(self):
        """Fazer logout"""
        self.current_user = None
        self.show_login()

def main(page: ft.Page):
    """Função principal da aplicação"""
    app = BaguncartApp(page)

if __name__ == "__main__":
    # Executar aplicação
    ft.app(target=main, view=ft.AppView.WEB_BROWSER, port=8080)