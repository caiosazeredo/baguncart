#!/usr/bin/env python3
# build.py - Script de Build para APK
import os
import sys
import subprocess
import shutil
from pathlib import Path

class BaguncartBuilder:
    def __init__(self):
        self.project_name = "BaguncartApp"
        self.app_version = "1.0.0"
        self.main_file = "main.py"
        self.build_dir = "build"
        self.assets_dir = "assets"
        
    def check_requirements(self):
        """Verificar requisitos para build"""
        print("🔍 Verificando requisitos...")
        
        # Verificar Python
        if sys.version_info < (3, 8):
            print("❌ Python 3.8+ é necessário")
            return False
        
        # Verificar Flet
        try:
            import flet
            print(f"✅ Flet {flet.__version__} encontrado")
        except ImportError:
            print("❌ Flet não encontrado. Execute: pip install flet")
            return False
        
        # Verificar arquivo principal
        if not os.path.exists(self.main_file):
            print(f"❌ Arquivo {self.main_file} não encontrado")
            return False
        
        print("✅ Todos os requisitos atendidos")
        return True
    
    def clean_build(self):
        """Limpar diretório de build"""
        print("🧹 Limpando builds anteriores...")
        
        if os.path.exists(self.build_dir):
            shutil.rmtree(self.build_dir)
        
        # Remover outros arquivos de build
        for pattern in ["*.spec", "dist", "__pycache__"]:
            for item in Path(".").rglob(pattern):
                if item.is_file():
                    item.unlink()
                elif item.is_dir():
                    shutil.rmtree(item)
        
        print("✅ Build limpo")
    
    def prepare_assets(self):
        """Preparar assets"""
        print("📦 Preparando assets...")
        
        # Criar diretório de assets se não existir
        os.makedirs(self.assets_dir, exist_ok=True)
        
        # Criar logo padrão se não existir
        logo_path = os.path.join(self.assets_dir, "logo.png")
        if not os.path.exists(logo_path):
            print("⚠️  Logo não encontrado, usando ícone padrão")
        
        print("✅ Assets preparados")
    
    def build_apk(self):
        """Build APK para Android"""
        print("🏗️  Iniciando build do APK...")
        
        try:
            # Comando de build
            cmd = [
                "flet", "pack", self.main_file,
                "--name", self.project_name,
                "--distpath", self.build_dir,
                "--android",
                "--app-version", self.app_version,
                "--app-description", "BagunçArt - Gestão de Eventos",
                "--copyright", "© 2024 BagunçArt Eventos",
            ]
            
            # Adicionar ícone se existir
            logo_path = os.path.join(self.assets_dir, "logo.png")
            if os.path.exists(logo_path):
                cmd.extend(["--icon", logo_path])
            
            # Executar build
            print(f"Executando: {' '.join(cmd)}")
            result = subprocess.run(cmd, capture_output=True, text=True)
            
            if result.returncode == 0:
                print("✅ APK gerado com sucesso!")
                
                # Encontrar APK gerado
                apk_files = list(Path(self.build_dir).rglob("*.apk"))
                if apk_files:
                    apk_path = apk_files[0]
                    size_mb = apk_path.stat().st_size / (1024 * 1024)
                    print(f"📱 APK: {apk_path}")
                    print(f"📏 Tamanho: {size_mb:.1f} MB")
                    
                    # Copiar para pasta principal com nome amigável
                    final_name = f"{self.project_name}-v{self.app_version}.apk"
                    shutil.copy2(apk_path, final_name)
                    print(f"📋 APK copiado para: {final_name}")
                
                return True
            else:
                print("❌ Erro no build:")
                print(result.stderr)
                return False
                
        except Exception as e:
            print(f"❌ Erro no build: {e}")
            return False
    
    def build_web(self):
        """Build para Web"""
        print("🌐 Iniciando build Web...")
        
        try:
            cmd = [
                "flet", "pack", self.main_file,
                "--name", self.project_name,
                "--distpath", self.build_dir,
                "--web",
            ]
            
            result = subprocess.run(cmd, capture_output=True, text=True)
            
            if result.returncode == 0:
                print("✅ Build Web concluído!")
                web_dir = os.path.join(self.build_dir, "web")
                if os.path.exists(web_dir):
                    print(f"🌐 Arquivos Web em: {web_dir}")
                return True
            else:
                print("❌ Erro no build Web:")
                print(result.stderr)
                return False
                
        except Exception as e:
            print(f"❌ Erro no build Web: {e}")
            return False
    
    def build_desktop(self):
        """Build para Desktop"""
        print("🖥️  Iniciando build Desktop...")
        
        try:
            cmd = [
                "flet", "pack", self.main_file,
                "--name", self.project_name,
                "--distpath", self.build_dir,
            ]
            
            # Adicionar ícone se existir
            logo_path = os.path.join(self.assets_dir, "logo.png")
            if os.path.exists(logo_path):
                cmd.extend(["--icon", logo_path])
            
            result = subprocess.run(cmd, capture_output=True, text=True)
            
            if result.returncode == 0:
                print("✅ Build Desktop concluído!")
                return True
            else:
                print("❌ Erro no build Desktop:")
                print(result.stderr)
                return False
                
        except Exception as e:
            print(f"❌ Erro no build Desktop: {e}")
            return False
    
    def run_all_builds(self):
        """Executar todos os builds"""
        print("🚀 Iniciando build completo do BagunçArt...\n")
        
        if not self.check_requirements():
            sys.exit(1)
        
        self.clean_build()
        self.prepare_assets()
        
        # APK (prioridade)
        print("\n" + "="*50)
        success_apk = self.build_apk()
        
        # Web
        print("\n" + "="*50)
        success_web = self.build_web()
        
        # Desktop
        print("\n" + "="*50)
        success_desktop = self.build_desktop()
        
        # Resumo
        print("\n" + "="*50)
        print("📊 RESUMO DO BUILD:")
        print(f"APK Android: {'✅' if success_apk else '❌'}")
        print(f"Web App: {'✅' if success_web else '❌'}")
        print(f"Desktop: {'✅' if success_desktop else '❌'}")
        
        if any([success_apk, success_web, success_desktop]):
            print("\n🎉 Build concluído! Arquivos em:")
            print(f"   📁 {os.path.abspath(self.build_dir)}")
        else:
            print("\n❌ Todos os builds falharam")
            sys.exit(1)

def main():
    """Função principal"""
    builder = BaguncartBuilder()
    
    if len(sys.argv) > 1:
        command = sys.argv[1].lower()
        
        if command == "apk":
            if builder.check_requirements():
                builder.clean_build()
                builder.prepare_assets()
                builder.build_apk()
        elif command == "web":
            if builder.check_requirements():
                builder.clean_build()
                builder.prepare_assets()
                builder.build_web()
        elif command == "desktop":
            if builder.check_requirements():
                builder.clean_build()
                builder.prepare_assets()
                builder.build_desktop()
        elif command == "clean":
            builder.clean_build()
        else:
            print("Uso: python build.py [apk|web|desktop|clean]")
            print("Sem argumentos: build completo")
    else:
        # Build completo
        builder.run_all_builds()

if __name__ == "__main__":
    main()