# src/views/notificacao_view.py
import flet as ft
from flet import icons
from datetime import datetime
from src.utils.colors import Colors

class NotificacaoView:
    def __init__(self, page, db, navigate_to, show_success, show_error):
        self.page = page
        self.db = db
        self.navigate_to = navigate_to
        self.show_success = show_success
        self.show_error = show_error
        
        # Listas
        self.clientes = []
        self.contratos = []
        self.servicos = []
        
        # Componentes
        self.tipo_notificacao = ft.RadioGroup(
            content=ft.Column([
                ft.Radio(value="geral", label="Notificação Geral"),
                ft.Radio(value="cliente", label="Cliente Específico"),
                ft.Radio(value="contrato", label="Contrato Específico"),
            ]),
            value="geral",
            on_change=self.on_tipo_change,
        )
        
        self.cliente_dropdown = ft.Dropdown(
            label="Cliente",
            border_color=Colors.GRAY,
            focused_border_color=Colors.PRIMARY,
            hint_text="Selecione um cliente",
            visible=False,
            on_change=self.on_cliente_change,
        )
        
        self.contrato_dropdown = ft.Dropdown(
            label="Contrato",
            border_color=Colors.GRAY,
            focused_border_color=Colors.PRIMARY,
            hint_text="Selecione um contrato",
            visible=False,
        )
        
        self.templates_dropdown = ft.Dropdown(
            label="Template de Mensagem",
            border_color=Colors.GRAY,
            focused_border_color=Colors.PRIMARY,
            hint_text="Selecione um template",
            options=[
                ft.dropdown.Option("evento_proximo", "Evento se aproximando"),
                ft.dropdown.Option("confirmacao", "Confirmação de agendamento"),
                ft.dropdown.Option("lembrete_pagamento", "Lembrete de pagamento"),
                ft.dropdown.Option("promocao", "Promoção especial"),
                ft.dropdown.Option("agradecimento", "Agradecimento"),
                ft.dropdown.Option("personalizada", "Mensagem personalizada"),
            ],
            on_change=self.on_template_change,
        )
        
        self.mensagem_field = ft.TextField(
            label="Mensagem",
            hint_text="Digite sua mensagem aqui",
            border_color=Colors.GRAY,
            focused_border_color=Colors.PRIMARY,
            multiline=True,
            min_lines=5,
            max_lines=10,
        )
        
        self.preview_container = ft.Container(
            content=ft.Text("Preview da mensagem aparecerá aqui"),
            bgcolor=Colors.LIGHT_GRAY,
            padding=15,
            border_radius=10,
            visible=False,
        )
        
        self.enviar_button = ft.ElevatedButton(
            text="ENVIAR NOTIFICAÇÃO",
            width=300,
            height=50,
            bgcolor=Colors.SUCCESS,
            color=Colors.WHITE,
            style=ft.ButtonStyle(
                text_style=ft.TextStyle(size=16, weight=ft.FontWeight.BOLD),
                shape=ft.RoundedRectangleBorder(radius=25),
            ),
            on_click=self.handle_enviar,
        )
        
        self.loading = ft.ProgressRing(
            visible=False,
            color=Colors.PRIMARY,
        )
        
        # Carregar dados
        self.load_data()

    def load_data(self):
        """Carregar clientes, contratos e serviços"""
        try:
            # Carregar clientes
            query = "SELECT id, nome, telefone FROM clientes ORDER BY nome"
            result = self.db.execute_query(query)
            self.clientes = result if result else []
            
            # Preencher dropdown de clientes
            self.cliente_dropdown.options = [
                ft.dropdown.Option(str(cliente['id']), 
                                 f"{cliente['nome']} - {cliente.get('telefone', 'N/A')}")
                for cliente in self.clientes
            ]
            
            # Carregar contratos ativos
            query = """
            SELECT c.id, c.numero_contrato, c.data_evento, cl.nome as cliente_nome
            FROM contratos c
            JOIN clientes cl ON c.cliente_id = cl.id
            WHERE c.status = 'ativo'
            ORDER BY c.data_evento
            """
            result = self.db.execute_query(query)
            self.contratos = result if result else []
            
            # Preencher dropdown de contratos
            self.contrato_dropdown.options = [
                ft.dropdown.Option(str(contrato['id']), 
                                 f"{contrato['numero_contrato']} - {contrato['cliente_nome']}")
                for contrato in self.contratos
            ]
            
            self.page.update()
            
        except Exception as e:
            print(f"Erro ao carregar dados: {e}")
            self.show_error("Erro ao carregar dados")

    def on_tipo_change(self, e):
        """Quando tipo de notificação muda"""
        tipo = e.control.value
        
        if tipo == "geral":
            self.cliente_dropdown.visible = False
            self.contrato_dropdown.visible = False
        elif tipo == "cliente":
            self.cliente_dropdown.visible = True
            self.contrato_dropdown.visible = False
        elif tipo == "contrato":
            self.cliente_dropdown.visible = False
            self.contrato_dropdown.visible = True
            
        self.page.update()

    def on_cliente_change(self, e):
        """Quando cliente é selecionado"""
        # Filtrar contratos do cliente selecionado
        if e.control.value:
            cliente_id = int(e.control.value)
            contratos_cliente = [c for c in self.contratos if c.get('cliente_id') == cliente_id]
            
            # Atualizar dropdown de contratos se necessário
            # (funcionalidade adicional para mostrar contratos do cliente)

    def on_template_change(self, e):
        """Quando template é selecionado"""
        template = e.control.value
        
        templates = {
            "evento_proximo": "Olá! Seu evento está se aproximando. Data: [DATA]. Local: [LOCAL]. Estamos ansiosos para tornar seu dia especial! 🎉",
            "confirmacao": "Confirmamos o agendamento do seu evento para [DATA] às [HORA]. Local: [LOCAL]. Em caso de dúvidas, entre em contato conosco!",
            "lembrete_pagamento": "Lembrete amigável: O pagamento do seu evento está programado para [DATA]. Valor: R$ [VALOR]. Obrigado!",
            "promocao": "🔥 PROMOÇÃO ESPECIAL! Desconto de [DESCONTO]% em nossos serviços. Válido até [VALIDADE]. Não perca esta oportunidade!",
            "agradecimento": "Muito obrigado por escolher nossos serviços! Foi um prazer participar do seu evento. Esperamos vê-lo novamente em breve! ⭐",
            "personalizada": "",
        }
        
        self.mensagem_field.value = templates.get(template, "")
        self.update_preview()
        self.page.update()

    def update_preview(self):
        """Atualizar preview da mensagem"""
        mensagem = self.mensagem_field.value
        if mensagem:
            # Substituir placeholders para preview
            preview_text = mensagem
            preview_text = preview_text.replace("[DATA]", "01/01/2025")
            preview_text = preview_text.replace("[HORA]", "14:00")
            preview_text = preview_text.replace("[LOCAL]", "Salão de Festas XYZ")
            preview_text = preview_text.replace("[VALOR]", "500,00")
            preview_text = preview_text.replace("[DESCONTO]", "20")
            preview_text = preview_text.replace("[VALIDADE]", "31/12/2024")
            
            self.preview_container.content = ft.Column([
                ft.Text(
                    "PREVIEW:",
                    weight=ft.FontWeight.BOLD,
                    color=Colors.PRIMARY,
                ),
                ft.Text(preview_text),
            ])
            self.preview_container.visible = True
        else:
            self.preview_container.visible = False
            
        self.page.update()

    def validate_form(self):
        """Validar formulário"""
        errors = []
        
        tipo = self.tipo_notificacao.value
        
        if tipo == "cliente" and not self.cliente_dropdown.value:
            errors.append("Selecione um cliente")
            
        if tipo == "contrato" and not self.contrato_dropdown.value:
            errors.append("Selecione um contrato")
            
        if not self.mensagem_field.value:
            errors.append("Digite uma mensagem")
            
        return errors

    def handle_enviar(self, e):
        """Enviar notificação"""
        # Validar formulário
        errors = self.validate_form()
        if errors:
            self.show_error("\n".join(errors))
            return
        
        # Mostrar loading
        self.enviar_button.visible = False
        self.loading.visible = True
        self.page.update()
        
        try:
            tipo = self.tipo_notificacao.value
            mensagem = self.mensagem_field.value
            
            if tipo == "geral":
                # Enviar para todos os clientes
                for cliente in self.clientes:
                    self.save_notification(cliente['id'], None, [], mensagem)
                    
                self.show_success(f"Notificação enviada para {len(self.clientes)} clientes!")
                
            elif tipo == "cliente":
                # Enviar para cliente específico
                cliente_id = int(self.cliente_dropdown.value)
                self.save_notification(cliente_id, None, [], mensagem)
                self.show_success("Notificação enviada para o cliente!")
                
            elif tipo == "contrato":
                # Enviar para cliente do contrato
                contrato_id = int(self.contrato_dropdown.value)
                contrato = next((c for c in self.contratos if c['id'] == contrato_id), None)
                if contrato:
                    # Buscar cliente do contrato
                    query = "SELECT cliente_id FROM contratos WHERE id = %s"
                    result = self.db.execute_query(query, (contrato_id,))
                    if result:
                        cliente_id = result[0]['cliente_id']
                        self.save_notification(cliente_id, contrato_id, [], mensagem)
                        self.show_success("Notificação enviada para o cliente do contrato!")
                
            # Limpar formulário
            self.clear_form()
                
        except Exception as ex:
            self.show_error(f"Erro ao enviar notificação: {str(ex)}")
        
        finally:
            self.enviar_button.visible = True
            self.loading.visible = False
            self.page.update()

    def save_notification(self, cliente_id, contrato_id, servico_ids, mensagem):
        """Salvar notificação no banco"""
        try:
            query = """
            INSERT INTO notificacoes (cliente_id, contrato_id, servico_ids, mensagem, 
                                    enviado, data_envio, created_at)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
            """
            
            import json
            self.db.execute_insert(
                query,
                (cliente_id, contrato_id, json.dumps(servico_ids), mensagem,
                 True, datetime.now(), datetime.now())
            )
            
        except Exception as e:
            print(f"Erro ao salvar notificação: {e}")

    def clear_form(self):
        """Limpar formulário"""
        self.tipo_notificacao.value = "geral"
        self.cliente_dropdown.value = None
        self.cliente_dropdown.visible = False
        self.contrato_dropdown.value = None
        self.contrato_dropdown.visible = False
        self.templates_dropdown.value = None
        self.mensagem_field.value = ""
        self.preview_container.visible = False
        self.page.update()

    def build(self):
        """Construir a view"""
        return ft.Container(
            content=ft.Column(
                [
                    # Título
                    ft.Container(
                        content=ft.Text(
                            "Enviar Notificação",
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
                                # Tipo de notificação
                                ft.Text(
                                    "Tipo de Notificação:",
                                    size=16,
                                    weight=ft.FontWeight.BOLD,
                                    color=Colors.DARK_GRAY,
                                ),
                                self.tipo_notificacao,
                                
                                ft.Container(height=20),
                                
                                # Seleções específicas
                                self.cliente_dropdown,
                                self.contrato_dropdown,
                                
                                ft.Container(height=20),
                                
                                # Template
                                self.templates_dropdown,
                                
                                ft.Container(height=15),
                                
                                # Mensagem
                                self.mensagem_field,
                                
                                ft.Container(height=15),
                                
                                # Preview
                                self.preview_container,
                                
                                ft.Container(height=30),
                                
                                # Botão e loading
                                ft.Stack(
                                    [
                                        self.enviar_button,
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