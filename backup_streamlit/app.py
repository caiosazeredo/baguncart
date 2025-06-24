#!/usr/bin/env python3
# app.py - BagunçArt Sistema de Gestão de Eventos em Streamlit

import streamlit as st
import pandas as pd
import mysql.connector
from datetime import datetime, date
import bcrypt
import re
import os
from dotenv import load_dotenv

# Carregar variáveis de ambiente
load_dotenv()

# Configuração da página
st.set_page_config(
    page_title="BagunçArt - Gestão de Eventos",
    page_icon="🎉",
    layout="wide",
    initial_sidebar_state="expanded"
)

# CSS personalizado
st.markdown("""
<style>
    .main-header {
        background: linear-gradient(90deg, #8B2F8B, #FF8C00);
        color: white;
        padding: 1rem;
        border-radius: 0.5rem;
        text-align: center;
        margin-bottom: 2rem;
    }
    .metric-card {
        background: white;
        padding: 1rem;
        border-radius: 0.5rem;
        border-left: 4px solid #8B2F8B;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
    .success-message {
        background: #d4edda;
        border: 1px solid #c3e6cb;
        color: #155724;
        padding: 0.75rem;
        border-radius: 0.25rem;
        margin: 1rem 0;
    }
    .error-message {
        background: #f8d7da;
        border: 1px solid #f5c6cb;
        color: #721c24;
        padding: 0.75rem;
        border-radius: 0.25rem;
        margin: 1rem 0;
    }
</style>
""", unsafe_allow_html=True)

class Database:
    def __init__(self):
        self.host = os.getenv('DB_HOST', 'localhost')
        self.port = int(os.getenv('DB_PORT', 3306))
        self.database = os.getenv('DB_NAME', 'baguncart_db')
        self.user = os.getenv('DB_USER', 'root')
        self.password = os.getenv('DB_PASSWORD', '')
        self.connection = None

    def connect(self):
        try:
            self.connection = mysql.connector.connect(
                host=self.host,
                port=self.port,
                database=self.database,
                user=self.user,
                password=self.password,
                autocommit=True
            )
            return True
        except Exception as e:
            st.error(f"Erro ao conectar ao banco: {e}")
            return False

    def execute_query(self, query, params=None):
        try:
            cursor = self.connection.cursor(dictionary=True)
            cursor.execute(query, params)
            result = cursor.fetchall()
            cursor.close()
            return result
        except Exception as e:
            st.error(f"Erro ao executar query: {e}")
            return None

    def execute_insert(self, query, params=None):
        try:
            cursor = self.connection.cursor()
            cursor.execute(query, params)
            insert_id = cursor.lastrowid
            cursor.close()
            return insert_id
        except Exception as e:
            st.error(f"Erro ao inserir dados: {e}")
            return None

def init_database():
    """Inicializar banco de dados"""
    db = Database()
    if not db.connect():
        return None
    
    try:
        cursor = db.connection.cursor()
        
        # Criar tabelas
        tables = [
            """CREATE TABLE IF NOT EXISTS usuarios (
                id INT AUTO_INCREMENT PRIMARY KEY,
                cnpj VARCHAR(14) UNIQUE NOT NULL,
                senha VARCHAR(255) NOT NULL,
                nome VARCHAR(100) NOT NULL,
                email VARCHAR(100),
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )""",
            """CREATE TABLE IF NOT EXISTS clientes (
                id INT AUTO_INCREMENT PRIMARY KEY,
                nome VARCHAR(100) NOT NULL,
                cpf VARCHAR(11) UNIQUE NOT NULL,
                endereco TEXT,
                telefone VARCHAR(15),
                email VARCHAR(100),
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )""",
            """CREATE TABLE IF NOT EXISTS servicos (
                id INT AUTO_INCREMENT PRIMARY KEY,
                nome VARCHAR(100) NOT NULL,
                preco DECIMAL(10,2) NOT NULL,
                descricao TEXT,
                ativo BOOLEAN DEFAULT TRUE,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )""",
            """CREATE TABLE IF NOT EXISTS contratos (
                id INT AUTO_INCREMENT PRIMARY KEY,
                numero_contrato VARCHAR(20) UNIQUE NOT NULL,
                cliente_id INT NOT NULL,
                data_evento DATE NOT NULL,
                local_evento TEXT,
                forma_pagamento VARCHAR(50),
                valor_total DECIMAL(10,2) NOT NULL,
                status VARCHAR(20) DEFAULT 'ativo',
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (cliente_id) REFERENCES clientes(id)
            )"""
        ]
        
        for table in tables:
            cursor.execute(table)
        
        cursor.close()
        
        # Inserir dados iniciais
        init_default_data(db)
        
        return db
        
    except Exception as e:
        st.error(f"Erro ao inicializar banco: {e}")
        return None

def init_default_data(db):
    """Inserir dados padrão"""
    try:
        # Usuário admin
        result = db.execute_query("SELECT * FROM usuarios WHERE cnpj = %s", ("12345678000100",))
        if not result:
            senha_hash = bcrypt.hashpw("admin123".encode('utf-8'), bcrypt.gensalt())
            db.execute_insert(
                "INSERT INTO usuarios (cnpj, senha, nome, email, created_at) VALUES (%s, %s, %s, %s, %s)",
                ("12345678000100", senha_hash, "Administrador", "admin@baguncart.com", datetime.now())
            )
        
        # Serviços padrão
        result = db.execute_query("SELECT COUNT(*) as total FROM servicos")
        if result and result[0]['total'] == 0:
            servicos = [
                ("Pula pula", 20.00, "Pula pula para festas infantis"),
                ("Garçom", 20.00, "Serviço de garçom para eventos"),
                ("Barman", 20.00, "Serviço de barman profissional"),
                ("Palhaço", 20.00, "Animação com palhaço"),
                ("Recepção", 20.00, "Serviço de recepção de convidados"),
                ("DJ", 50.00, "Serviço de DJ com equipamentos"),
                ("Decoração", 100.00, "Decoração completa do ambiente"),
            ]
            
            for nome, preco, descricao in servicos:
                db.execute_insert(
                    "INSERT INTO servicos (nome, preco, descricao, ativo, created_at) VALUES (%s, %s, %s, %s, %s)",
                    (nome, preco, descricao, True, datetime.now())
                )
    except Exception as e:
        st.error(f"Erro ao inserir dados padrão: {e}")

def authenticate(cnpj, senha):
    """Autenticar usuário"""
    db = st.session_state.get('db')
    if not db:
        return None
    
    try:
        result = db.execute_query("SELECT * FROM usuarios WHERE cnpj = %s", (cnpj,))
        if result:
            user = result[0]
            stored_password = user['senha']
            if isinstance(stored_password, str):
                stored_password = stored_password.encode('utf-8')
            
            if bcrypt.checkpw(senha.encode('utf-8'), stored_password):
                return {
                    'id': user['id'],
                    'cnpj': user['cnpj'],
                    'nome': user['nome'],
                    'email': user['email']
                }
        return None
    except Exception as e:
        st.error(f"Erro na autenticação: {e}")
        return None

def format_cpf(cpf):
    """Formatar CPF"""
    numbers = re.sub(r'\D', '', cpf)
    if len(numbers) == 11:
        return f"{numbers[:3]}.{numbers[3:6]}.{numbers[6:9]}-{numbers[9:]}"
    return cpf

def format_cnpj(cnpj):
    """Formatar CNPJ"""
    numbers = re.sub(r'\D', '', cnpj)
    if len(numbers) == 14:
        return f"{numbers[:2]}.{numbers[2:5]}.{numbers[5:8]}/{numbers[8:12]}-{numbers[12:]}"
    return cnpj

def validate_cpf(cpf):
    """Validar CPF"""
    numbers = re.sub(r'\D', '', cpf)
    if len(numbers) != 11 or numbers == numbers[0] * 11:
        return False
    
    # Cálculo dos dígitos verificadores
    def calculate_digit(digits):
        sum_val = sum(int(digit) * weight for digit, weight in zip(digits, range(len(digits) + 1, 1, -1)))
        remainder = sum_val % 11
        return 0 if remainder < 2 else 11 - remainder
    
    return (calculate_digit(numbers[:9]) == int(numbers[9]) and
            calculate_digit(numbers[:10]) == int(numbers[10]))

def show_login():
    """Tela de login"""
    st.markdown("""
    <div class="main-header">
        <h1>🎉 BagunçArt - Gestão de Eventos</h1>
        <p>Sistema completo para gerenciar seus eventos</p>
    </div>
    """, unsafe_allow_html=True)
    
    col1, col2, col3 = st.columns([1, 2, 1])
    
    with col2:
        st.subheader("🔐 Login")
        
        with st.form("login_form"):
            cnpj = st.text_input("CNPJ", placeholder="00.000.000/0000-00", max_chars=18)
            senha = st.text_input("Senha", type="password", placeholder="Digite sua senha")
            submit = st.form_submit_button("🚀 ENTRAR", use_container_width=True)
            
            if submit:
                if not cnpj or not senha:
                    st.error("❌ Preencha todos os campos!")
                else:
                    # Remover formatação do CNPJ
                    cnpj_clean = re.sub(r'\D', '', cnpj)
                    user = authenticate(cnpj_clean, senha)
                    
                    if user:
                        st.session_state['user'] = user
                        st.success(f"✅ Bem-vindo, {user['nome']}!")
                        st.rerun()
                    else:
                        st.error("❌ CNPJ ou senha incorretos!")
        
        st.info("💡 **Login padrão:**\n\nCNPJ: `12345678000100`\nSenha: `admin123`")

def show_dashboard():
    """Dashboard principal"""
    st.markdown("""
    <div class="main-header">
        <h1>📊 Dashboard - BagunçArt</h1>
        <p>Visão geral do seu negócio</p>
    </div>
    """, unsafe_allow_html=True)
    
    # Métricas
    db = st.session_state.get('db')
    if db:
        # Total de clientes
        result = db.execute_query("SELECT COUNT(*) as total FROM clientes")
        total_clientes = result[0]['total'] if result else 0
        
        # Total de contratos
        result = db.execute_query("SELECT COUNT(*) as total FROM contratos WHERE status = 'ativo'")
        total_contratos = result[0]['total'] if result else 0
        
        # Valor total
        result = db.execute_query("SELECT SUM(valor_total) as total FROM contratos WHERE status = 'ativo'")
        valor_total = result[0]['total'] if result and result[0]['total'] else 0
        
        # Próximo evento
        result = db.execute_query("""
            SELECT MIN(data_evento) as proximo_evento 
            FROM contratos 
            WHERE data_evento >= CURDATE() AND status = 'ativo'
        """)
        proximo_evento = result[0]['proximo_evento'] if result and result[0]['proximo_evento'] else None
        
        # Calcular dias até próximo evento
        if proximo_evento:
            if isinstance(proximo_evento, str):
                proximo_evento = datetime.strptime(proximo_evento, '%Y-%m-%d').date()
            dias_restantes = (proximo_evento - date.today()).days
        else:
            dias_restantes = 0
    
    # Exibir métricas
    col1, col2, col3, col4 = st.columns(4)
    
    with col1:
        st.metric(
            label="👥 Clientes",
            value=total_clientes,
            delta=f"Total cadastrados"
        )
    
    with col2:
        st.metric(
            label="📋 Contratos Ativos",
            value=total_contratos,
            delta="Em andamento"
        )
    
    with col3:
        st.metric(
            label="💰 Receita Total",
            value=f"R$ {valor_total:,.2f}",
            delta="Contratos ativos"
        )
    
    with col4:
        st.metric(
            label="📅 Próximo Evento",
            value=f"{dias_restantes} dias",
            delta="Para o próximo"
        )
    
    st.markdown("---")
    
    # Ações rápidas
    st.subheader("🚀 Ações Rápidas")
    
    col1, col2, col3, col4 = st.columns(4)
    
    with col1:
        if st.button("👤 Novo Cliente", use_container_width=True):
            st.session_state['page'] = 'cadastro_cliente'
            st.rerun()
    
    with col2:
        if st.button("📋 Ver Contratos", use_container_width=True):
            st.session_state['page'] = 'contratos'
            st.rerun()
    
    with col3:
        if st.button("👥 Ver Clientes", use_container_width=True):
            st.session_state['page'] = 'clientes'
            st.rerun()
    
    with col4:
        if st.button("🎯 Criar Promoção", use_container_width=True):
            st.session_state['page'] = 'promocao'
            st.rerun()

def show_clientes():
    """Lista de clientes"""
    st.markdown("""
    <div class="main-header">
        <h1>👥 Gestão de Clientes</h1>
        <p>Visualize e gerencie seus clientes</p>
    </div>
    """, unsafe_allow_html=True)
    
    db = st.session_state.get('db')
    if not db:
        st.error("Erro de conexão com banco de dados")
        return
    
    # Barra de pesquisa
    col1, col2 = st.columns([3, 1])
    with col1:
        search = st.text_input("🔍 Pesquisar clientes", placeholder="Nome, CPF ou telefone...")
    with col2:
        if st.button("➕ Novo Cliente", use_container_width=True):
            st.session_state['page'] = 'cadastro_cliente'
            st.rerun()
    
    # Buscar clientes
    if search:
        query = """
        SELECT * FROM clientes 
        WHERE nome LIKE %s OR cpf LIKE %s OR telefone LIKE %s OR email LIKE %s
        ORDER BY nome
        """
        search_term = f"%{search}%"
        clientes = db.execute_query(query, (search_term, search_term, search_term, search_term))
    else:
        clientes = db.execute_query("SELECT * FROM clientes ORDER BY nome")
    
    if not clientes:
        st.info("📝 Nenhum cliente encontrado. Cadastre o primeiro cliente!")
        if st.button("🚀 Cadastrar Primeiro Cliente"):
            st.session_state['page'] = 'cadastro_cliente'
            st.rerun()
    else:
        # Converter para DataFrame
        df = pd.DataFrame(clientes)
        df['cpf'] = df['cpf'].apply(format_cpf)
        df['created_at'] = pd.to_datetime(df['created_at']).dt.strftime('%d/%m/%Y')
        
        # Exibir tabela
        st.dataframe(
            df[['nome', 'cpf', 'telefone', 'email', 'created_at']],
            column_config={
                'nome': 'Nome',
                'cpf': 'CPF',
                'telefone': 'Telefone',
                'email': 'Email',
                'created_at': 'Cadastrado em'
            },
            use_container_width=True,
            hide_index=True
        )
        
        st.info(f"📊 Total: {len(clientes)} clientes cadastrados")

def show_cadastro_cliente():
    """Cadastro de cliente"""
    st.markdown("""
    <div class="main-header">
        <h1>👤 Cadastro de Cliente</h1>
        <p>Adicione um novo cliente ao sistema</p>
    </div>
    """, unsafe_allow_html=True)
    
    db = st.session_state.get('db')
    if not db:
        st.error("Erro de conexão com banco de dados")
        return
    
    with st.form("cadastro_cliente"):
        col1, col2 = st.columns(2)
        
        with col1:
            nome = st.text_input("Nome Completo *", placeholder="Digite o nome completo")
            cpf = st.text_input("CPF *", placeholder="000.000.000-00", max_chars=14)
            telefone = st.text_input("Telefone *", placeholder="(11) 99999-9999")
        
        with col2:
            email = st.text_input("Email", placeholder="cliente@email.com")
            endereco = st.text_area("Endereço", placeholder="Rua, número, bairro, cidade", height=100)
        
        col1, col2 = st.columns([1, 1])
        with col1:
            submit = st.form_submit_button("💾 Salvar Cliente", use_container_width=True)
        with col2:
            if st.form_submit_button("🔙 Voltar", use_container_width=True):
                st.session_state['page'] = 'clientes'
                st.rerun()
        
        if submit:
            # Validações
            errors = []
            
            if not nome or len(nome.strip()) < 3:
                errors.append("Nome deve ter pelo menos 3 caracteres")
            
            if not cpf:
                errors.append("CPF é obrigatório")
            else:
                cpf_clean = re.sub(r'\D', '', cpf)
                if len(cpf_clean) != 11:
                    errors.append("CPF deve ter 11 dígitos")
                elif not validate_cpf(cpf):
                    errors.append("CPF inválido")
            
            if not telefone:
                errors.append("Telefone é obrigatório")
            
            if email and not re.match(r'^[^@]+@[^@]+\.[^@]+$', email):
                errors.append("Email inválido")
            
            if errors:
                for error in errors:
                    st.error(f"❌ {error}")
            else:
                try:
                    cpf_clean = re.sub(r'\D', '', cpf)
                    telefone_clean = re.sub(r'\D', '', telefone)
                    
                    # Verificar se CPF já existe
                    existing = db.execute_query("SELECT id FROM clientes WHERE cpf = %s", (cpf_clean,))
                    if existing:
                        st.error("❌ CPF já cadastrado!")
                    else:
                        # Inserir cliente
                        query = """
                        INSERT INTO clientes (nome, cpf, endereco, telefone, email, created_at)
                        VALUES (%s, %s, %s, %s, %s, %s)
                        """
                        
                        result = db.execute_insert(
                            query, 
                            (nome.strip(), cpf_clean, endereco.strip(), telefone_clean, email.strip(), datetime.now())
                        )
                        
                        if result:
                            st.success("✅ Cliente cadastrado com sucesso!")
                            st.balloons()
                            
                            if st.button("🎯 Criar Contrato para este Cliente"):
                                st.session_state['cliente_selecionado'] = result
                                st.session_state['page'] = 'novo_contrato'
                                st.rerun()
                        else:
                            st.error("❌ Erro ao cadastrar cliente")
                            
                except Exception as e:
                    st.error(f"❌ Erro: {e}")

def show_contratos():
    """Lista de contratos"""
    st.markdown("""
    <div class="main-header">
        <h1>📋 Gestão de Contratos</h1>
        <p>Visualize e gerencie todos os contratos</p>
    </div>
    """, unsafe_allow_html=True)
    
    db = st.session_state.get('db')
    if not db:
        st.error("Erro de conexão com banco de dados")
        return
    
    # Filtros
    col1, col2, col3 = st.columns([2, 1, 1])
    with col1:
        search = st.text_input("🔍 Pesquisar contratos", placeholder="Número, cliente...")
    with col2:
        status_filter = st.selectbox("Status", ["Todos", "Ativo", "Concluído", "Cancelado"])
    with col3:
        if st.button("➕ Novo Contrato", use_container_width=True):
            st.session_state['page'] = 'novo_contrato'
            st.rerun()
    
    # Buscar contratos
    query = """
    SELECT c.*, cl.nome as cliente_nome, cl.telefone as cliente_telefone
    FROM contratos c
    JOIN clientes cl ON c.cliente_id = cl.id
    WHERE 1=1
    """
    params = []
    
    if search:
        query += " AND (c.numero_contrato LIKE %s OR cl.nome LIKE %s OR c.local_evento LIKE %s)"
        search_term = f"%{search}%"
        params.extend([search_term, search_term, search_term])
    
    if status_filter != "Todos":
        query += " AND c.status = %s"
        params.append(status_filter.lower())
    
    query += " ORDER BY c.data_evento DESC"
    
    contratos = db.execute_query(query, params if params else None)
    
    if not contratos:
        st.info("📝 Nenhum contrato encontrado.")
        if st.button("🚀 Criar Primeiro Contrato"):
            st.session_state['page'] = 'novo_contrato'
            st.rerun()
    else:
        # Converter para DataFrame
        df = pd.DataFrame(contratos)
        df['data_evento'] = pd.to_datetime(df['data_evento']).dt.strftime('%d/%m/%Y')
        df['valor_total'] = df['valor_total'].apply(lambda x: f"R$ {float(x):,.2f}")
        df['status'] = df['status'].str.title()
        
        # Exibir tabela
        st.dataframe(
            df[['numero_contrato', 'cliente_nome', 'data_evento', 'local_evento', 'valor_total', 'status']],
            column_config={
                'numero_contrato': 'Número',
                'cliente_nome': 'Cliente',
                'data_evento': 'Data do Evento',
                'local_evento': 'Local',
                'valor_total': 'Valor',
                'status': 'Status'
            },
            use_container_width=True,
            hide_index=True
        )
        
        st.info(f"📊 Total: {len(contratos)} contratos encontrados")

def main():
    """Função principal"""
    # Inicializar sessão
    if 'db' not in st.session_state:
        st.session_state['db'] = init_database()
    
    if 'user' not in st.session_state:
        st.session_state['user'] = None
    
    if 'page' not in st.session_state:
        st.session_state['page'] = 'dashboard'
    
    # Verificar autenticação
    if not st.session_state['user']:
        show_login()
        return
    
    # Sidebar
    with st.sidebar:
        st.markdown("### 🎉 BagunçArt")
        st.write(f"👤 **{st.session_state['user']['nome']}**")
        
        st.markdown("---")
        
        # Menu
        if st.button("📊 Dashboard", use_container_width=True):
            st.session_state['page'] = 'dashboard'
            st.rerun()
        
        if st.button("👥 Clientes", use_container_width=True):
            st.session_state['page'] = 'clientes'
            st.rerun()
        
        if st.button("📋 Contratos", use_container_width=True):
            st.session_state['page'] = 'contratos'
            st.rerun()
        
        if st.button("👤 Cadastrar Cliente", use_container_width=True):
            st.session_state['page'] = 'cadastro_cliente'
            st.rerun()
        
        st.markdown("---")
        
        if st.button("🚪 Sair", use_container_width=True):
            st.session_state['user'] = None
            st.session_state['page'] = 'dashboard'
            st.rerun()
    
    # Roteamento de páginas
    page = st.session_state.get('page', 'dashboard')
    
    if page == 'dashboard':
        show_dashboard()
    elif page == 'clientes':
        show_clientes()
    elif page == 'cadastro_cliente':
        show_cadastro_cliente()
    elif page == 'contratos':
        show_contratos()
    else:
        show_dashboard()

if __name__ == "__main__":
    main()