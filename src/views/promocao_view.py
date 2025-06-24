# src/views/promocao_view.py
import flet as ft
from datetime import datetime, timedelta
from src.utils.colors import Colors

class PromocaoView:
    def __init__(self, page, db, navigate_to, show_success, show_error):
        self.page = page
        self.db = db
        self.navigate_to = navigate_to
        self.show_success = show_success
        self.show_error = show_error
        
        # Listas
        self.clientes = []
        self.servicos = []
        self.servicos_selecionados = []
        
        # Componentes
        self.cliente_dropdown = ft.Dropdown(
            label="Cliente",
            border_color=Colors.GRAY,
            focused_border_color=Colors.PRIMARY,
            hint_text="Selecione um cliente",
            width=300,
        )
        
        self.servicos_list = ft.Column(spacing=10)
        
        self.valor_original_field = ft.TextField(
            label="Valor Original",
            hint_text="R$ 0,00",
            border_color=Colors.GRAY,
            focused_border_color=Colors.PRIMARY,
            prefix_icon=ft.icons.MONEY,
            read_only=True,
        )
        
        self.valor_promocional_field = ft.TextField(
            label="Valor Promocional",
            hint_text="R$ 0,00",
            border_color=Colors.GRAY,
            focused_border_color=Colors.PRIMARY,
            prefix_icon=ft.icons.LOCAL_OFFER,
            on_change=self.calculate_discount,
        )
        
        self.desconto_field = ft.TextField(
            label="Desconto (%)",
            hint_text="0%",
            border_color=Colors.GRAY,
            focused_border_color=Colors.PRIMARY,
            prefix_icon=ft.icons.PERCENT,
            read_only=True,
        )
        
        self.validade_field = ft.TextField(
            label="Validade da Promoção",
            hint_text="DD/MM/AAAA",
            border_color=Colors.GRAY,
            focused_border_color=Colors.PRIMARY,
            prefix_icon=ft.icons.CALENDAR_TODAY,
            on_change=self.format_date,
        )
        
        self.descricao_field = ft.TextField(
            label="Descrição da Promoção",
            hint_text="Descreva os detalhes da promoção",
            border_color=Colors.GRAY,
            focused_border_color=Colors.PRIMARY,
            prefix_icon=ft.icons.DESCRIPTION,
            multiline=True,
            min_lines=3,
            max_lines=5,
        )
        
        self.criar_button = ft.ElevatedButton(
            text="CRIAR PROMOÇÃO",
            width=300,
            height=50,
            bgcolor=Colors.SECONDARY,
            color=Colors.WHITE,
            style=ft.ButtonStyle(
                text_style=ft.TextStyle(size=16, weight=ft.FontWeight.BOLD),
                shape=ft.RoundedRectangleBorder(radius=25),
            ),
            on_click=self.handle_criar,
        )
        
        self.loading = ft.ProgressRing(
            visible=False,
            color=Colors.PRIMARY,
        )
        
        # Carregar dados
        self.load_data()

    def load_data(self):
        """Carregar clientes e serviços"""
        try:
            # Carregar clientes
            query = "SELECT id, nome FROM clientes ORDER BY nome"
            result = self.db.execute_query(query)
            self.clientes = result if result else []
            
            # Preencher dropdown de clientes
            self.cliente_dropdown.options = [
                ft.dropdown.Option(str(cliente['id']), cliente['nome'])
                for cliente in self.clientes
            ]
            
            # Carregar serviços
            query = "SELECT * FROM servicos WHERE ativo = TRUE ORDER BY nome"
            result = self.db.execute_query(query)
            self.servicos = result if result else []
            
            self.update_servicos_list()
            
        except Exception as e:
            print(f"Erro ao carregar dados: {e}")
            self.show_error("Erro ao carregar dados")

    def update_servicos_list(self):
        """Atualizar lista de serviços"""
        self.servicos_list.controls.clear()
        
        for servico in self.servicos:
            checkbox = ft.Checkbox(
                label=f"{servico['nome']} - R$ {servico['preco']:.2f}",
                value=False,
                on_change=lambda e, s=servico: self.toggle_servico(s, e),
            )
            
            descricao = ft.Text(
                servico.get('descricao', ''),
                size=12,
                color=Colors.GRAY,
            )
            
            card = ft.Container(
                content=ft.Column([
                    checkbox,
                    ft.Container(
                        content=descricao,
                        padding=ft.padding.only(left=40),
                    ),
                ]),
                bgcolor=Colors.LIGHT_GRAY,
                padding=15,
                border_radius=10,
            )
            
            self.servicos_list.controls.append(card)

    def toggle_servico(self, servico, e):
        """Alternar seleção de serviço"""
        if e.control.value:
            self.servicos_selecionados.append(servico)
        else:
            self.servicos_selecionados = [s for s in self.servicos_selecionados if s['id'] != servico['id']]
        
        self.calculate_original_value()

    def calculate_original_value(self):
        """Calcular valor original"""
        total = sum(float(s['preco']) for s in self.servicos_selecionados)
        self.valor_original_field.value = f"R$ {total:.2f}"
        self.page.update()
        
        # Limpar campos de promoção
        self.valor_promocional_field.value = ""
        self.desconto_field.value = ""

    def calculate_discount(self, e):
        """Calcular desconto baseado no valor promocional"""
        try:
            valor_original_text = self.valor_original_field.value.replace('R$ ', '').replace(',', '.')
            valor_original = float(valor_original_text) if valor_original_text else 0
            
            valor_promocional_text = e.control.value.replace('R$ ', '').replace(',', '.')
            valor_promocional = float(valor_promocional_text) if valor_promocional_text else 0
            
            if valor_original > 0 and valor_promocional < valor_original:
                desconto = ((valor_original - valor_promocional) / valor_original) * 100
                self.desconto_field.value = f"{desconto:.1f}%"
            else:
                self.desconto_field.value = "0%"
                
            self.page.update()
            
        except:
            self.desconto_field.value = "0%"
            self.page.update()

    def format_date(self, e):
        """Formatar data automaticamente"""
        text = e.control.value
        numbers = ''.join(filter(str.isdigit, text))
        
        if len(numbers) <= 2:
            formatted = numbers
        elif len(numbers) <= 4:
            formatted = f"{numbers[:2]}/{numbers[2:]}"
        else:
            formatted = f"{numbers[:2]}/{numbers[2:4]}/{numbers[4:8]}"
        
        e.control.value = formatted
        e.control.update()

    def validate_form(self):
        """Validar formulário"""
        errors = []
        
        if not self.cliente_dropdown.value:
            errors.append("Selecione um cliente")
            
        if not self.servicos_selecionados:
            errors.append("Selecione pelo menos um serviço")
            
        if not self.valor_promocional_field.value:
            errors.append("Digite o valor promocional")
        else:
            try:
                valor = float(self.valor_promocional_field.value.replace('R$ ', '').replace(',', '.'))
                if valor <= 0:
                    errors.append("Valor promocional deve ser maior que zero")
            except:
                errors.append("Valor promocional inválido")
                
        if not self.validade_field.value:
            errors.append("Data de validade é obrigatória")
        else:
            # Validar formato de data
            try:
                date_parts = self.validade_field.value.split('/')
                if len(date_parts) != 3:
                    errors.append("Data inválida. Use o formato DD/MM/AAAA")
                else:
                    day, month, year = map(int, date_parts)
                    validade_date = datetime(year, month, day).date()
                    if validade_date <= datetime.now().date():
                        errors.append("Data de validade deve ser futura")
            except:
                errors.append("Data inválida. Use o formato DD/MM/AAAA")
                
        if not self.descricao_field.value:
            errors.append("Descrição é obrigatória")
            
        return errors

    def handle_criar(self, e):
        """Criar promoção"""
        # Validar formulário
        errors = self.validate_form()
        if errors:
            self.show_error("\n".join(errors))
            return
        
        # Mostrar loading
        self.criar_button.visible = False
        self.loading.visible = True
        self.page.update()
        
        try:
            # Preparar dados
            cliente_id = int(self.cliente_dropdown.value)
            servico_ids = [s['id'] for s in self.servicos_selecionados]
            valor_promocional = float(self.valor_promocional_field.value.replace('R$ ', '').replace(',', '.'))
            
            # Converter data
            date_parts = self.validade_field.value.split('/')
            validade = f"{date_parts[2]}-{date_parts[1]}-{date_parts[0]}"
            
            # Inserir promoção
            query = """
            INSERT INTO promocoes (cliente_id, servico_ids, valor_promocional, 
                                 validade_promocao, descricao, ativo, created_at)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
            """
            
            import json
            promocao_id = self.db.execute_insert(
                query,
                (cliente_id, json.dumps(servico_ids), valor_promocional, 
                 validade, self.descricao_field.value, True, datetime.now())
            )
            
            if promocao_id:
                self.show_success("Promoção criada com sucesso!")
                # Limpar formulário
                self.clear_form()
            else:
                self.show_error("Erro ao criar promoção")
                
        except Exception as ex:
            self.show_error(f"Erro ao criar promoção: {str(ex)}")
        
        finally:
            self.criar_button.visible = True
            self.loading.visible = False
            self.page.update()

    def clear_form(self):
        """Limpar formulário"""
        self.cliente_dropdown.value = None
        self.valor_original_field.value = ""
        self.valor_promocional_field.value = ""
        self.desconto_field.value = ""
        self.validade_field.value = ""
        self.descricao_field.value = ""
        
        # Desmarcar serviços
        self.servicos_selecionados = []
        for control in self.servicos_list.controls:
            if hasattr(control, 'content') and hasattr(control.content, 'controls'):
                checkbox = control.content.controls[0]
                if hasattr(checkbox, 'value'):
                    checkbox.value = False
        
        self.page.update()

    def build(self):
        """Construir a view"""
        return ft.Container(
            content=ft.Column(
                [
                    # Título
                    ft.Container(
                        content=ft.Text(
                            "Criar Promoção",
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
                                # Seleção de cliente
                                self.cliente_dropdown,
                                ft.Container(height=20),
                                
                                # Serviços
                                ft.Text(
                                    "Selecionar Serviços:",
                                    size=18,
                                    weight=ft.FontWeight.BOLD,
                                    color=Colors.DARK_GRAY,
                                ),
                                ft.Container(
                                    content=self.servicos_list,
                                    height=200,
                                    scroll=ft.ScrollMode.AUTO,
                                ),
                                
                                ft.Container(height=20),
                                
                                # Valores
                                ft.Row([
                                    self.valor_original_field,
                                    ft.Container(width=10),
                                    self.valor_promocional_field,
                                ]),
                                
                                ft.Container(height=15),
                                
                                ft.Row([
                                    self.desconto_field,
                                    ft.Container(width=10),
                                    self.validade_field,
                                ]),
                                
                                ft.Container(height=15),
                                
                                # Descrição
                                self.descricao_field,
                                
                                ft.Container(height=30),
                                
                                # Botão e loading
                                ft.Stack(
                                    [
                                        self.criar_button,
                                        ft.Container(
                                            content=self.loading,
                                            alignment=ft.alignment.center,
                                        ),
                                    ],
                                    height=50,
                                ),
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