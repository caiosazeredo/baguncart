// src/screens/ClientesScreen.js
import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  SafeAreaView,
  FlatList,
  Alert,
  RefreshControl,
} from 'react-native';
import { colors, texts } from '../utils';
// import { clienteService } from '../services/clienteService';

const ClientesScreen = ({ navigation }) => {
  const [clientes, setClientes] = useState([]);
  const [searchText, setSearchText] = useState('');
  const [loading, setLoading] = useState(false);
  const [refreshing, setRefreshing] = useState(false);

  // Dados simulados - substitua pela chamada real da API
  const clientesSimulados = [
    {
      id: 1,
      nome: 'Gabriel Oliveira',
      telefone: '(21)99999-9999',
      email: 'gabriel.oliveira@gmail.com',
      cpf: '123.456.789-00',
    },
    {
      id: 2,
      nome: 'Maria Silva',
      telefone: '(21)88888-8888',
      email: 'maria.silva@gmail.com',
      cpf: '987.654.321-00',
    },
    {
      id: 3,
      nome: 'João Santos',
      telefone: '(21)77777-7777',
      email: 'joao.santos@gmail.com',
      cpf: '456.789.123-00',
    },
  ];

  useEffect(() => {
    carregarClientes();
  }, []);

  const carregarClientes = async () => {
    setLoading(true);
    try {
      // const response = await clienteService.getAll(searchText);
      // setClientes(response);
      
      // Simulação - substitua pela chamada real
      setTimeout(() => {
        setClientes(clientesSimulados);
        setLoading(false);
      }, 1000);
      
    } catch (error) {
      setLoading(false);
      Alert.alert('Erro', 'Erro ao carregar clientes');
    }
  };

  const onRefresh = async () => {
    setRefreshing(true);
    await carregarClientes();
    setRefreshing(false);
  };

  const buscarClientes = async () => {
    if (searchText.trim()) {
      const clientesFiltrados = clientesSimulados.filter(cliente =>
        cliente.nome.toLowerCase().includes(searchText.toLowerCase()) ||
        cliente.telefone.includes(searchText) ||
        cliente.email.toLowerCase().includes(searchText.toLowerCase())
      );
      setClientes(clientesFiltrados);
    } else {
      setClientes(clientesSimulados);
    }
  };

  const handleClientePress = (cliente) => {
    Alert.alert(
      cliente.nome,
      `Telefone: ${cliente.telefone}\nEmail: ${cliente.email}\nCPF: ${cliente.cpf}`,
      [
        { text: 'Fechar', style: 'cancel' },
        { text: 'Editar', onPress: () => editarCliente(cliente) },
        { text: 'Novo Contrato', onPress: () => novoContrato(cliente) },
      ]
    );
  };

  const editarCliente = (cliente) => {
    // Navegar para tela de edição
    navigation.navigate('CadastroCliente', { cliente, isEdit: true });
  };

  const novoContrato = (cliente) => {
    // Navegar para criação de contrato com cliente pré-selecionado
    navigation.navigate('CadastroCliente', { clienteSelecionado: cliente });
  };

  const renderCliente = ({ item }) => (
    <TouchableOpacity
      style={styles.clienteCard}
      onPress={() => handleClientePress(item)}
    >
      <View style={styles.clienteIcon}>
        <Text style={styles.clienteIconText}>👤</Text>
      </View>
      <View style={styles.clienteInfo}>
        <Text style={styles.clienteNome}>{item.nome}</Text>
        <Text style={styles.clienteTelefone}>{item.telefone}</Text>
        <Text style={styles.clienteEmail}>{item.email}</Text>
      </View>
      <View style={styles.clienteActions}>
        <Text style={styles.actionIcon}>📞</Text>
      </View>
    </TouchableOpacity>
  );

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity 
          style={styles.backButton}
          onPress={() => navigation.goBack()}
        >
          <Text style={styles.backButtonText}>←</Text>
        </TouchableOpacity>
        <Text style={styles.headerTitle}>{texts.clientes.title}</Text>
        <TouchableOpacity 
          style={styles.addButton}
          onPress={() => navigation.navigate('CadastroCliente')}
        >
          <Text style={styles.addButtonText}>+</Text>
        </TouchableOpacity>
      </View>

      <View style={styles.searchContainer}>
        <TextInput
          style={styles.searchInput}
          placeholder={texts.clientes.pesquisar}
          placeholderTextColor={colors.gray}
          value={searchText}
          onChangeText={setSearchText}
          onSubmitEditing={buscarClientes}
        />
        <TouchableOpacity style={styles.searchButton} onPress={buscarClientes}>
          <Text style={styles.searchIcon}>🔍</Text>
        </TouchableOpacity>
      </View>

      <FlatList
        data={clientes}
        renderItem={renderCliente}
        keyExtractor={(item) => item.id.toString()}
        contentContainerStyle={styles.listContainer}
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
        }
        ListEmptyComponent={
          <View style={styles.emptyContainer}>
            <Text style={styles.emptyText}>
              {loading ? 'Carregando...' : texts.clientes.noClients}
            </Text>
          </View>
        }
      />
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.white,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 20,
    paddingVertical: 15,
    backgroundColor: colors.white,
    borderBottomWidth: 1,
    borderBottomColor: colors.lightGray,
  },
  backButton: {
    padding: 10,
  },
  backButtonText: {
    fontSize: 24,
    color: colors.primary,
    fontWeight: 'bold',
  },
  headerTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: colors.primary,
  },
  addButton: {
    backgroundColor: colors.primary,
    width: 40,
    height: 40,
    borderRadius: 20,
    justifyContent: 'center',
    alignItems: 'center',
  },
  addButtonText: {
    color: colors.white,
    fontSize: 24,
    fontWeight: 'bold',
  },
  searchContainer: {
    flexDirection: 'row',
    paddingHorizontal: 20,
    paddingVertical: 15,
    alignItems: 'center',
  },
  searchInput: {
    flex: 1,
    borderWidth: 1,
    borderColor: colors.gray,
    borderRadius: 25,
    paddingHorizontal: 20,
    paddingVertical: 12,
    fontSize: 16,
    backgroundColor: colors.lightGray,
    marginRight: 10,
  },
  searchButton: {
    backgroundColor: colors.secondary,
    width: 45,
    height: 45,
    borderRadius: 22.5,
    justifyContent: 'center',
    alignItems: 'center',
  },
  searchIcon: {
    fontSize: 20,
  },
  listContainer: {
    paddingHorizontal: 20,
    paddingBottom: 20,
  },
  clienteCard: {
    flexDirection: 'row',
    backgroundColor: colors.white,
    borderRadius: 12,
    padding: 15,
    marginVertical: 5,
    shadowColor: colors.black,
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
    borderWidth: 1,
    borderColor: colors.lightGray,
  },
  clienteIcon: {
    width: 50,
    height: 50,
    borderRadius: 25,
    backgroundColor: colors.primary,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 15,
  },
  clienteIconText: {
    fontSize: 24,
    color: colors.white,
  },
  clienteInfo: {
    flex: 1,
    justifyContent: 'center',
  },
  clienteNome: {
    fontSize: 16,
    fontWeight: 'bold',
    color: colors.darkGray,
    marginBottom: 4,
  },
  clienteTelefone: {
    fontSize: 14,
    color: colors.gray,
    marginBottom: 2,
  },
  clienteEmail: {
    fontSize: 14,
    color: colors.gray,
  },
  clienteActions: {
    justifyContent: 'center',
    alignItems: 'center',
    paddingLeft: 10,
  },
  actionIcon: {
    fontSize: 20,
  },
  emptyContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingTop: 50,
  },
  emptyText: {
    fontSize: 16,
    color: colors.gray,
    textAlign: 'center',
  },
});

export default ClientesScreen;