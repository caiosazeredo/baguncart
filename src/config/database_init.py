# src/config/database_init.py
from datetime import datetime

def init_database(db):
    """Inicializar banco de dados com todas as tabelas"""
    try:
        cursor = db.connection.cursor()
        
        # Tabela de usuários
        create_usuarios = """
        CREATE TABLE IF NOT EXISTS usuarios (
            id INT AUTO_INCREMENT PRIMARY KEY,
            cnpj VARCHAR(14) UNIQUE NOT NULL,
            senha VARCHAR(255) NOT NULL,
            nome VARCHAR(100) NOT NULL,
            email VARCHAR(100),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
        """
        
        # Tabela de clientes
        create_clientes = """
        CREATE TABLE IF NOT EXISTS clientes (
            id INT AUTO_INCREMENT PRIMARY KEY,
            nome VARCHAR(100) NOT NULL,
            cpf VARCHAR(11) UNIQUE NOT NULL,
            endereco TEXT,
            telefone VARCHAR(15),
            email VARCHAR(100),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
        """
        
        # Tabela de serviços
        create_servicos = """
        CREATE TABLE IF NOT EXISTS servicos (
            id INT AUTO_INCREMENT PRIMARY KEY,
            nome VARCHAR(100) NOT NULL,
            preco DECIMAL(10,2) NOT NULL,
            descricao TEXT,
            ativo BOOLEAN DEFAULT TRUE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
        """
        
        # Tabela de contratos
        create_contratos = """
        CREATE TABLE IF NOT EXISTS contratos (
            id INT AUTO_INCREMENT PRIMARY KEY,
            numero_contrato VARCHAR(20) UNIQUE NOT NULL,
            cliente_id INT NOT NULL,
            data_evento DATE NOT NULL,
            local_evento TEXT,
            forma_pagamento VARCHAR(50),
            valor_total DECIMAL(10,2) NOT NULL,
            valor_desconto DECIMAL(10,2) DEFAULT 0,
            status VARCHAR(20) DEFAULT 'ativo',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (cliente_id) REFERENCES clientes(id)
        )
        """
        
        # Tabela de itens do contrato
        create_contrato_servicos = """
        CREATE TABLE IF NOT EXISTS contrato_servicos (
            id INT AUTO_INCREMENT PRIMARY KEY,
            contrato_id INT NOT NULL,
            servico_id INT NOT NULL,
            quantidade INT DEFAULT 1,
            preco_unitario DECIMAL(10,2) NOT NULL,
            FOREIGN KEY (contrato_id) REFERENCES contratos(id),
            FOREIGN KEY (servico_id) REFERENCES servicos(id)
        )
        """
        
        # Tabela de promoções
        create_promocoes = """
        CREATE TABLE IF NOT EXISTS promocoes (
            id INT AUTO_INCREMENT PRIMARY KEY,
            cliente_id INT NOT NULL,
            contrato_id INT,
            servico_ids JSON,
            valor_promocional DECIMAL(10,2) NOT NULL,
            validade_promocao DATE NOT NULL,
            descricao TEXT,
            ativo BOOLEAN DEFAULT TRUE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (cliente_id) REFERENCES clientes(id)
        )
        """
        
        # Tabela de notificações
        create_notificacoes = """
        CREATE TABLE IF NOT EXISTS notificacoes (
            id INT AUTO_INCREMENT PRIMARY KEY,
            cliente_id INT NOT NULL,
            contrato_id INT,
            servico_ids JSON,
            mensagem TEXT NOT NULL,
            enviado BOOLEAN DEFAULT FALSE,
            data_envio TIMESTAMP NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (cliente_id) REFERENCES clientes(id)
        )
        """
        
        # Executar criação das tabelas
        cursor.execute(create_usuarios)
        cursor.execute(create_clientes)
        cursor.execute(create_servicos)
        cursor.execute(create_contratos)
        cursor.execute(create_contrato_servicos)
        cursor.execute(create_promocoes)
        cursor.execute(create_notificacoes)
        cursor.close()
        
        print("✅ Tabelas criadas/verificadas com sucesso")
        
        # Inserir serviços padrão
        init_default_services(db)
        
        return True
        
    except Exception as e:
        print(f"❌ Erro ao criar tabelas: {e}")
        return False

def init_default_services(db):
    """Inserir serviços padrão"""
    try:
        # Verificar se já existem serviços
        result = db.execute_query("SELECT COUNT(*) as total FROM servicos")
        
        if result and result[0]['total'] == 0:
            # Inserir serviços padrão
            servicos_padrao = [
                ("Pula pula", 20.00, "Pula pula para festas infantis"),
                ("Garçom", 20.00, "Serviço de garçom para eventos"),
                ("Barman", 20.00, "Serviço de barman profissional"),
                ("Palhaço", 20.00, "Animação com palhaço"),
                ("Recepção", 20.00, "Serviço de recepção de convidados"),
                ("DJ", 50.00, "Serviço de DJ com equipamentos"),
                ("Decoração", 100.00, "Decoração completa do ambiente"),
            ]
            
            for nome, preco, descricao in servicos_padrao:
                query = """
                INSERT INTO servicos (nome, preco, descricao, ativo, created_at)
                VALUES (%s, %s, %s, %s, %s)
                """
                db.execute_insert(query, (nome, preco, descricao, True, datetime.now()))
            
            print("✅ Serviços padrão inseridos")
            
    except Exception as e:
        print(f"⚠️ Erro ao inserir serviços padrão: {e}")