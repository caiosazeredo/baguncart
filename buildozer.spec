[app]
title = BagunçArt - Gestão de Eventos
package.name = baguncart
package.domain = com.baguncart.eventos

source.dir = .
source.include_exts = py,png,jpg,kv,atlas,txt,json

version = 2.0.0
version.regex = __version__ = ['"]([^'"]*?)['"]
version.filename = %(source.dir)s/main.py

# KivyMD Requirements optimized for APK
requirements = python3,kivy==2.2.0,kivymd==1.2.0,mysql-connector-python,bcrypt,python-dotenv,requests,pillow,pyjnius,android

# Metadados
author = BagunçArt Eventos
description = Sistema profissional de gestão de eventos com Material Design 3, transparência total e automação inteligente

[buildozer]
log_level = 2
warn_on_root = 1

[android]
fullscreen = 0
orientation = portrait
android.permissions = INTERNET,ACCESS_NETWORK_STATE,WRITE_EXTERNAL_STORAGE,READ_EXTERNAL_STORAGE,ACCESS_WIFI_STATE,CAMERA,RECORD_AUDIO

# Icons and splash
icon.filename = %(source.dir)s/assets/icon.png
presplash.filename = %(source.dir)s/assets/presplash.png

# Android versions
android.api = 33
android.minapi = 21
android.ndk = 25b
android.sdk = 33

# Build settings
android.gradle_dependencies = 
android.add_src = 
android.add_java_dir = 
android.add_res_dir = 
android.add_assets_dir = 

# Architectures
android.archs = arm64-v8a, armeabi-v7a

# Release settings
android.release_artifact = apk
android.debug_artifact = apk

# Signing (uncomment for release)
# android.release_keystore = %(source.dir)s/release.keystore
# android.release_keyalias = baguncart
# android.release_keystore_passwd = your_keystore_password
# android.release_keyalias_passwd = your_alias_password

[ios]
ios.kivy_ios_url = https://github.com/kivy/kivy-ios
ios.kivy_ios_branch = master
ios.ios_deploy_url = https://github.com/phonegap/ios-deploy
ios.ios_deploy_branch = 1.7.0
