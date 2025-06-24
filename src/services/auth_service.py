# src/services/auth_service.py
import bcrypt
from datetime import datetime

class AuthService:
    def __init__(self, database):
        self.db = database
        self.init_admin_user()

    def init_admin_user(self):
        """Criar usuário admin padrão se não existir"""
        try:
            # Verificar se usuário admin já existe
            query = "SELECT * FROM usuarios WHERE cnpj = %s"
            result = self.db.execute_query(query, ("12345678000100",))
            
            if not result:
                # Criar usuário admin
                senha_hash = bcrypt.hashpw("admin123".encode('utf-8'), bcrypt.gensalt())
                
                insert_query = """
                INSERT INTO usuarios (cnpj, senha, nome, email, created_at)
                VALUES (%s, %s, %s, %s, %s)
                """
                
                self.db.execute_insert(
                    insert_query,
                    ("12345678000100", senha_hash, "Administrador", "admin@baguncart.com", datetime.now())
                )
                print("✅ Usuário admin criado: CNPJ 12345678000100 / Senha: admin123")
                
        except Exception as e:
            print(f"Erro ao criar usuário admin: {e}")

    def authenticate(self, cnpj, senha):
        """Autenticar usuário"""
        try:
            # Buscar usuário por CNPJ
            query = "SELECT * FROM usuarios WHERE cnpj = %s"
            result = self.db.execute_query(query, (cnpj,))
            
            if result:
                user = result[0]
                stored_password = user['senha']
                
                # Verificar se é bytes ou string
                if isinstance(stored_password, str):
                    stored_password = stored_password.encode('utf-8')
                
                # Verificar senha
                if bcrypt.checkpw(senha.encode('utf-8'), stored_password):
                    # Login bem-sucedido - remover senha do retorno
                    user_data = {
                        'id': user['id'],
                        'cnpj': user['cnpj'],
                        'nome': user['nome'],
                        'email': user['email']
                    }
                    return user_data
                    
            return None
            
        except Exception as e:
            print(f"Erro na autenticação: {e}")
            return None

    def create_user(self, cnpj, senha, nome, email=None):
        """Criar novo usuário"""
        try:
            # Verificar se CNPJ já existe
            query = "SELECT * FROM usuarios WHERE cnpj = %s"
            result = self.db.execute_query(query, (cnpj,))
            
            if result:
                return {"error": "CNPJ já cadastrado"}
            
            # Hash da senha
            senha_hash = bcrypt.hashpw(senha.encode('utf-8'), bcrypt.gensalt())
            
            # Inserir usuário
            insert_query = """
            INSERT INTO usuarios (cnpj, senha, nome, email, created_at)
            VALUES (%s, %s, %s, %s, %s)
            """
            
            user_id = self.db.execute_insert(
                insert_query,
                (cnpj, senha_hash, nome, email, datetime.now())
            )
            
            if user_id:
                return {"success": True, "user_id": user_id}
            else:
                return {"error": "Erro ao criar usuário"}
                
        except Exception as e:
            print(f"Erro ao criar usuário: {e}")
            return {"error": str(e)}

    def change_password(self, user_id, senha_atual, nova_senha):
        """Alterar senha do usuário"""
        try:
            # Buscar usuário
            query = "SELECT senha FROM usuarios WHERE id = %s"
            result = self.db.execute_query(query, (user_id,))
            
            if not result:
                return {"error": "Usuário não encontrado"}
            
            stored_password = result[0]['senha']
            if isinstance(stored_password, str):
                stored_password = stored_password.encode('utf-8')
            
            # Verificar senha atual
            if not bcrypt.checkpw(senha_atual.encode('utf-8'), stored_password):
                return {"error": "Senha atual incorreta"}
            
            # Hash da nova senha
            nova_senha_hash = bcrypt.hashpw(nova_senha.encode('utf-8'), bcrypt.gensalt())
            
            # Atualizar senha
            update_query = "UPDATE usuarios SET senha = %s WHERE id = %s"
            self.db.execute_query(update_query, (nova_senha_hash, user_id))
            
            return {"success": True}
            
        except Exception as e:
            print(f"Erro ao alterar senha: {e}")
            return {"error": str(e)}