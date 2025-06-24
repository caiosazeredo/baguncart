[app]
title = BagunçArt - Gestão de Eventos
package.name = baguncart
package.domain = com.baguncart.eventos

source.dir = .
source.include_exts = py,png,jpg,kv,atlas,txt

version = 1.0.0
version.regex = __version__ = ['"]([^'"]*?)['"]
version.filename = %(source.dir)s/main.py

requirements = python3,kivy==2.1.0,kivymd==1.1.1,mysql-connector-python,bcrypt,python-dotenv,requests,pyjnius

# Metadados do app
author = BagunçArt Eventos
description = Sistema completo de gestão de eventos para empresas

[buildozer]
log_level = 2
warn_on_root = 1

[android]
fullscreen = 0
orientation = portrait

# Ícones (substitua por ícones reais)
icon.filename = %(source.dir)s/icon.png
presplash.filename = %(source.dir)s/presplash.png

# Permissões necessárias
android.permissions = INTERNET,ACCESS_NETWORK_STATE,WRITE_EXTERNAL_STORAGE,READ_EXTERNAL_STORAGE,ACCESS_WIFI_STATE

# Versões do Android
android.api = 30
android.minapi = 21
android.ndk = 25b
android.sdk = 30

# Configurações de build
android.release_artifact = apk
android.debug_artifact = apk

# Configurações de assinatura (para release)
# android.debug_keystore = ~/.android/debug.keystore
# android.release_keystore = %(source.dir)s/release.keystore
# android.release_keyalias = baguncart
# android.release_keystore_passwd = suasenha
# android.release_keyalias_passwd = suasenha

[ios]
ios.kivy_ios_url = https://github.com/kivy/kivy-ios
ios.kivy_ios_branch = master
