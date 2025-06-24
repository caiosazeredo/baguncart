#!/usr/bin/env python3
# loading_animations_transparency.py - Funcionalidades Específicas

from kivy.lang import Builder
from kivymd.app import MDApp
from kivymd.uix.screen import MDScreen
from kivymd.uix.card import MDCard
from kivymd.uix.button import MDButton, MDButtonText
from kivymd.uix.dialog import MDDialog, MDDialogContentContainer
from kivymd.uix.progressindicator import MDCircularProgressIndicator
from kivymd.uix.snackbar import MDSnackbar, MDSnackbarText
from kivymd.uix.bottomsheet import MDBottomSheet, MDBottomSheetContent
from kivymd.uix.expansionpanel import MDExpansionPanel, MDExpansionPanelOneLine
from kivymd.uix.imagelist import MDSmartTile
from kivymd.uix.floatlayout import MDFloatLayout
from kivymd.uix.anchorlayout import MDAnchorLayout
from kivy.animation import Animation
from kivy.clock import Clock
from kivy.metrics import dp
from kivy.properties import StringProperty, BooleanProperty, NumericProperty
from kivy.core.window import Window
import json
import asyncio
from datetime import datetime

# KV com Loading, Animações e Transparência
TRANSPARENCY_KV = '''
#:import get_color_from_hex kivy.utils.get_color_from_hex

# =============== LOADING COMPONENTS ===============
<LoadingScreen>:
    name: "loading"
    md_bg_color: self.theme_cls.backgroundColor
    
    MDAnchorLayout:
        anchor_x: "center"
        anchor_y: "center"
        
        MDCard:
            style: "elevated"
            size_hint: None, None
            size: dp(300), dp(200)
            md_bg_color: self.theme_cls.surfaceColor
            
            MDBoxLayout:
                orientation: "vertical"
                padding: dp(30)
                spacing: dp(20)
                
                # Logo animado
                MDBoxLayout:
                    orientation: "horizontal"
                    spacing: dp(10)
                    size_hint_y: None
                    height: dp(60)
                    
                    MDLabel:
                        text: "🎉"
                        font_size: "40sp"
                        size_hint_x: None
                        width: dp(60)
                        halign: "center"
                        
                    MDLabel:
                        text: "BagunçArt"
                        font_style: "Display"
                        role: "small"
                        theme_text_color: "Custom"
                        text_color: get_color_from_hex("#8B2F8B")
                        adaptive_height: True
                
                # Progress indicator
                MDAnchorLayout:
                    anchor_x: "center"
                    size_hint_y: None
                    height: dp(60)
                    
                    MDCircularProgressIndicator:
                        id: progress
                        size_hint: None, None
                        size: dp(48), dp(48)
                        active: True
                        line_width: dp(4)
                        color: get_color_from_hex("#FF8C00")
                
                MDLabel:
                    id: loading_text
                    text: "Carregando..."
                    font_style: "Body"
                    role: "medium"
                    theme_text_color: "Secondary"
                    halign: "center"
                    adaptive_height: True

# =============== TRANSPARÊNCIA DE CONTRATOS ===============
<TransparenciaScreen>:
    name: "transparencia"
    md_bg_color: self.theme_cls.backgroundColor
    
    MDBoxLayout:
        orientation: "vertical"
        
        MDTopAppBar:
            title: "Transparência de Contratos"
            left_action_items: [["arrow-left", lambda x: app.change_screen("dashboard")]]
            right_action_items: [["refresh", lambda x: root.refresh_contratos()]]
            md_bg_color: get_color_from_hex("#8B2F8B") 
            specific_text_color: "white"
        
        MDScrollView:
            
            MDBoxLayout:
                orientation: "vertical"
                padding: dp(16)
                spacing: dp(16)
                adaptive_height: True
                
                # Header informativo
                MDCard:
                    style: "filled"
                    md_bg_color: get_color_from_hex("#E3F2FD")
                    padding: dp(20)
                    
                    MDBoxLayout:
                        orientation: "vertical"
                        spacing: dp(8)
                        
                        MDLabel:
                            text: "🔍 Transparência Total"
                            font_style: "Headline"
                            role: "small"
                            theme_text_color: "Primary"
                            adaptive_height: True
                            
                        MDLabel:
                            text: "Acompanhe todos os detalhes dos seus contratos em tempo real. Confirmações automáticas e histórico completo."
                            font_style: "Body"
                            role: "medium"
                            theme_text_color: "Secondary"
                            adaptive_height: True
                
                # Lista de contratos com expansão
                MDLabel:
                    text: "📋 Seus Contratos"
                    font_style: "Headline"
                    role: "small"
                    theme_text_color: "Primary"
                    adaptive_height: True
                
                # Contratos expansíveis
                MDExpansionPanel:
                    id: contrato_1
                    content: ContratoDetails(numero="7.589", cliente="Gabriel Oliveira", data="25/05/25", valor="R$ 1.250,00", servicos=["DJ", "Decoração", "Garçom"])
                    panel_cls: ContratoPanel(text="Contrato 7.589 - Gabriel Oliveira", secondary_text="25/05/2025 • R$ 1.250,00", status="confirmado")
                
                MDExpansionPanel:
                    id: contrato_2
                    content: ContratoDetails(numero="7.709", cliente="Maria Silva", data="30/06/25", valor="R$ 850,00", servicos=["Palhaço", "Pula-pula"])
                    panel_cls: ContratoPanel(text="Contrato 7.709 - Maria Silva", secondary_text="30/06/2025 • R$ 850,00", status="pendente")
                
                MDExpansionPanel:
                    id: contrato_3
                    content: ContratoDetails(numero="7.852", cliente="João Santos", data="30/09/25", valor="R$ 2.100,00", servicos=["DJ", "Decoração", "Garçom", "Barman", "Recepção"])
                    panel_cls: ContratoPanel(text="Contrato 7.852 - João Santos", secondary_text="30/09/2025 • R$ 2.100,00", status="confirmado")

# =============== ANIMAÇÕES DE ENTRADA ===============
<AnimatedCard>:
    style: "elevated"
    ripple_behavior: True
    elevation: 2
    
    canvas.before:
        PushMatrix
        Scale:
            x: root.scale_x
            y: root.scale_y
            origin: self.center
    canvas.after:
        PopMatrix

# =============== DETALHES DO CONTRATO ===============
<ContratoDetails>:
    orientation: "vertical"
    spacing: dp(16)
    padding: dp(20)
    adaptive_height: True
    
    # Status do contrato
    MDCard:
        style: "filled"
        md_bg_color: get_color_from_hex("#E8F5E8") if root.status == "confirmado" else get_color_from_hex("#FFF3E0")
        padding: dp(12)
        size_hint_y: None
        height: dp(60)
        
        MDBoxLayout:
            orientation: "horizontal"
            spacing: dp(12)
            
            MDIcon:
                icon: "check-circle" if root.status == "confirmado" else "clock-outline"
                theme_icon_color: "Custom"
                icon_color: get_color_from_hex("#4CAF50") if root.status == "confirmado" else get_color_from_hex("#FF9800")
                size_hint_x: None
                width: dp(24)
                
            MDLabel:
                text: "✅ Contrato Confirmado" if root.status == "confirmado" else "⏳ Aguardando Confirmação"
                font_style: "Label"
                role: "large"
                theme_text_color: "Custom"
                text_color: get_color_from_hex("#4CAF50") if root.status == "confirmado" else get_color_from_hex("#FF9800")
                adaptive_height: True
    
    # Informações básicas
    MDCard:
        style: "outlined"
        padding: dp(16)
        
        MDBoxLayout:
            orientation: "vertical"
            spacing: dp(12)
            
            MDLabel:
                text: "📊 Informações do Contrato"
                font_style: "Label"
                role: "large"
                theme_text_color: "Primary"
                adaptive_height: True
            
            MDBoxLayout:
                orientation: "horizontal"
                spacing: dp(16)
                
                MDBoxLayout:
                    orientation: "vertical"
                    spacing: dp(4)
                    
                    MDLabel:
                        text: "Número"
                        font_style: "Body"
                        role: "small"
                        theme_text_color: "Secondary"
                        adaptive_height: True
                        
                    MDLabel:
                        text: root.numero
                        font_style: "Label"
                        role: "medium"
                        theme_text_color: "Primary"
                        adaptive_height: True
                
                MDBoxLayout:
                    orientation: "vertical"
                    spacing: dp(4)
                    
                    MDLabel:
                        text: "Data do Evento"
                        font_style: "Body"
                        role: "small"
                        theme_text_color: "Secondary"
                        adaptive_height: True
                        
                    MDLabel:
                        text: root.data
                        font_style: "Label"
                        role: "medium"
                        theme_text_color: "Primary"
                        adaptive_height: True
                
                MDBoxLayout:
                    orientation: "vertical"
                    spacing: dp(4)
                    
                    MDLabel:
                        text: "Valor Total"
                        font_style: "Body"
                        role: "small"
                        theme_text_color: "Secondary"
                        adaptive_height: True
                        
                    MDLabel:
                        text: root.valor
                        font_style: "Label"
                        role: "medium"
                        theme_text_color: "Custom"
                        text_color: get_color_from_hex("#4CAF50")
                        adaptive_height: True
    
    # Serviços contratados
    MDCard:
        style: "outlined"
        padding: dp(16)
        
        MDBoxLayout:
            orientation: "vertical"
            spacing: dp(12)
            
            MDLabel:
                text: "🛠️ Serviços Contratados"
                font_style: "Label"
                role: "large"
                theme_text_color: "Primary"
                adaptive_height: True
            
            ServicosGrid:
                id: servicos_grid
                servicos: root.servicos
    
    # Ações do contrato
    MDBoxLayout:
        orientation: "horizontal"
        spacing: dp(12)
        size_hint_y: None
        height: dp(48)
        
        MDButton:
            style: "outlined"
            
            MDButtonText:
                text: "📄 Download PDF"
            
            on_release: root.download_contrato()
        
        MDButton:
            style: "filled"
            md_bg_color: get_color_from_hex("#25D366")
            
            MDButtonText:
                text: "💬 WhatsApp"
                theme_text_color: "Custom"
                text_color: "white"
            
            on_release: root.send_whatsapp()
        
        MDButton:
            style: "text"
            
            MDButtonText:
                text: "✏️ Editar"
                
            on_release: root.edit_contrato()

# =============== GRID DE SERVIÇOS ===============
<ServicosGrid>:
    cols: 2
    spacing: dp(8)
    size_hint_y: None
    height: self.minimum_height
    adaptive_height: True

# =============== PANEL DE CONTRATO ===============
<ContratoPanel>:
    MDListItemLeadingIcon:
        icon: "check-circle" if root.status == "confirmado" else "clock-outline"
        theme_icon_color: "Custom"
        icon_color: get_color_from_hex("#4CAF50") if root.status == "confirmado" else get_color_from_hex("#FF9800")

# =============== LOADING BOTTOM SHEET ===============
<LoadingBottomSheet>:
    
    MDBottomSheetContent:
        padding: dp(20)
        spacing: dp(20)
        adaptive_height: True
        
        MDBoxLayout:
            orientation: "horizontal"
            spacing: dp(16)
            size_hint_y: None
            height: dp(60)
            
            MDCircularProgressIndicator:
                size_hint: None, None
                size: dp(40), dp(40)
                active: True
                color: get_color_from_hex("#FF8C00")
                
            MDBoxLayout:
                orientation: "vertical"
                spacing: dp(4)
                
                MDLabel:
                    text: root.title
                    font_style: "Label"
                    role: "large"
                    theme_text_color: "Primary"
                    adaptive_height: True
                    
                MDLabel:
                    text: root.message
                    font_style: "Body"
                    role: "medium"
                    theme_text_color: "Secondary"
                    adaptive_height: True
'''

class LoadingScreen(MDScreen):
    """Tela de loading animada"""
    
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.loading_messages = [
            "Carregando...",
            "Conectando ao servidor...",
            "Sincronizando dados...",
            "Preparando interface...",
            "Quase pronto..."
        ]
        self.current_message = 0
    
    def on_enter(self):
        """Iniciar animações de loading"""
        self.start_loading_animation()
        self.cycle_messages()
    
    def start_loading_animation(self):
        """Animação do logo"""
        logo = self.ids.get('logo')
        if logo:
            # Animação de pulsação
            anim = Animation(font_size="50sp", duration=1) + Animation(font_size="35sp", duration=1)
            anim.repeat = True
            anim.start(logo)
    
    def cycle_messages(self):
        """Alternar mensagens de loading"""
        def update_message(dt):
            if hasattr(self, 'ids') and 'loading_text' in self.ids:
                self.ids.loading_text.text = self.loading_messages[self.current_message]
                self.current_message = (self.current_message + 1) % len(self.loading_messages)
        
        Clock.schedule_interval(update_message, 1.5)

class AnimatedCard(MDCard):
    """Card com animações"""
    scale_x = NumericProperty(1)
    scale_y = NumericProperty(1)
    
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.bind(on_touch_down=self.animate_press)
        self.bind(on_touch_up=self.animate_release)
    
    def animate_press(self, instance, touch):
        """Animação ao pressionar"""
        if self.collide_point(*touch.pos):
            anim = Animation(scale_x=0.95, scale_y=0.95, duration=0.1)
            anim.start(self)
    
    def animate_release(self, instance, touch):
        """Animação ao soltar"""
        anim = Animation(scale_x=1, scale_y=1, duration=0.1)
        anim.start(self)

class ContratoPanel(MDListItem):
    """Panel de contrato no expansion"""
    status = StringProperty("pendente")

class ServicosGrid(MDGridLayout):
    """Grid de serviços"""
    servicos = StringProperty("")
    
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.bind(servicos=self.update_servicos)
    
    def update_servicos(self, instance, value):
        """Atualizar lista de serviços"""
        self.clear_widgets()
        if isinstance(value, list):
            for servico in value:
                card = MDCard(
                    style="filled",
                    md_bg_color="#F3E5F5",
                    padding=dp(8),
                    size_hint_y=None,
                    height=dp(40)
                )
                label = MDLabel(
                    text=f"• {servico}",
                    font_style="Body",
                    role="medium",
                    adaptive_height=True
                )
                card.add_widget(label)
                self.add_widget(card)

class ContratoDetails(MDBoxLayout):
    """Detalhes do contrato"""
    numero = StringProperty("")
    cliente = StringProperty("")
    data = StringProperty("")
    valor = StringProperty("")
    servicos = StringProperty("")
    status = StringProperty("pendente")
    
    def download_contrato(self):
        """Download do contrato com loading"""
        app = MDApp.get_running_app()
        
        # Mostrar loading
        loading = LoadingBottomSheet(
            title="Gerando Contrato",
            message="Preparando arquivo PDF..."
        )
        loading.open()
        
        # Simular download
        def complete_download(dt):
            loading.dismiss()
            app.show_success(f"Contrato {self.numero} baixado com sucesso!")
        
        Clock.schedule_once(complete_download, 3)
    
    def send_whatsapp(self):
        """Enviar via WhatsApp"""
        app = MDApp.get_running_app()
        
        # Simular envio
        loading = LoadingBottomSheet(
            title="Enviando WhatsApp",
            message="Preparando mensagem..."
        )
        loading.open()
        
        def complete_send(dt):
            loading.dismiss()
            app.show_success("Mensagem enviada via WhatsApp!")
        
        Clock.schedule_once(complete_send, 2)
    
    def edit_contrato(self):
        """Editar contrato"""
        app = MDApp.get_running_app()
        app.show_info("Função de edição em desenvolvimento")

class LoadingBottomSheet(MDBottomSheet):
    """Bottom sheet de loading"""
    title = StringProperty("Carregando")
    message = StringProperty("Aguarde...")

class TransparenciaScreen(MDScreen):
    """Tela de transparência de contratos"""
    
    def refresh_contratos(self):
        """Atualizar contratos"""
        # Animação de refresh
        app = MDApp.get_running_app()
        
        loading = LoadingBottomSheet(
            title="Atualizando",
            message="Sincronizando contratos..."
        )
        loading.open()
        
        def complete_refresh(dt):
            loading.dismiss()
            app.show_success("Contratos atualizados!")
            # Aqui você pode recarregar os dados
            self.animate_cards()
        
        Clock.schedule_once(complete_refresh, 2)
    
    def animate_cards(self):
        """Animar entrada dos cards"""
        # Animação em cascata dos expansion panels
        panels = [self.ids.contrato_1, self.ids.contrato_2, self.ids.contrato_3]
        
        for i, panel in enumerate(panels):
            def animate_panel(dt, p=panel):
                # Animação de entrada
                p.opacity = 0
                p.y = p.y - 50
                
                anim = Animation(opacity=1, y=p.y + 50, duration=0.5)
                anim.start(p)
            
            Clock.schedule_once(animate_panel, i * 0.2)

class TransparencyApp(MDApp):
    """App com transparência e animações"""
    
    def build(self):
        # Tema
        self.theme_cls.primary_palette = "Purple"
        self.theme_cls.accent_palette = "Orange"
        self.theme_cls.theme_style = "Light"
        self.theme_cls.material_style = "M3"
        
        return Builder.load_string(TRANSPARENCY_KV)
    
    def on_start(self):
        """Inicializar com loading"""
        print("🎉 BagunçArt Transparency iniciado!")
        
        # Mostrar loading por 3 segundos
        Clock.schedule_once(self.complete_loading, 3)
    
    def complete_loading(self, dt):
        """Completar loading e ir para transparência"""
        self.change_screen("transparencia")
    
    def change_screen(self, screen_name):
        """Trocar tela"""
        self.root.current = screen_name
    
    def show_success(self, message):
        """Mostrar sucesso"""
        snackbar = MDSnackbar(
            MDSnackbarText(text=message),
            y=dp(24),
            pos_hint={"center_x": 0.5},
            size_hint_x=0.9,
            md_bg_color="#4CAF50"
        )
        snackbar.open()
    
    def show_info(self, message):
        """Mostrar info"""
        snackbar = MDSnackbar(
            MDSnackbarText(text=message),
            y=dp(24),
            pos_hint={"center_x": 0.5},
            size_hint_x=0.9,
        )
        snackbar.open()

if __name__ == "__main__":
    TransparencyApp().run()