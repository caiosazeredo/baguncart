# BagunçArt - Sistema de Gestão de Eventos

![BagunçArt](assets/icon-192.png)

## 🎉 Sobre o Projeto

O **BagunçArt** é um sistema moderno e completo para gestão de eventos, desenvolvido com **KivyMD** (Material Design 3) e **Python**. 

### ✨ Principais Recursos

- 🎨 **Interface Moderna**: Material Design 3 com animações fluidas
- 📱 **Responsivo**: Funciona perfeitamente em mobile, tablet e desktop  
- 🔍 **Transparência Total**: Clientes acompanham contratos em tempo real
- 🤖 **Automação Inteligente**: Notificações e lembretes automáticos
- 🔒 **Segurança**: Autenticação robusta com bcrypt
- 🌐 **Cloud Ready**: Conecta com MySQL na nuvem (Aiven)

### 📋 Funcionalidades

#### 👥 Gestão de Clientes
- Cadastro completo com validação de CPF
- Pesquisa avançada e filtros
- Histórico de contratos
- Comunicação direta (WhatsApp)

#### 📋 Contratos Inteligentes  
- Criação assistida de contratos
- Cálculo automático de valores
- Gestão de serviços
- Download de PDF

#### 🔍 Transparência
- Portal do cliente
- Acompanhamento em tempo real
- Confirmações automáticas
- Histórico completo

#### 📊 Relatórios e Analytics
- Dashboard em tempo real
- Gráficos interativos
- Exportação para PDF
- Métricas de desempenho

#### 🔔 Notificações
- Lembretes automáticos
- Confirmações de serviço
- Alertas personalizados
- Integração WhatsApp

### 🚀 Instalação e Uso

#### Pré-requisitos
- Python 3.7+
- pip
- Git

#### Instalação Rápida

```bash
# Clonar repositório
git clone https://github.com/seu-usuario/baguncart.git
cd baguncart

# Instalar dependências
pip install -r requirements.txt

# Configurar ambiente
cp .env.example .env
# Edite o .env com suas configurações

# Executar aplicação
python main.py
```

#### 📱 Gerar APK

```bash
# Instalar buildozer
pip install buildozer

# Gerar APK debug
python build_system.py --apk-debug

# Gerar APK release (Play Store)
python build_system.py --apk-release
```

### 🔐 Login Padrão

- **CNPJ**: `12345678000100`
- **Senha**: `admin123`

### 🏗️ Arquitetura

```
baguncart/
├── main.py              # Aplicação principal
├── src/                 # Código fonte
│   ├── models/          # Modelos de dados
│   ├── views/           # Telas da aplicação
│   ├── services/        # Lógica de negócio
│   └── utils/           # Utilitários
├── assets/              # Recursos (ícones, imagens)
├── tests/               # Testes automatizados
├── docs/                # Documentação
├── build/               # Arquivos de build
└── dist/                # Distribuição (APKs)
```

### 🤝 Contribuição

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

### 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para detalhes.

### 🛠️ Tecnologias Utilizadas

- **Python 3.8+**
- **Kivy 2.2.0** - Framework multiplataforma
- **KivyMD 1.2.0** - Material Design para Kivy
- **MySQL** - Banco de dados
- **bcrypt** - Criptografia de senhas
- **Buildozer** - Build para Android

### 📱 Screenshots

![Dashboard](docs/screenshots/dashboard.png)
![Clientes](docs/screenshots/clientes.png)
![Transparência](docs/screenshots/transparencia.png)

### 🔗 Links Úteis

- [Documentação KivyMD](https://kivymd.readthedocs.io/)
- [Material Design 3](https://m3.material.io/)
- [Python.org](https://python.org/)

### 📞 Suporte

Para suporte e dúvidas:
- 📧 Email: suporte@baguncart.com
- 💬 WhatsApp: (21) 99999-9999
- 🌐 Site: https://baguncart.com

---

**Desenvolvido com ❤️ para transformar a gestão de eventos**

*BagunçArt - Versão 2.0.0 - 2025-06-24 16:52:04*
