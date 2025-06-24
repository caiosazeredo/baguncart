# src/views/dashboard_view.py
import flet as ft
from datetime import datetime, timedelta
from src.utils.colors import Colors

class DashboardView:
    def __init__(self, page, db, navigate_to, current_user):
        self.page = page
        self.db = db
        self.navigate_to = navigate_to
        self.current_user = current_user
        
        # Calcular dias até próximo evento
        self.days_remaining = self.calculate_days_to_next_event()

    def calculate_days_to_next_event(self):
        """Calcular dias até o próximo evento"""
        try:
            # Buscar próximo evento no banco
            query = """
            SELECT MIN(data_evento) as proximo_evento 
            FROM contratos 
            WHERE data_evento >= CURDATE() 
            AND status = 'ativo'
            """
            result = self.db.execute_query(query)
            
            if result and result[0]['proximo_evento']:
                proximo_evento = result[0]['proximo_evento']
                if isinstance(proximo_evento, str):
                    # Se vier como string, converter para datetime
                    from datetime import datetime
                    proximo_evento = datetime.strptime(proximo_evento, '%Y-%m-%d').date()
                
                hoje = datetime.now().date()
                delta = proximo_evento - hoje
                return max(0, delta.days)
            else:
                # Se não há eventos, usar data fictícia (Ano Novo)
                return 15
                
        except Exception as e:
            print(f"Erro ao calcular dias: {e}")
            return 15

    def create_menu_item(self, title, icon, color, on_click):
        """Criar item do menu"""
        return ft.Container(
            content=ft.Column(
                [
                    ft.Icon(
                        icon,
                        size=40,
                        color=Colors.WHITE,
                    ),
                    ft.Text(
                        title,
                        size=12,
                        weight=ft.FontWeight.BOLD,
                        color=Colors.WHITE,
                        text_align=ft.TextAlign.CENTER,
                    ),
                ],
                alignment=ft.MainAxisAlignment.CENTER,
                horizontal_alignment=ft.CrossAxisAlignment.CENTER,
                spacing=8,
            ),
            bgcolor=color,
            border_radius=10,
            padding=15,
            width=110,
            height=100,
            on_click=on_click,
            ink=True,
        )

    def get_stats_summary(self):
        """Obter resumo de estatísticas"""
        try:
            # Total de clientes
            query = "SELECT COUNT(*) as total FROM clientes"
            result = self.db.execute_query(query)
            total_clientes = result[0]['total'] if result else 0
            
            # Total de contratos ativos
            query = "SELECT COUNT(*) as total FROM contratos WHERE status = 'ativo'"
            result = self.db.execute_query(query)
            total_contratos = result[0]['total'] if result else 0
            
            # Valor total em contratos
            query = "SELECT SUM(valor_total) as total FROM contratos WHERE status = 'ativo'"
            result = self.db.execute_query(query)
            valor_total = result[0]['total'] if result and result[0]['total'] else 0
            
            return {
                'clientes': total_clientes,
                'contratos': total_contratos,
                'valor_total': valor_total
            }
            
        except Exception as e:
            print(f"Erro ao obter estatísticas: {e}")
            return {'clientes': 0, 'contratos': 0, 'valor_total': 0}

    def build(self):
        """Construir a view"""
        stats = self.get_stats_summary()
        
        return ft.Container(
            content=ft.Column(
                [
                    # Header com informações do usuário
                    ft.Container(
                        content=ft.Row(
                            [
                                ft.Icon(ft.icons.PERSON, color=Colors.PRIMARY, size=30),
                                ft.Column(
                                    [
                                        ft.Text(
                                            self.current_user['nome'],
                                            size=18,
                                            weight=ft.FontWeight.BOLD,
                                            color=Colors.DARK_GRAY,
                                        ),
                                        ft.Text(
                                            "Administrador",
                                            size=14,
                                            color=Colors.GRAY,
                                        ),
                                    ],
                                    spacing=2,
                                ),
                            ],
                            alignment=ft.MainAxisAlignment.START,
                        ),
                        padding=20,
                    ),
                    
                    # Seção de boas-vindas
                    ft.Container(
                        content=ft.Column(
                            [
                                ft.Text(
                                    "Seja Bem Vindo a",
                                    size=16,
                                    color=Colors.WHITE,
                                    text_align=ft.TextAlign.CENTER,
                                ),
                                ft.Text(
                                    "BAGUNÇART EVENTOS",
                                    size=20,
                                    weight=ft.FontWeight.BOLD,
                                    color=Colors.SECONDARY,
                                    text_align=ft.TextAlign.CENTER,
                                ),
                                ft.Container(height=20),
                                ft.Text(
                                    str(self.days_remaining),
                                    size=60,
                                    weight=ft.FontWeight.BOLD,
                                    color=Colors.SECONDARY,
                                    text_align=ft.TextAlign.CENTER,
                                ),
                                ft.Text(
                                    "DIAS",
                                    size=18,
                                    weight=ft.FontWeight.BOLD,
                                    color=Colors.WHITE,
                                    text_align=ft.TextAlign.CENTER,
                                ),
                                ft.Container(height=10),
                                ft.Text(
                                    "Para o melhor dia de todos",
                                    size=14,
                                    color=Colors.WHITE,
                                    text_align=ft.TextAlign.CENTER,
                                ),
                                ft.Container(height=10),
                                ft.Container(
                                    content=ft.Column(
                                        [
                                            ft.Text(
                                                "DIA ESPECIAL",
                                                size=14,
                                                weight=ft.FontWeight.BOLD,
                                                color=Colors.WHITE,
                                            ),
                                            ft.Text(
                                                "01/01/25",
                                                size=12,
                                                color=Colors.WHITE,
                                            ),
                                        ],
                                        horizontal_alignment=ft.CrossAxisAlignment.CENTER,
                                        spacing=2,
                                    ),
                                ),
                            ],
                            horizontal_alignment=ft.CrossAxisAlignment.CENTER,
                            spacing=5,
                        ),
                        bgcolor=Colors.PRIMARY,
                        border_radius=15,
                        padding=30,
                        margin=ft.margin.symmetric(horizontal=20),
                    ),
                    
                    ft.Container(height=20),
                    
                    # Estatísticas rápidas
                    ft.Container(
                        content=ft.Row(
                            [
                                ft.Container(
                                    content=ft.Column(
                                        [
                                            ft.Text(
                                                str(stats['clientes']),
                                                size=24,
                                                weight=ft.FontWeight.BOLD,
                                                color=Colors.PRIMARY,
                                            ),
                                            ft.Text(
                                                "Clientes",
                                                size=12,
                                                color=Colors.GRAY,
                                            ),
                                        ],
                                        horizontal_alignment=ft.CrossAxisAlignment.CENTER,
                                    ),
                                    bgcolor=Colors.LIGHT_GRAY,
                                    border_radius=10,
                                    padding=15,
                                    expand=True,
                                ),
                                ft.Container(width=10),
                                ft.Container(
                                    content=ft.Column(
                                        [
                                            ft.Text(
                                                str(stats['contratos']),
                                                size=24,
                                                weight=ft.FontWeight.BOLD,
                                                color=Colors.PRIMARY,
                                            ),
                                            ft.Text(
                                                "Contratos",
                                                size=12,
                                                color=Colors.GRAY,
                                            ),
                                        ],
                                        horizontal_alignment=ft.CrossAxisAlignment.CENTER,
                                    ),
                                    bgcolor=Colors.LIGHT_GRAY,
                                    border_radius=10,
                                    padding=15,
                                    expand=True,
                                ),
                                ft.Container(width=10),
                                ft.Container(
                                    content=ft.Column(
                                        [
                                            ft.Text(
                                                f"R$ {stats['valor_total']:.0f}",
                                                size=20,
                                                weight=ft.FontWeight.BOLD,
                                                color=Colors.PRIMARY,
                                            ),
                                            ft.Text(
                                                "Receita",
                                                size=12,
                                                color=Colors.GRAY,
                                            ),
                                        ],
                                        horizontal_alignment=ft.CrossAxisAlignment.CENTER,
                                    ),
                                    bgcolor=Colors.LIGHT_GRAY,
                                    border_radius=10,
                                    padding=15,
                                    expand=True,
                                ),
                            ],
                        ),
                        padding=ft.padding.symmetric(horizontal=20),
                    ),
                    
                    ft.Container(height=30),
                    
                    # Menu principal
                    ft.Container(
                        content=ft.Column(
                            [
                                # Primeira linha
                                ft.Row(
                                    [
                                        self.create_menu_item(
                                            "CLIENTES",
                                            ft.icons.PEOPLE,
                                            Colors.SECONDARY,
                                            lambda _: self.navigate_to("clientes")
                                        ),
                                        self.create_menu_item(
                                            "CONTRATOS",
                                            ft.icons.DESCRIPTION,
                                            Colors.SECONDARY,
                                            lambda _: self.navigate_to("contratos")
                                        ),
                                        self.create_menu_item(
                                            "PROMOÇÃO",
                                            ft.icons.CAMPAIGN,
                                            Colors.SECONDARY,
                                            lambda _: self.navigate_to("promocao")
                                        ),
                                    ],
                                    alignment=ft.MainAxisAlignment.SPACE_BETWEEN,
                                ),
                                
                                ft.Container(height=15),
                                
                                # Segunda linha
                                ft.Row(
                                    [
                                        self.create_menu_item(
                                            "CADASTRAR\nCLIENTE",
                                            ft.icons.PERSON_ADD,
                                            Colors.SECONDARY,
                                            lambda _: self.navigate_to("cadastro_cliente")
                                        ),
                                        self.create_menu_item(
                                            "NOTIFICAÇÃO",
                                            ft.icons.NOTIFICATIONS,
                                            Colors.SECONDARY,
                                            lambda _: self.navigate_to("notificacao")
                                        ),
                                        ft.Container(width=110),  # Espaço vazio para balancear
                                    ],
                                    alignment=ft.MainAxisAlignment.SPACE_BETWEEN,
                                ),
                            ],
                        ),
                        padding=ft.padding.symmetric(horizontal=20),
                    ),
                    
                    ft.Container(height=20),
                    
                    # Redes sociais footer
                    ft.Container(
                        content=ft.Row(
                            [
                                ft.IconButton(
                                    ft.icons.PHONE,
                                    icon_color=Colors.WHITE,
                                    bgcolor=Colors.SUCCESS,
                                    icon_size=30,
                                ),
                                ft.IconButton(
                                    ft.icons.PHOTO_CAMERA,
                                    icon_color=Colors.WHITE,
                                    bgcolor=Colors.SUCCESS,
                                    icon_size=30,
                                ),
                                ft.IconButton(
                                    ft.icons.THUMB_UP,
                                    icon_color=Colors.WHITE,
                                    bgcolor=Colors.SUCCESS,
                                    icon_size=30,
                                ),
                                ft.IconButton(
                                    ft.icons.PLAY_ARROW,
                                    icon_color=Colors.WHITE,
                                    bgcolor=Colors.SUCCESS,
                                    icon_size=30,
                                ),
                            ],
                            alignment=ft.MainAxisAlignment.SPACE_AROUND,
                        ),
                        bgcolor=Colors.SECONDARY,
                        padding=15,
                        margin=ft.margin.only(top=20),
                    ),
                ],
                scroll=ft.ScrollMode.AUTO,
                expand=True,
            ),
            bgcolor=Colors.WHITE,
            expand=True,
        )