# src/views/servicos_view.py
import flet as ft
from flet import icons
from datetime import datetime, timedelta
from src.utils.colors import Colors

class ServicosView:
    def __init__(self, page, db, navigate_to, show_success, show_error, cliente_data=None):
        self.page = page
        self.db = db
        self.navigate_to = navigate_to
        self.show_success = show_success
        self.show_error = show_error
        self.cliente_data = cliente_data or {}
        
        # Lista de serviços disponíveis
        self.servicos_disponiveis = []
        self.servicos_selecionados = []
        
        # Componentes
        self.servicos_list = ft.Column(spacing=10)
        self.total_container = ft.Container()
        self.data_evento_field = ft.TextField(
            label="Data do Evento",
            hint_text="DD/MM/AAAA",
            border_color=Colors.GRAY,
            focused_border_color=Colors.PRIMARY,
            prefix_icon=icons.CALENDAR_TODAY,
            on_change=self.format_date,
        )
        
        self.local_evento_field = ft.TextField(
            label="Local do Evento",
            hint_text="Endereço do evento",
            border_color=Colors.GRAY,
            focused_border_color=Colors.PRIMARY,
            prefix_icon=icons.LOCATION_ON,
            multiline=True,
            min_lines=2,
            max_lines=3,
        )
        
        self.forma_pagamento_dropdown = ft.Dropdown(
            label="Forma de Pagamento",
            border_color=Colors.GRAY,
            focused_border_color=Colors.PRIMARY,
            options=[
                ft.dropdown.Option("dinheiro", "Dinheiro"),
                ft.dropdown.Option("cartao", "Cartão"),
                ft.dropdown.Option("pix", "PIX"),
                ft.dropdown.Option("transferencia", "Transferência"),
            ],
            value="dinheiro",
        )
        
        self.finalizar_button = ft.ElevatedButton(
            text="FINALIZAR CONTRATO",
            width=300,
            height=50,
            bgcolor=Colors.SUCCESS,
            color=Colors.WHITE,
            style=ft.ButtonStyle(
                text_style=ft.TextStyle(size=16, weight=ft.FontWeight.BOLD),
                shape=ft.RoundedRectangleBorder(radius=25),
            ),
            on_click=self.handle_finalizar,
            visible=False,
        )
        
        # Carregar serviços
        self.load_servicos()

    def load_servicos(self):
        """Carregar serviços disponíveis"""
        try:
            query = "SELECT * FROM servicos WHERE ativo = TRUE ORDER BY nome"
            result = self.db.execute_query(query)
            self.servicos_disponiveis = result if result else []
            self.update_servicos_list()
            
        except Exception as e:
            print(f"Erro ao carregar serviços: {e}")
            self.show_error("Erro ao carregar serviços disponíveis")

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

    def toggle_servico(self, servico, e):
        """Alternar seleção de serviço"""
        if e.control.value:
            self.servicos_selecionados.append(servico)
        else:
            self.servicos_selecionados = [s for s in self.servicos_selecionados if s['id'] != servico['id']]
        
        self.update_total()
        self.update_finalizar_button()

    def update_servicos_list(self):
        """Atualizar lista de serviços"""
        self.servicos_list.controls.clear()
        
        for servico in self.servicos_disponiveis:
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

    def update_total(self):
        """Atualizar total"""
        total = sum(float(s['preco']) for s in self.servicos_selecionados)
        
        self.total_container.content = ft.Container(
            content=ft.Text(
                f"Total: R$ {total:.2f}",
                size=20,
                weight=ft.FontWeight.BOLD,
                color=Colors.PRIMARY,
            ),
            bgcolor=Colors.LIGHT_GRAY,
            padding=15,
            border_radius=10,
            alignment=ft.alignment.center,
        )
        self.page.update()

    def update_finalizar_button(self):
        """Atualizar visibilidade do botão finalizar"""
        self.finalizar_button.visible = len(self.servicos_selecionados) > 0
        self.page.update()

    def validate_form(self):
        """Validar formulário"""
        errors = []
        
        if not self.servicos_selecionados:
            errors.append("Selecione pelo menos um serviço")
            
        if not self.data_evento_field.value:
            errors.append("Data do evento é obrigatória")
        else:
            # Validar formato de data
            try:
                date_parts = self.data_evento_field.value.split('/')
                if len(date_parts) != 3:
                    errors.append("Data inválida. Use o formato DD/MM/AAAA")
                else:
                    day, month, year = map(int, date_parts)
                    event_date = datetime(year, month, day).date()
                    if event_date <= datetime.now().date():
                        errors.append("Data do evento deve ser futura")
            except:
                errors.append("Data inválida. Use o formato DD/MM/AAAA")
                
        if not self.local_evento_field.value:
            errors.append("Local do evento é obrigatório")
            
        return errors

    def handle_finalizar(self, e):
        """Finalizar contrato"""
        # Validar formulário
        errors = self.validate_form()
        if errors:
            self.show_error("\n".join(errors))
            return
        
        try:
            # Primeiro, salvar o cliente se não existir
            from src.services.cliente_service import ClienteService
            cliente_service = ClienteService(self.db)
            
            cliente_result = cliente_service.create(
                self.cliente_data['nome'],
                self.cliente_data['cpf'],
                self.cliente_data['endereco'],
                self.cliente_data['telefone'],
                self.cliente_data['email']
            )
            
            if not cliente_result.get('success'):
                # Se der erro, pode ser porque cliente já existe
                # Vamos buscar pelo CPF
                query = "SELECT id FROM clientes WHERE cpf = %s"
                result = self.db.execute_query(query, (self.cliente_data['cpf'],))
                if result:
                    cliente_id = result[0]['id']
                else:
                    self.show_error("Erro ao processar cliente")
                    return
            else:
                cliente_id = cliente_result['cliente_id']
            
            # Criar contrato
            numero_contrato = f"CT{datetime.now().strftime('%Y%m%d%H%M%S')}"
            total = sum(float(s['preco']) for s in self.servicos_selecionados)
            
            # Converter data
            date_parts = self.data_evento_field.value.split('/')
            data_evento = f"{date_parts[2]}-{date_parts[1]}-{date_parts[0]}"
            
            contrato_query = """
            INSERT INTO contratos (numero_contrato, cliente_id, data_evento, local_evento, 
                                 forma_pagamento, valor_total, status, created_at)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            """
            
            contrato_id = self.db.execute_insert(
                contrato_query,
                (numero_contrato, cliente_id, data_evento, self.local_evento_field.value,
                 self.forma_pagamento_dropdown.value, total, 'ativo', datetime.now())
            )
            
            if contrato_id:
                # Inserir serviços do contrato
                for servico in self.servicos_selecionados:
                    servico_query = """
                    INSERT INTO contrato_servicos (contrato_id, servico_id, quantidade, preco_unitario)
                    VALUES (%s, %s, %s, %s)
                    """
                    self.db.execute_insert(
                        servico_query,
                        (contrato_id, servico['id'], 1, servico['preco'])
                    )
                
                self.show_success(f"Contrato {numero_contrato} criado com sucesso!")
                self.navigate_to("contratos")
            else:
                self.show_error("Erro ao criar contrato")
                
        except Exception as ex:
            self.show_error(f"Erro ao finalizar contrato: {str(ex)}")

    def build(self):
        """Construir a view"""
        return ft.Container(
            content=ft.Column(
                [
                    # Título
                    ft.Container(
                        content=ft.Text(
                            "Selecionar Serviços",
                            size=24,
                            weight=ft.FontWeight.BOLD,
                            color=Colors.PRIMARY,
                            text_align=ft.TextAlign.CENTER,
                        ),
                        padding=20,
                    ),
                    
                    # Info do cliente
                    ft.Container(
                        content=ft.Text(
                            f"Cliente: {self.cliente_data.get('nome', 'N/A')}",
                            size=16,
                            weight=ft.FontWeight.BOLD,
                            color=Colors.DARK_GRAY,
                        ),
                        padding=ft.padding.symmetric(horizontal=20),
                    ),
                    
                    # Lista de serviços
                    ft.Container(
                        content=ft.Column([
                            ft.Text(
                                "Serviços Disponíveis:",
                                size=18,
                                weight=ft.FontWeight.BOLD,
                                color=Colors.DARK_GRAY,
                            ),
                            self.servicos_list,
                        ]),
                        padding=20,
                        height=300,
                        scroll=ft.ScrollMode.AUTO,
                    ),
                    
                    # Total
                    ft.Container(
                        content=self.total_container,
                        padding=ft.padding.symmetric(horizontal=20),
                    ),
                    
                    # Formulário do evento
                    ft.Container(
                        content=ft.Column([
                            self.data_evento_field,
                            ft.Container(height=15),
                            self.local_evento_field,
                            ft.Container(height=15),
                            self.forma_pagamento_dropdown,
                            ft.Container(height=20),
                            self.finalizar_button,
                        ]),
                        padding=20,
                    ),
                ],
                scroll=ft.ScrollMode.AUTO,
            ),
            bgcolor=Colors.WHITE,
            expand=True,
        )