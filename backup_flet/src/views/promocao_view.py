# src/views/promocao_view.py
import flet as ft
from src.utils.colors import Colors

class PromocaoView:
    def __init__(self, page, db, navigate_to, show_success, show_error):
        self.page = page
        self.navigate_to = navigate_to
        
    def build(self):
        return ft.Container(
            content=ft.Column(
                [
                    ft.Text("Criar Promoção", size=24, weight=ft.FontWeight.BOLD, color=Colors.PRIMARY),
                    ft.Text("🚧 Em desenvolvimento..."),
                    ft.ElevatedButton("Voltar ao Dashboard", on_click=lambda _: self.navigate_to("dashboard"))
                ],
                alignment=ft.MainAxisAlignment.CENTER,
                horizontal_alignment=ft.CrossAxisAlignment.CENTER,
            ),
            bgcolor=Colors.WHITE,
            expand=True,
        )
