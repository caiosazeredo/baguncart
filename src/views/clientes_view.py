# src/views/clientes_view.py
import flet as ft
from src.utils.colors import Colors
from src.services.cliente_service import ClienteService

class ClientesView:
    def __init__(self, page, db, navigate_to):
        self.page = page
        self.db = db
        self.navigate_to = navigate_to
        self.cliente_service = ClienteService(db)
        
        # Lista de clientes
        self.clientes = []
        self.clientes_filtrados = []
        
        # Componentes
        self.search_field = ft.TextField(
            hint_text="Pesquisar clientes...",
            prefix_icon=ft.icons.SEARCH,
            border_color=Colors.GRAY,
            focused_border_color=Colors.PRIMARY,
            on_change=self.filter_clientes,
            expand=True,
        )
        
        self.clientes_list = ft.Column(
            spacing=10,
            scroll=ft.ScrollMode.AUTO,
        )
        
        self.loading = ft.ProgressRing(
            color=Colors.PRIMARY,
            visible=True,
        )
        
        # Carregar clientes
        self.load_clientes()

    def load_clientes(self):
        """Carregar lista de clientes"""
        try:
            self.clientes = self.cliente_service.get_all()
            self.clientes_filtrados = self.clientes.copy()
            self.update_clientes_list()
            self.loading.visible = False
            
        except Exception as e:
            print(f"Erro ao carregar clientes: {e}")
            self.show_error("Erro ao carregar clientes")
            self.loading.visible = False
        
        self.page.update()

    def filter_clientes(self, e):
        """Filtrar clientes por texto"""
        search_text = e.control.value.lower()
        
        if not search_text:
            self.clientes_filtrados = self.clientes.copy()
        else:
            self.clientes_filtrados = [
                cliente for cliente in self.clientes
                if (search_text in cliente.get('nome', '').lower() or
                    search_text in cliente.get('telefone', '').lower() or
                    search_text in cliente.get('email', '').lower())
            ]
        
        self.update_clientes_list()
        self.page.update()

    def update_clientes_list(self):
        """Atualizar lista visual de clientes"""
        self.clientes_list.controls.clear()
        
        if not self.clientes_filtrados:
            # Lista vazia
            self.clientes_list.controls.append(
                ft.Container(
                    content=ft.Column(
                        [
                            ft.Icon(
                                ft.icons.PEOPLE_OUTLINE,
                                size=60,
                                color=Colors.GRAY,
                            ),
                            ft.Text(
                                "Nenhum cliente encontrado",
                                size=16,
                                color=Colors.GRAY,
                                text_align=ft.TextAlign.CENTER,
                            ),
                            ft.Container(height=20),
                            ft.ElevatedButton(
                                text="Cadastrar Primeiro Cliente",
                                bgcolor=Colors.PRIMARY,
                                color=Colors.WHITE,
                                on_click=lambda _: self.navigate_to("cadastro_cliente"),
                            ),
                        ],
                        horizontal_alignment=ft.CrossAxisAlignment.CENTER,
                    ),
                    alignment=ft.alignment.center,
                    height=300,
                )
            )
        else:
            # Lista com clientes
            for cliente in self.clientes_filtrados:
                self.clientes_list.controls.append(
                    self.create_cliente_card(cliente)
                )

    def create_cliente_card(self, cliente):
        """Criar card de cliente"""
        return ft.Container(
            content=ft.Row(
                [
                    # Avatar
                    ft.Container(
                        content=ft.Icon(
                            ft.icons.PERSON,
                            color=Colors.WHITE,
                            size=30,
                        ),
                        bgcolor=Colors.PRIMARY,
                        border_radius=25,
                        width=50,
                        height=50,
                        alignment=ft.alignment.center,
                    ),
                    
                    # Informações
                    ft.Container(
                        content=ft.Column(
                            [
                                ft.Text(
                                    cliente.get('nome', 'N/A'),
                                    size=16,
                                    weight=ft.FontWeight.BOLD,
                                    color=Colors.DARK_GRAY,
                                ),
                                ft.Text(
                                    cliente.get('telefone', 'N/A'),
                                    size=14,
                                    color=Colors.GRAY,
                                ),
                                ft.Text(
                                    cliente.get('email', 'N/A'),
                                    size=12,
                                    color=Colors.GRAY,
                                ),
                            ],
                            spacing=2,
                        ),
                        expand=True,
                        padding=ft.padding.only(left=15),
                    ),
                    
                    # Ações
                    ft.Column(
                        [
                            ft.IconButton(
                                ft.icons.PHONE,
                                icon_color=Colors.SUCCESS,
                                icon_size=20,
                                tooltip="Ligar",
                                on_click=lambda _, c=cliente: self.call_cliente(c),
                            ),
                            ft.IconButton(
                                ft.icons.EDIT,
                                icon_color=Colors.SECONDARY,
                                icon_size=20,
                                tooltip="Editar",
                                on_click=lambda _, c=cliente: self.edit_cliente(c),
                            ),
                        ],
                        spacing=0,
                    ),
                ],
                alignment=ft.MainAxisAlignment.START,
            ),
            bgcolor=Colors.WHITE,
            border=ft.border.all(1, Colors.BORDER),
            border_radius=10,
            padding=15,
            on_click=lambda _, c=cliente: self.show_cliente_details(c),
            ink=True,
        )

    def show_cliente_details(self, cliente):
        """Mostrar detalhes do cliente"""
        dlg = ft.AlertDialog(
            title=ft.Text(cliente.get('nome', 'Cliente')),
            content=ft.Column(
                [
                    ft.Row([
                        ft.Text("CPF:", weight=ft.FontWeight.BOLD),
                        ft.Text(cliente.get('cpf', 'N/A')),
                    ]),
                    ft.Row([
                        ft.Text("Telefone:", weight=ft.FontWeight.BOLD),
                        ft.Text(cliente.get('telefone', 'N/A')),
                    ]),
                    ft.Row([
                        ft.Text("Email:", weight=ft.FontWeight.BOLD),
                        ft.Text(cliente.get('email', 'N/A')),
                    ]),
                    ft.Row([
                        ft.Text("Endereço:", weight=ft.FontWeight.BOLD),
                    ]),
                    ft.Text(cliente.get('endereco', 'N/A')),
                ],
                tight=True,
            ),
            actions=[
                ft.TextButton("Fechar", on_click=lambda _: self.close_dialog()),
                ft.TextButton("Editar", on_click=lambda _: self.edit_cliente(cliente)),
                ft.TextButton("Novo Contrato", on_click=lambda _: self.new_contract(cliente)),
            ],
        )
        self.page.dialog = dlg
        dlg.open = True
        self.page.update()

    def call_cliente(self, cliente):
        """Ação de ligar para cliente"""
        self.show_info(f"Ligando para {cliente.get('nome', 'Cliente')}: {cliente.get('telefone', '')}")

    def edit_cliente(self, cliente):
        """Editar cliente"""
        self.close_dialog()
        self.navigate_to("cadastro_cliente", cliente=cliente)

    def new_contract(self, cliente):
        """Novo contrato para cliente"""
        self.close_dialog()
        self.navigate_to("cadastro_cliente", cliente_selecionado=cliente)

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

    def show_info(self, message):
        """Mostrar informação"""
        dlg = ft.AlertDialog(
            title=ft.Text("Informação", color=Colors.INFO),
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

    def build(self):
        """Construir a view"""
        return ft.Container(
            content=ft.Column(
                [
                    # Barra de pesquisa
                    ft.Container(
                        content=ft.Row(
                            [
                                self.search_field,
                                ft.IconButton(
                                    ft.icons.REFRESH,
                                    icon_color=Colors.PRIMARY,
                                    tooltip="Atualizar",
                                    on_click=lambda _: self.load_clientes(),
                                ),
                            ],
                        ),
                        padding=20,
                    ),
                    
                    # Lista de clientes ou loading
                    ft.Container(
                        content=ft.Stack(
                            [
                                self.clientes_list,
                                ft.Container(
                                    content=self.loading,
                                    alignment=ft.alignment.center,
                                ),
                            ]
                        ),
                        expand=True,
                        padding=ft.padding.symmetric(horizontal=20),
                    ),
                ],
                expand=True,
            ),
            bgcolor=Colors.BACKGROUND,
            expand=True,
        )