# src/views/servicos_view.py
import flet as ft
from src.utils.colors import Colors

class ServicosView:
    def __init__(self, page, db, navigate_to, show_success, show_error, cliente_data=None):
        self.page = page
        self.navigate_to = navigate_to
        
    def build(self):
        return ft.Container(
            content=ft.Column(
                [
                    ft.Text("Seleção de Serviços", size=24, weight=ft.FontWeight.BOLD, color=Colors.PRIMARY),
                    ft.Text("🚧 Em desenvolvimento..."),
                    ft.ElevatedButton("Voltar", on_click=lambda _: self.navigate_to("cadastro_cliente"))
                ],
                alignment=ft.MainAxisAlignment.CENTER,
                horizontal_alignment=ft.CrossAxisAlignment.CENTER,
            ),
            bgcolor=Colors.WHITE,
            expand=True,
        )
