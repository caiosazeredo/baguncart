import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collections
  final String _clientesCollection = 'clientes';
  final String _servicosCollection = 'servicos';
  final String _contratosCollection = 'contratos';
  final String _promocoesCollection = 'promocoes';
  final String _notificacoesCollection = 'notificacoes';

  // AUTH
  Future<bool> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      return credential.user != null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw 'Usuário não encontrado. Verifique o email.';
        case 'wrong-password':
          throw 'Senha incorreta.';
        case 'user-disabled':
          throw 'Usuário desabilitado.';
        case 'too-many-requests':
          throw 'Muitas tentativas. Tente novamente mais tarde.';
        case 'invalid-email':
          throw 'Email inválido.';
        default:
          throw 'Erro de autenticação: ${e.message}';
      }
    } catch (e) {
      throw 'Erro de conexão: $e';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;

  // CLIENTES
  Future<List<Cliente>> getClientes() async {
    try {
      final querySnapshot = await _firestore
          .collection(_clientesCollection)
          .orderBy('nome')
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Cliente.fromMap(data);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<String?> insertCliente(Cliente cliente) async {
    try {
      final docRef = await _firestore
          .collection(_clientesCollection)
          .add({
        ...cliente.toMap(),
        'created_at': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateCliente(String id, Cliente cliente) async {
    try {
      await _firestore
          .collection(_clientesCollection)
          .doc(id)
          .update({
        ...cliente.toMap(),
        'updated_at': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteCliente(String id) async {
    try {
      await _firestore.collection(_clientesCollection).doc(id).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  // SERVIÇOS
  Future<List<Servico>> getServicos() async {
    try {
      final querySnapshot = await _firestore
          .collection(_servicosCollection)
          .orderBy('nome')
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Servico.fromMap(data);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<String?> insertServico(Servico servico) async {
    try {
      final docRef = await _firestore
          .collection(_servicosCollection)
          .add({
        ...servico.toMap(),
        'created_at': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateServico(String id, Servico servico) async {
    try {
      await _firestore
          .collection(_servicosCollection)
          .doc(id)
          .update({
        ...servico.toMap(),
        'updated_at': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteServico(String id) async {
    try {
      await _firestore.collection(_servicosCollection).doc(id).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  // CONTRATOS
  Future<List<Contrato>> getContratos() async {
    try {
      final querySnapshot = await _firestore
          .collection(_contratosCollection)
          .orderBy('created_at', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Contrato.fromMap(data);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<String?> insertContrato(Contrato contrato) async {
    try {
      final docRef = await _firestore
          .collection(_contratosCollection)
          .add({
        ...contrato.toMap(),
        'created_at': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateContrato(String id, Contrato contrato) async {
    try {
      await _firestore
          .collection(_contratosCollection)
          .doc(id)
          .update({
        ...contrato.toMap(),
        'updated_at': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteContrato(String id) async {
    try {
      await _firestore.collection(_contratosCollection).doc(id).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  // PROMOÇÕES
  Future<List<Promocao>> getPromocoes() async {
    try {
      final querySnapshot = await _firestore
          .collection(_promocoesCollection)
          .orderBy('created_at', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Promocao.fromMap(data);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<String?> insertPromocao(Promocao promocao) async {
    try {
      final docRef = await _firestore
          .collection(_promocoesCollection)
          .add({
        ...promocao.toMap(),
        'created_at': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updatePromocao(String id, Promocao promocao) async {
    try {
      await _firestore
          .collection(_promocoesCollection)
          .doc(id)
          .update({
        ...promocao.toMap(),
        'updated_at': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deletePromocao(String id) async {
    try {
      await _firestore.collection(_promocoesCollection).doc(id).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  // NOTIFICAÇÕES
  Future<List<Notificacao>> getNotificacoes() async {
    try {
      final querySnapshot = await _firestore
          .collection(_notificacoesCollection)
          .orderBy('created_at', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Notificacao.fromMap(data);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<String?> insertNotificacao(Notificacao notificacao) async {
    try {
      final docRef = await _firestore
          .collection(_notificacoesCollection)
          .add({
        ...notificacao.toMap(),
        'created_at': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateNotificacao(String id, Notificacao notificacao) async {
    try {
      await _firestore
          .collection(_notificacoesCollection)
          .doc(id)
          .update({
        ...notificacao.toMap(),
        'updated_at': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteNotificacao(String id) async {
    try {
      await _firestore.collection(_notificacoesCollection).doc(id).delete();
      return true;
    } catch (e) {
      return false;
    }
  }
}