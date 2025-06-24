# src/services/cliente_service.py
from datetime import datetime
import re

class ClienteService:
    def __init__(self, database):
        self.db = database
        self.init_tables()

    def init_tables(self):
        """Criar tabelas se não existirem"""
        try:
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
                FOREIGN KEY (cliente_id) REFERENCES clientes(id),
                FOREIGN KEY (contrato_id) REFERENCES contratos(id)
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
                FOREIGN KEY (cliente_id) REFERENCES clientes(id),
                FOREIGN KEY (contrato_id) REFERENCES contratos(id)
            )
            """
            
            # Executar criação das tabelas
            cursor = self.db.connection.cursor()
            cursor.execute(create_usuarios)
            cursor.execute(create_clientes)
            cursor.execute(create_servicos)
            cursor.execute(create_contratos)
            cursor.execute(create_contrato_servicos)
            cursor.execute(create_promocoes)
            cursor.execute(create_notificacoes)
            cursor.close()
            
            # Inserir serviços padrão
            self.init_default_services()
            
            print("✅ Tabelas criadas/verificadas com sucesso")
            
        except Exception as e:
            print(f"Erro ao criar tabelas: {e}")

    def init_default_services(self):
        """Inserir serviços padrão"""
        try:
            # Verificar se já existem serviços
            result = self.db.execute_query("SELECT COUNT(*) as total FROM servicos")
            
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
                    self.db.execute_insert(query, (nome, preco, descricao, True, datetime.now()))
                
                print("✅ Serviços padrão inseridos")
                
        except Exception as e:
            print(f"Erro ao inserir serviços padrão: {e}")

    def validate_cpf(self, cpf):
        """Validar CPF"""
        # Remover formatação
        cpf = re.sub(r'\D', '', cpf)
        
        if len(cpf) != 11:
            return False
        
        # Verificar se todos os dígitos são iguais
        if cpf == cpf[0] * 11:
            return False
        
        # Cálculo do primeiro dígito verificador
        soma = sum(int(cpf[i]) * (10 - i) for i in range(9))
        resto = 11 - (soma % 11)
        if resto >= 10:
            resto = 0
        if resto != int(cpf[9]):
            return False
        
        # Cálculo do segundo dígito verificador
        soma = sum(int(cpf[i]) * (11 - i) for i in range(10))
        resto = 11 - (soma % 11)
        if resto >= 10:
            resto = 0
        if resto != int(cpf[10]):
            return False
        
        return True

    def get_all(self, search=""):
        """Obter todos os clientes"""
        try:
            if search:
                query = """
                SELECT * FROM clientes 
                WHERE nome LIKE %s OR telefone LIKE %s OR email LIKE %s
                ORDER BY nome
                """
                search_term = f"%{search}%"
                result = self.db.execute_query(query, (search_term, search_term, search_term))
            else:
                query = "SELECT * FROM clientes ORDER BY nome"
                result = self.db.execute_query(query)
            
            return result if result else []
            
        except Exception as e:
            print(f"Erro ao obter clientes: {e}")
            return []

    def get_by_id(self, cliente_id):
        """Obter cliente por ID"""
        try:
            query = "SELECT * FROM clientes WHERE id = %s"
            result = self.db.execute_query(query, (cliente_id,))
            return result[0] if result else None
            
        except Exception as e:
            print(f"Erro ao obter cliente: {e}")
            return None

    def create(self, nome, cpf, endereco="", telefone="", email=""):
        """Criar novo cliente"""
        try:
            # Validar CPF
            cpf_limpo = re.sub(r'\D', '', cpf)
            if not self.validate_cpf(cpf_limpo):
                return {"error": "CPF inválido"}
            
            # Verificar se CPF já existe
            existing = self.db.execute_query("SELECT id FROM clientes WHERE cpf = %s", (cpf_limpo,))
            if existing:
                return {"error": "CPF já cadastrado"}
            
            # Inserir cliente
            query = """
            INSERT INTO clientes (nome, cpf, endereco, telefone, email, created_at)
            VALUES (%s, %s, %s, %s, %s, %s)
            """
            
            cliente_id = self.db.execute_insert(
                query, 
                (nome, cpf_limpo, endereco, telefone, email, datetime.now())
            )
            
            if cliente_id:
                return {"success": True, "cliente_id": cliente_id}
            else:
                return {"error": "Erro ao criar cliente"}
                
        except Exception as e:
            print(f"Erro ao criar cliente: {e}")
            return {"error": str(e)}

    def update(self, cliente_id, nome, cpf, endereco="", telefone="", email=""):
        """Atualizar cliente"""
        try:
            # Validar CPF
            cpf_limpo = re.sub(r'\D', '', cpf)
            if not self.validate_cpf(cpf_limpo):
                return {"error": "CPF inválido"}
            
            # Verificar se CPF já existe em outro cliente
            existing = self.db.execute_query(
                "SELECT id FROM clientes WHERE cpf = %s AND id != %s", 
                (cpf_limpo, cliente_id)
            )
            if existing:
                return {"error": "CPF já cadastrado para outro cliente"}
            
            # Atualizar cliente
            query = """
            UPDATE clientes 
            SET nome = %s, cpf = %s, endereco = %s, telefone = %s, email = %s
            WHERE id = %s
            """
            
            self.db.execute_query(query, (nome, cpf_limpo, endereco, telefone, email, cliente_id))
            return {"success": True}
                
        except Exception as e:
            print(f"Erro ao atualizar cliente: {e}")
            return {"error": str(e)}

    def delete(self, cliente_id):
        """Deletar cliente"""
        try:
            # Verificar se cliente tem contratos
            contratos = self.db.execute_query(
                "SELECT COUNT(*) as total FROM contratos WHERE cliente_id = %s", 
                (cliente_id,)
            )
            
            if contratos and contratos[0]['total'] > 0:
                return {"error": "Cliente possui contratos e não pode ser excluído"}
            
            # Deletar cliente
            query = "DELETE FROM clientes WHERE id = %s"
            self.db.execute_query(query, (cliente_id,))
            return {"success": True}
                
        except Exception as e:
            print(f"Erro ao deletar cliente: {e}")
            return {"error": str(e)}