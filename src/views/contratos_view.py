# src/views/contratos_view.py
import flet as ft
from flet import icons
from datetime import datetime
from src.utils.colors import Colors

class ContratosView:
    def __init__(self, page, db, navigate_to):
        self.page = page
        self.db = db
        self.navigate_to = navigate_to
        
        # Lista de contratos
        self.contratos = []
        self.contratos_filtrados = []
        
        # Componentes
        self.search_field = ft.TextField(
            hint_text="Pesquisar contratos...",
            prefix_icon=icons.SEARCH,
            border_color=Colors.GRAY,
            focused_border_color=Colors.PRIMARY,
            on_change=self.filter_contratos,
            expand=True,
        )
        
        self.status_filter = ft.Dropdown(
            label="Status",
            border_color=Colors.GRAY,
            focused_border_color=Colors.PRIMARY,
            options=[
                ft.dropdown.Option("todos", "Todos"),
                ft.dropdown.Option("ativo", "Ativo"),
                ft.dropdown.Option("concluido", "Concluído"),
                ft.dropdown.Option("cancelado", "Cancelado"),
            ],
            value="todos",
            on_change=self.filter_contratos,
            width=150,
        )
        
        self.contratos_list = ft.Column(
            spacing=10,
            scroll=ft.ScrollMode.AUTO,
        )
        
        self.loading = ft.ProgressRing(
            color=Colors.PRIMARY,
            visible=True,
        )
        
        # Carregar contratos
        self.load_contratos()

    def load_contratos(self):
        """Carregar lista de contratos"""
        try:
            query = """
            SELECT c.*, cl.nome as cliente_nome, cl.telefone as cliente_telefone
            FROM contratos c
            JOIN clientes cl ON c.cliente_id = cl.id
            ORDER BY c.data_evento DESC
            """
            self.contratos = self.db.execute_query(query)
            if not self.contratos:
                self.contratos = []
            
            self.contratos_filtrados = self.contratos.copy()
            self.update_contratos_list()
            self.loading.visible = False
            
        except Exception as e:
            print(f"Erro ao carregar contratos: {e}")
            self.show_error("Erro ao carregar contratos")
            self.loading.visible = False
        
        self.page.update()

    def filter_contratos(self, e):
        """Filtrar contratos"""
        search_text = self.search_field.value.lower() if self.search_field.value else ""
        status_filter = self.status_filter.value
        
        self.contratos_filtrados = []
        
        for contrato in self.contratos:
            # Filtro por texto
            text_match = (
                not search_text or
                search_text in contrato.get('numero_contrato', '').lower() or
                search_text in contrato.get('cliente_nome', '').lower() or
                search_text in contrato.get('local_evento', '').lower()
            )
            
            # Filtro por status
            status_match = (
                status_filter == "todos" or
                contrato.get('status') == status_filter
            )
            
            if text_match and status_match:
                self.contratos_filtrados.append(contrato)
        
        self.update_contratos_list()
        self.page.update()

    def update_contratos_list(self):
        """Atualizar lista visual de contratos"""
        self.contratos_list.controls.clear()
        
        if not self.contratos_filtrados:
            # Lista vazia
            self.contratos_list.controls.append(
                ft.Container(
                    content=ft.Column(
                        [
                            ft.Icon(
                                icons.DESCRIPTION_OUTLINED,
                                size=60,
                                color=Colors.GRAY,
                            ),
                            ft.Text(
                                "Nenhum contrato encontrado",
                                size=16,
                                color=Colors.GRAY,
                                text_align=ft.TextAlign.CENTER,
                            ),
                            ft.Container(height=20),
                            ft.ElevatedButton(
                                text="Novo Contrato",
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
            # Lista com contratos
            for contrato in self.contratos_filtrados:
                self.contratos_list.controls.append(
                    self.create_contrato_card(contrato)
                )

    def create_contrato_card(self, contrato):
        """Criar card de contrato"""
        # Cor do status
        status_colors = {
            'ativo': Colors.SUCCESS,
            'concluido': Colors.PRIMARY,
            'cancelado': Colors.ERROR,
        }
        status_color = status_colors.get(contrato.get('status', 'ativo'), Colors.GRAY)
        
        # Formatar data
        data_evento = contrato.get('data_evento')
        if isinstance(data_evento, str):
            try:
                data_evento = datetime.strptime(data_evento, '%Y-%m-%d').date()
            except:
                pass
        
        data_formatada = data_evento.strftime('%d/%m/%Y') if data_evento else 'N/A'
        
        return ft.Container(
            content=ft.Row(
                [
                    # Status indicator
                    ft.Container(
                        bgcolor=status_color,
                        width=5,
                        height=80,
                        border_radius=ft.border_radius.only(left=10),
                    ),
                    
                    # Informações principais
                    ft.Container(
                        content=ft.Column(
                            [
                                ft.Row([
                                    ft.Text(
                                        contrato.get('numero_contrato', 'N/A'),
                                        size=16,
                                        weight=ft.FontWeight.BOLD,
                                        color=Colors.DARK_GRAY,
                                    ),
                                    ft.Container(
                                        content=ft.Text(
                                            contrato.get('status', 'ativo').upper(),
                                            size=10,
                                            color=Colors.WHITE,
                                            weight=ft.FontWeight.BOLD,
                                        ),
                                        bgcolor=status_color,
                                        padding=ft.padding.symmetric(horizontal=8, vertical=2),
                                        border_radius=10,
                                    ),
                                ], alignment=ft.MainAxisAlignment.SPACE_BETWEEN),
                                
                                ft.Text(
                                    contrato.get('cliente_nome', 'N/A'),
                                    size=14,
                                    color=Colors.GRAY,
                                ),
                                ft.Text(
                                    f"Data: {data_formatada}",
                                    size=12,
                                    color=Colors.GRAY,
                                ),
                                ft.Text(
                                    f"Valor: R$ {float(contrato.get('valor_total', 0)):.2f}",
                                    size=12,
                                    weight=ft.FontWeight.BOLD,
                                    color=Colors.SUCCESS,
                                ),
                            ],
                            spacing=2,
                        ),
                        expand=True,
                        padding=ft.padding.only(left=15, right=10),
                    ),
                    
                    # Ações
                    ft.Column(
                        [
                            ft.IconButton(
                                icons.VISIBILITY,
                                icon_color=Colors.PRIMARY,
                                icon_size=20,
                                tooltip="Ver Detalhes",
                                on_click=lambda _, c=contrato: self.show_contrato_details(c),
                            ),
                            ft.IconButton(
                                icons.PHONE,
                                icon_color=Colors.SUCCESS,
                                icon_size=20,
                                tooltip="Ligar Cliente",
                                on_click=lambda _, c=contrato: self.call_cliente(c),
                            ),
                        ],
                        spacing=0,
                    ),
                ],
                alignment=ft.MainAxisAlignment.START,
            ),
            bgcolor=Colors.WHITE,
            border=ft.border.all(1, Colors.LIGHT_GRAY),
            border_radius=10,
            padding=0,
            on_click=lambda _, c=contrato: self.show_contrato_details(c),
            ink=True,
        )

    def show_contrato_details(self, contrato):
        """Mostrar detalhes do contrato"""
        # Buscar serviços do contrato
        try:
            query = """
            SELECT s.nome, s.preco, cs.quantidade, cs.preco_unitario
            FROM contrato_servicos cs
            JOIN servicos s ON cs.servico_id = s.id
            WHERE cs.contrato_id = %s
            """
            servicos = self.db.execute_query(query, (contrato['id'],))
            
            servicos_text = []
            if servicos:
                for servico in servicos:
                    servicos_text.append(
                        f"• {servico['nome']} - R$ {float(servico['preco_unitario']):.2f}"
                    )
            else:
                servicos_text = ["Nenhum serviço encontrado"]
                
        except Exception as e:
            print(f"Erro ao buscar serviços: {e}")
            servicos_text = ["Erro ao carregar serviços"]
        
        # Formatar data
        data_evento = contrato.get('data_evento')
        if isinstance(data_evento, str):
            try:
                data_evento = datetime.strptime(data_evento, '%Y-%m-%d').date()
            except:
                pass
        data_formatada = data_evento.strftime('%d/%m/%Y') if data_evento else 'N/A'
        
        dlg = ft.AlertDialog(
            title=ft.Text(f"Contrato {contrato.get('numero_contrato', 'N/A')}"),
            content=ft.Container(
                content=ft.Column(
                    [
                        ft.Text("CLIENTE:", weight=ft.FontWeight.BOLD),
                        ft.Text(contrato.get('cliente_nome', 'N/A')),
                        ft.Container(height=10),
                        
                        ft.Text("DATA DO EVENTO:", weight=ft.FontWeight.BOLD),
                        ft.Text(data_formatada),
                        ft.Container(height=10),
                        
                        ft.Text("LOCAL:", weight=ft.FontWeight.BOLD),
                        ft.Text(contrato.get('local_evento', 'N/A')),
                        ft.Container(height=10),
                        
                        ft.Text("FORMA DE PAGAMENTO:", weight=ft.FontWeight.BOLD),
                        ft.Text(contrato.get('forma_pagamento', 'N/A').upper()),
                        ft.Container(height=10),
                        
                        ft.Text("SERVIÇOS:", weight=ft.FontWeight.BOLD),
                        ft.Column([
                            ft.Text(servico) for servico in servicos_text
                        ]),
                        ft.Container(height=10),
                        
                        ft.Text("VALOR TOTAL:", weight=ft.FontWeight.BOLD),
                        ft.Text(f"R$ {float(contrato.get('valor_total', 0)):.2f}", 
                                color=Colors.SUCCESS, weight=ft.FontWeight.BOLD),
                    ],
                    tight=True,
                    scroll=ft.ScrollMode.AUTO,
                ),
                height=400,
                width=300,
            ),
            actions=[
                ft.TextButton("Fechar", on_click=lambda _: self.close_dialog()),
                ft.TextButton("Ligar Cliente", on_click=lambda _: self.call_cliente(contrato)),
            ],
        )
        self.page.dialog = dlg
        dlg.open = True
        self.page.update()

    def call_cliente(self, contrato):
        """Ação de ligar para cliente"""
        self.close_dialog()
        self.show_info(f"Ligando para {contrato.get('cliente_nome', 'Cliente')}: {contrato.get('cliente_telefone', '')}")

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
            title=ft.Text("Informação", color=Colors.PRIMARY),
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
                    # Barra de filtros
                    ft.Container(
                        content=ft.Row(
                            [
                                self.search_field,
                                ft.Container(width=10),
                                self.status_filter,
                                ft.IconButton(
                                    icons.REFRESH,
                                    icon_color=Colors.PRIMARY,
                                    tooltip="Atualizar",
                                    on_click=lambda _: self.load_contratos(),
                                ),
                            ],
                        ),
                        padding=20,
                    ),
                    
                    # Lista de contratos ou loading
                    ft.Container(
                        content=ft.Stack(
                            [
                                self.contratos_list,
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
            bgcolor=Colors.LIGHT_GRAY,
            expand=True,
        )