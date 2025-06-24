# src/views/cadastro_cliente_view.py
import flet as ft
from flet import icons
import re
from src.utils.colors import Colors
from src.services.cliente_service import ClienteService

class CadastroClienteView:
    def __init__(self, page, db, navigate_to, show_success, show_error, cliente=None):
        self.page = page
        self.db = db
        self.navigate_to = navigate_to
        self.show_success = show_success
        self.show_error = show_error
        self.cliente_service = ClienteService(db)
        
        # Cliente para edição (se fornecido)
        self.cliente = cliente
        self.is_editing = cliente is not None
        
        # Campos do formulário
        self.nome_field = ft.TextField(
            label="Nome Completo",
            hint_text="Digite o nome completo",
            border_color=Colors.GRAY,
            focused_border_color=Colors.PRIMARY,
            prefix_icon=icons.PERSON,
        )
        
        self.cpf_field = ft.TextField(
            label="CPF",
            hint_text="000.000.000-00",
            border_color=Colors.GRAY,
            focused_border_color=Colors.PRIMARY,
            prefix_icon=icons.CREDIT_CARD,
            max_length=14,
            on_change=self.format_cpf,
        )
        
        self.telefone_field = ft.TextField(
            label="Telefone",
            hint_text="(11) 99999-9999",
            border_color=Colors.GRAY,
            focused_border_color=Colors.PRIMARY,
            prefix_icon=icons.PHONE,
            max_length=15,
            on_change=self.format_telefone,
        )
        
        self.email_field = ft.TextField(
            label="Email (opcional)",
            hint_text="cliente@email.com",
            border_color=Colors.GRAY,
            focused_border_color=Colors.PRIMARY,
            prefix_icon=icons.EMAIL,
        )
        
        self.endereco_field = ft.TextField(
            label="Endereço",
            hint_text="Rua, número, bairro, cidade",
            border_color=Colors.GRAY,
            focused_border_color=Colors.PRIMARY,
            prefix_icon=icons.HOME,
            multiline=True,
            min_lines=2,
            max_lines=3,
        )
        
        self.save_button = ft.ElevatedButton(
            text="SALVAR CLIENTE" if not self.is_editing else "ATUALIZAR CLIENTE",
            width=300,
            height=50,
            bgcolor=Colors.PRIMARY,
            color=Colors.WHITE,
            style=ft.ButtonStyle(
                text_style=ft.TextStyle(size=16, weight=ft.FontWeight.BOLD),
                shape=ft.RoundedRectangleBorder(radius=25),
            ),
            on_click=self.handle_save,
        )
        
        self.continue_button = ft.ElevatedButton(
            text="CONTINUAR PARA SERVIÇOS",
            width=300,
            height=50,
            bgcolor=Colors.SECONDARY,
            color=Colors.WHITE,
            style=ft.ButtonStyle(
                text_style=ft.TextStyle(size=16, weight=ft.FontWeight.BOLD),
                shape=ft.RoundedRectangleBorder(radius=25),
            ),
            visible=False,
            on_click=self.handle_continue,
        )
        
        self.loading = ft.ProgressRing(
            visible=False,
            color=Colors.PRIMARY,
        )
        
        # Preencher campos se editando
        if self.is_editing:
            self.populate_fields()

    def populate_fields(self):
        """Preencher campos com dados do cliente"""
        if self.cliente:
            self.nome_field.value = self.cliente.get('nome', '')
            self.cpf_field.value = self.format_cpf_value(self.cliente.get('cpf', ''))
            self.telefone_field.value = self.format_telefone_value(self.cliente.get('telefone', ''))
            self.email_field.value = self.cliente.get('email', '')
            self.endereco_field.value = self.cliente.get('endereco', '')

    def format_cpf_value(self, cpf):
        """Formatar CPF para exibição"""
        numbers = re.sub(r'\D', '', cpf)
        if len(numbers) == 11:
            return f"{numbers[:3]}.{numbers[3:6]}.{numbers[6:9]}-{numbers[9:]}"
        return cpf

    def format_telefone_value(self, telefone):
        """Formatar telefone para exibição"""
        numbers = re.sub(r'\D', '', telefone)
        if len(numbers) == 11:
            return f"({numbers[:2]}) {numbers[2:7]}-{numbers[7:]}"
        elif len(numbers) == 10:
            return f"({numbers[:2]}) {numbers[2:6]}-{numbers[6:]}"
        return telefone

    def format_cpf(self, e):
        """Formatar CPF automaticamente"""
        text = e.control.value
        numbers = re.sub(r'\D', '', text)
        
        if len(numbers) <= 3:
            formatted = numbers
        elif len(numbers) <= 6:
            formatted = f"{numbers[:3]}.{numbers[3:]}"
        elif len(numbers) <= 9:
            formatted = f"{numbers[:3]}.{numbers[3:6]}.{numbers[6:]}"
        else:
            formatted = f"{numbers[:3]}.{numbers[3:6]}.{numbers[6:9]}-{numbers[9:11]}"
        
        e.control.value = formatted
        e.control.update()

    def format_telefone(self, e):
        """Formatar telefone automaticamente"""
        text = e.control.value
        numbers = re.sub(r'\D', '', text)
        
        if len(numbers) <= 2:
            formatted = f"({numbers}" if numbers else ""
        elif len(numbers) <= 7:
            formatted = f"({numbers[:2]}) {numbers[2:]}"
        elif len(numbers) <= 11:
            if len(numbers) == 11:
                formatted = f"({numbers[:2]}) {numbers[2:7]}-{numbers[7:]}"
            else:
                formatted = f"({numbers[:2]}) {numbers[2:6]}-{numbers[6:]}"
        else:
            formatted = f"({numbers[:2]}) {numbers[2:7]}-{numbers[7:11]}"
        
        e.control.value = formatted
        e.control.update()

    def validate_form(self):
        """Validar formulário"""
        errors = []
        
        if not self.nome_field.value or len(self.nome_field.value.strip()) < 3:
            errors.append("Nome deve ter pelo menos 3 caracteres")
            
        if not self.cpf_field.value:
            errors.append("CPF é obrigatório")
        else:
            cpf_numbers = re.sub(r'\D', '', self.cpf_field.value)
            if len(cpf_numbers) != 11:
                errors.append("CPF deve ter 11 dígitos")
                
        if not self.telefone_field.value:
            errors.append("Telefone é obrigatório")
        else:
            tel_numbers = re.sub(r'\D', '', self.telefone_field.value)
            if len(tel_numbers) < 10:
                errors.append("Telefone deve ter pelo menos 10 dígitos")
                
        if self.email_field.value and not re.match(r'^[^@]+@[^@]+\.[^@]+$', self.email_field.value):
            errors.append("Email inválido")
            
        return errors

    def handle_save(self, e):
        """Processar salvamento"""
        # Validar formulário
        errors = self.validate_form()
        if errors:
            self.show_error("\n".join(errors))
            return
        
        # Mostrar loading
        self.save_button.visible = False
        self.loading.visible = True
        self.page.update()
        
        try:
            # Preparar dados
            nome = self.nome_field.value.strip()
            cpf = re.sub(r'\D', '', self.cpf_field.value)
            telefone = re.sub(r'\D', '', self.telefone_field.value)
            email = self.email_field.value.strip()
            endereco = self.endereco_field.value.strip()
            
            if self.is_editing:
                # Atualizar cliente existente
                result = self.cliente_service.update(
                    self.cliente['id'], nome, cpf, endereco, telefone, email
                )
            else:
                # Criar novo cliente
                result = self.cliente_service.create(
                    nome, cpf, endereco, telefone, email
                )
            
            if result.get('success'):
                action = "atualizado" if self.is_editing else "cadastrado"
                self.show_success(f"Cliente {action} com sucesso!")
                
                if not self.is_editing:
                    # Mostrar botão para continuar com serviços
                    self.save_button.visible = False
                    self.continue_button.visible = True
                else:
                    # Voltar para lista de clientes
                    self.navigate_to("clientes")
            else:
                self.show_error(result.get('error', 'Erro desconhecido'))
                
        except Exception as ex:
            self.show_error(f"Erro ao salvar cliente: {str(ex)}")
        
        finally:
            if self.save_button.visible:
                self.save_button.visible = True
            self.loading.visible = False
            self.page.update()

    def handle_continue(self, e):
        """Continuar para seleção de serviços"""
        cliente_data = {
            'nome': self.nome_field.value.strip(),
            'cpf': re.sub(r'\D', '', self.cpf_field.value),
            'telefone': re.sub(r'\D', '', self.telefone_field.value),
            'email': self.email_field.value.strip(),
            'endereco': self.endereco_field.value.strip(),
        }
        self.navigate_to("servicos", cliente_data=cliente_data)

    def build(self):
        """Construir a view"""
        title = "Editar Cliente" if self.is_editing else "Cadastro de Cliente"
        
        return ft.Container(
            content=ft.Column(
                [
                    # Título
                    ft.Container(
                        content=ft.Text(
                            title,
                            size=24,
                            weight=ft.FontWeight.BOLD,
                            color=Colors.PRIMARY,
                            text_align=ft.TextAlign.CENTER,
                        ),
                        padding=20,
                    ),
                    
                    # Formulário
                    ft.Container(
                        content=ft.Column(
                            [
                                self.nome_field,
                                ft.Container(height=15),
                                self.cpf_field,
                                ft.Container(height=15),
                                self.telefone_field,
                                ft.Container(height=15),
                                self.email_field,
                                ft.Container(height=15),
                                self.endereco_field,
                                ft.Container(height=30),
                                
                                # Botões e loading
                                ft.Stack(
                                    [
                                        self.save_button,
                                        self.continue_button,
                                        ft.Container(
                                            content=self.loading,
                                            alignment=ft.alignment.center,
                                        ),
                                    ],
                                    height=50,
                                ),
                                
                                ft.Container(height=20),
                            ],
                            scroll=ft.ScrollMode.AUTO,
                        ),
                        padding=20,
                        expand=True,
                    ),
                ],
                expand=True,
            ),
            bgcolor=Colors.WHITE,
            expand=True,
        )