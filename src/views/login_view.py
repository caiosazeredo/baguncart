# src/views/login_view.py
import flet as ft
import re
from src.utils.colors import Colors
from src.services.auth_service import AuthService

class LoginView:
    def __init__(self, page, db, on_login_success):
        self.page = page
        self.db = db
        self.on_login_success = on_login_success
        self.auth_service = AuthService(db)
        
        # Campos do formulário
        self.cnpj_field = ft.TextField(
            label="CNPJ",
            hint_text="00.000.000/0000-00",
            border_color=Colors.GRAY,
            focused_border_color=Colors.PRIMARY,
            prefix_icon=ft.icons.BUSINESS,
            max_length=18,
            on_change=self.format_cnpj,
        )
        
        self.senha_field = ft.TextField(
            label="Senha",
            hint_text="Digite sua senha",
            border_color=Colors.GRAY,
            focused_border_color=Colors.PRIMARY,
            prefix_icon=ft.icons.LOCK,
            password=True,
            can_reveal_password=True,
        )
        
        self.login_button = ft.ElevatedButton(
            text="ENTRAR",
            width=300,
            height=50,
            bgcolor=Colors.SECONDARY,
            color=Colors.WHITE,
            style=ft.ButtonStyle(
                text_style=ft.TextStyle(size=18, weight=ft.FontWeight.BOLD),
                shape=ft.RoundedRectangleBorder(radius=25),
            ),
            on_click=self.handle_login,
        )
        
        self.loading = ft.ProgressRing(
            visible=False,
            color=Colors.PRIMARY,
        )

    def format_cnpj(self, e):
        """Formatar CNPJ automaticamente"""
        text = e.control.value
        # Remove tudo que não é dígito
        numbers = re.sub(r'\D', '', text)
        
        # Aplica a máscara
        if len(numbers) <= 2:
            formatted = numbers
        elif len(numbers) <= 5:
            formatted = f"{numbers[:2]}.{numbers[2:]}"
        elif len(numbers) <= 8:
            formatted = f"{numbers[:2]}.{numbers[2:5]}.{numbers[5:]}"
        elif len(numbers) <= 12:
            formatted = f"{numbers[:2]}.{numbers[2:5]}.{numbers[5:8]}/{numbers[8:]}"
        else:
            formatted = f"{numbers[:2]}.{numbers[2:5]}.{numbers[5:8]}/{numbers[8:12]}-{numbers[12:14]}"
        
        e.control.value = formatted
        e.control.update()

    def validate_form(self):
        """Validar formulário"""
        errors = []
        
        if not self.cnpj_field.value:
            errors.append("CNPJ é obrigatório")
        elif len(self.cnpj_field.value.replace('.', '').replace('/', '').replace('-', '')) != 14:
            errors.append("CNPJ deve ter 14 dígitos")
            
        if not self.senha_field.value:
            errors.append("Senha é obrigatória")
        elif len(self.senha_field.value) < 4:
            errors.append("Senha deve ter pelo menos 4 caracteres")
            
        return errors

    def show_error(self, message):
        """Mostrar erro"""
        dlg = ft.AlertDialog(
            title=ft.Text("Erro", color=Colors.ERROR),
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

    def handle_login(self, e):
        """Processar login"""
        # Validar formulário
        errors = self.validate_form()
        if errors:
            self.show_error("\n".join(errors))
            return
        
        # Mostrar loading
        self.login_button.visible = False
        self.loading.visible = True
        self.page.update()
        
        try:
            # Remover formatação do CNPJ
            cnpj = re.sub(r'\D', '', self.cnpj_field.value)
            senha = self.senha_field.value
            
            # Tentar autenticar
            user = self.auth_service.authenticate(cnpj, senha)
            
            if user:
                # Login bem-sucedido
                self.on_login_success(user)
            else:
                # Login falhou
                self.show_error("CNPJ ou senha incorretos")
                
        except Exception as ex:
            self.show_error(f"Erro ao fazer login: {str(ex)}")
        
        finally:
            # Esconder loading
            self.login_button.visible = True
            self.loading.visible = False
            self.page.update()

    def build(self):
        """Construir a view"""
        return ft.Container(
            content=ft.Column(
                [
                    # Logo e título
                    ft.Container(
                        content=ft.Column(
                            [
                                ft.Text(
                                    "BagunçArt",
                                    size=36,
                                    weight=ft.FontWeight.BOLD,
                                    color=Colors.PRIMARY,
                                    text_align=ft.TextAlign.CENTER,
                                ),
                                ft.Text(
                                    "Gestão de Eventos",
                                    size=16,
                                    color=Colors.GRAY,
                                    text_align=ft.TextAlign.CENTER,
                                ),
                            ],
                            alignment=ft.MainAxisAlignment.CENTER,
                            horizontal_alignment=ft.CrossAxisAlignment.CENTER,
                        ),
                        height=200,
                        alignment=ft.alignment.center,
                    ),
                    
                    # Formulário
                    ft.Container(
                        content=ft.Column(
                            [
                                self.cnpj_field,
                                ft.Container(height=20),
                                self.senha_field,
                                ft.Container(height=30),
                                
                                # Botão de login e loading
                                ft.Stack(
                                    [
                                        self.login_button,
                                        ft.Container(
                                            content=self.loading,
                                            alignment=ft.alignment.center,
                                        ),
                                    ],
                                    height=50,
                                ),
                                
                                ft.Container(height=20),
                                
                                # Link esqueceu senha
                                ft.TextButton(
                                    text="Esqueceu a senha?",
                                    style=ft.ButtonStyle(
                                        color=Colors.GRAY,
                                    ),
                                    on_click=lambda _: self.show_error("Funcionalidade não implementada"),
                                ),
                            ],
                            alignment=ft.MainAxisAlignment.CENTER,
                            horizontal_alignment=ft.CrossAxisAlignment.CENTER,
                        ),
                        padding=30,
                    ),
                    
                    # Rodapé
                    ft.Container(
                        content=ft.Text(
                            "© 2024 BagunçArt Eventos",
                            size=12,
                            color=Colors.GRAY,
                            text_align=ft.TextAlign.CENTER,
                        ),
                        alignment=ft.alignment.center,
                    ),
                ],
                alignment=ft.MainAxisAlignment.SPACE_BETWEEN,
                expand=True,
            ),
            bgcolor=Colors.WHITE,
            expand=True,
        )