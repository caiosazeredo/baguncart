// src/screens/ContratosScreen.js
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
  Modal,
} from 'react-native';
import { colors, texts } from '../utils';
// import { contratoService } from '../services/contratoService';

const ContratosScreen = ({ navigation }) => {
  const [contratos, setContratos] = useState([]);
  const [searchText, setSearchText] = useState('');
  const [loading, setLoading] = useState(false);
  const [refreshing, setRefreshing] = useState(false);
  const [contratoSelecionado, setContratoSelecionado] = useState(null);
  const [modalVisible, setModalVisible] = useState(false);

  // Dados simulados - substitua pela chamada real da API
  const contratosSimulados = [
    {
      id: 1,
      numeroContrato: '7.589',
      contratante: 'Gabriel Oliveira',
      dataEvento: '25/05/25',
      localEvento: 'Rua das Laranjeiras, 325 - Casa 02',
      valorTotal: 100.00,
      status: 'ativo',
      servicos: [
        { nome: 'Pula pula', preco: 20.00, quantidade: 1 },
        { nome: 'Garçom', preco: 20.00, quantidade: 1 },
        { nome: 'Barman', preco: 20.00, quantidade: 1 },
        { nome: 'Palhaço', preco: 20.00, quantidade: 1 },
        { nome: 'Recepção', preco: 20.00, quantidade: 1 },
      ],
    },
    {
      id: 2,
      numeroContrato: '7.709',
      contratante: 'Gabriel Oliveira',
      dataEvento: '30/06/25',
      localEvento: 'Rua das Palmeiras, 150 - Ap 301',
      valorTotal: 150.00,
      status: 'ativo',
      servicos: [
        { nome: 'Pula pula', preco: 30.00, quantidade: 2 },
        { nome: 'Garçom', preco: 25.00, quantidade: 2 },
        { nome: 'DJ', preco: 70.00, quantidade: 1 },
      ],
    },
    {
      id: 3,
      numeroContrato: '7.852',
      contratante: 'Gabriel Oliveira',
      dataEvento: '30/09/25',
      localEvento: 'Salão de Festas - Centro',
      valorTotal: 300.00,
      status: 'ativo',
      servicos: [
        { nome: 'Decoração completa', preco: 150.00, quantidade: 1 },
        { nome: 'Buffet', preco: 100.00, quantidade: 1 },
        { nome: 'Som e luz', preco: 50.00, quantidade: 1 },
      ],
    },
    {
      id: 4,
      numeroContrato: '7.287',
      contratante: 'Gabriel Oliveira',
      dataEvento: '25/01/26',
      localEvento: 'Chácara das Flores',
      valorTotal: 500.00,
      status: 'ativo',
      servicos: [
        { nome: 'Evento completo', preco: 500.00, quantidade: 1 },
      ],
    },
  ];

  useEffect(() => {
    carregarContratos();
  }, []);

  const carregarContratos = async () => {
    setLoading(true);
    try {
      // const response = await contratoService.getAll(searchText);
      // setContratos(response);
      
      // Simulação - substitua pela chamada real
      setTimeout(() => {
        setContratos(contratosSimulados);
        setLoading(false);
      }, 1000);
      
    } catch (error) {
      setLoading(false);
      Alert.alert('Erro', 'Erro ao carregar contratos');
    }
  };

  const onRefresh = async () => {
    setRefreshing(true);
    await carregarContratos();
    setRefreshing(false);
  };

  const buscarContratos = async () => {
    if (searchText.trim()) {
      const contratosFiltrados = contratosSimulados.filter(contrato =>
        contrato.numeroContrato.includes(searchText) ||
        contrato.contratante.toLowerCase().includes(searchText.toLowerCase()) ||
        contrato.dataEvento.includes(searchText)
      );
      setContratos(contratosFiltrados);
    } else {
      setContratos(contratosSimulados);
    }
  };

  const handleContratoPress = (contrato) => {
    setContratoSelecionado(contrato);
    setModalVisible(true);
  };

  const formatCurrency = (value) => {
    return `R$ ${value.toFixed(2).replace('.', ',')}`;
  };

  const renderContrato = ({ item }) => (
    <TouchableOpacity
      style={styles.contratoCard}
      onPress={() => handleContratoPress(item)}
    >
      <View style={styles.contratoHeader}>
        <Text style={styles.numeroContrato}>
          Contrato - {item.numeroContrato}
        </Text>
        <TouchableOpacity style={styles.downloadButton}>
          <Text style={styles.downloadIcon}>📥</Text>
        </TouchableOpacity>
      </View>
      <Text style={styles.contratante}>
        Contratante: {item.contratante}
      </Text>
      <Text style={styles.dataEvento}>
        Data: {item.dataEvento}
      </Text>
      <View style={styles.contratoFooter}>
        <Text style={styles.valorTotal}>
          {formatCurrency(item.valorTotal)}
        </Text>
        <View style={[styles.statusBadge, { 
          backgroundColor: item.status === 'ativo' ? colors.success : colors.warning 
        }]}>
          <Text style={styles.statusText}>{item.status}</Text>
        </View>
      </View>
    </TouchableOpacity>
  );

  const renderContratoModal = () => (
    <Modal
      animationType="slide"
      transparent={true}
      visible={modalVisible}
      onRequestClose={() => setModalVisible(false)}
    >
      <View style={styles.modalOverlay}>
        <View style={styles.modalContent}>
          <View style={styles.modalHeader}>
            <Text style={styles.modalTitle}>
              Contrato {contratoSelecionado?.numeroContrato}
            </Text>
            <TouchableOpacity
              style={styles.closeButton}
              onPress={() => setModalVisible(false)}
            >
              <Text style={styles.closeButtonText}>×</Text>
            </TouchableOpacity>
          </View>

          <View style={styles.contratoDetalhes}>
            <Text style={styles.detalheLabel}>Contratante:</Text>
            <Text style={styles.detalheValue}>{contratoSelecionado?.contratante}</Text>

            <Text style={styles.detalheLabel}>Data do Evento:</Text>
            <Text style={styles.detalheValue}>{contratoSelecionado?.dataEvento}</Text>

            <Text style={styles.detalheLabel}>Local do Evento:</Text>
            <Text style={styles.detalheValue}>{contratoSelecionado?.localEvento}</Text>

            <Text style={styles.detalheLabel}>Serviços Contratados:</Text>
            {contratoSelecionado?.servicos.map((servico, index) => (
              <View key={index} style={styles.servicoItem}>
                <Text style={styles.servicoNome}>• {servico.nome}</Text>
                <Text style={styles.servicoPreco}>
                  {servico.quantidade}x {formatCurrency(servico.preco)}
                </Text>
              </View>
            ))}

            <View style={styles.totalContainer}>
              <Text style={styles.totalLabel}>Valor Total:</Text>
              <Text style={styles.totalValue}>
                {formatCurrency(contratoSelecionado?.valorTotal || 0)}
              </Text>
            </View>
          </View>

          <View style={styles.modalActions}>
            <TouchableOpacity style={styles.editButton}>
              <Text style={styles.editButtonText}>Editar</Text>
            </TouchableOpacity>
            <TouchableOpacity style={styles.shareButton}>
              <Text style={styles.shareButtonText}>Compartilhar</Text>
            </TouchableOpacity>
          </View>
        </View>
      </View>
    </Modal>
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
        <Text style={styles.headerTitle}>{texts.contratos.title}</Text>
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
          placeholder={texts.contratos.pesquisar}
          placeholderTextColor={colors.gray}
          value={searchText}
          onChangeText={setSearchText}
          onSubmitEditing={buscarContratos}
        />
        <TouchableOpacity style={styles.searchButton} onPress={buscarContratos}>
          <Text style={styles.searchIcon}>🔍</Text>
        </TouchableOpacity>
      </View>

      <FlatList
        data={contratos}
        renderItem={renderContrato}
        keyExtractor={(item) => item.id.toString()}
        contentContainerStyle={styles.listContainer}
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
        }
        ListEmptyComponent={
          <View style={styles.emptyContainer}>
            <Text style={styles.emptyText}>
              {loading ? 'Carregando...' : texts.contratos.noContracts}
            </Text>
          </View>
        }
      />

      {renderContratoModal()}
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
  contratoCard: {
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
  contratoHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 8,
  },
  numeroContrato: {
    fontSize: 16,
    fontWeight: 'bold',
    color: colors.darkGray,
  },
  downloadButton: {
    padding: 5,
  },
  downloadIcon: {
    fontSize: 20,
    color: colors.primary,
  },
  contratante: {
    fontSize: 14,
    color: colors.gray,
    marginBottom: 4,
  },
  dataEvento: {
    fontSize: 14,
    color: colors.gray,
    marginBottom: 12,
  },
  contratoFooter: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  valorTotal: {
    fontSize: 16,
    fontWeight: 'bold',
    color: colors.primary,
  },
  statusBadge: {
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 12,
  },
  statusText: {
    color: colors.white,
    fontSize: 12,
    fontWeight: 'bold',
    textTransform: 'uppercase',
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
  // Modal styles
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  modalContent: {
    backgroundColor: colors.white,
    borderRadius: 20,
    padding: 20,
    width: '90%',
    maxHeight: '80%',
  },
  modalHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 20,
    borderBottomWidth: 1,
    borderBottomColor: colors.lightGray,
    paddingBottom: 15,
  },
  modalTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: colors.primary,
  },
  closeButton: {
    width: 30,
    height: 30,
    borderRadius: 15,
    backgroundColor: colors.lightGray,
    justifyContent: 'center',
    alignItems: 'center',
  },
  closeButtonText: {
    fontSize: 20,
    color: colors.gray,
    fontWeight: 'bold',
  },
  contratoDetalhes: {
    marginBottom: 20,
  },
  detalheLabel: {
    fontSize: 14,
    fontWeight: 'bold',
    color: colors.darkGray,
    marginTop: 10,
    marginBottom: 5,
  },
  detalheValue: {
    fontSize: 14,
    color: colors.gray,
  },
  servicoItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingVertical: 4,
  },
  servicoNome: {
    fontSize: 14,
    color: colors.darkGray,
  },
  servicoPreco: {
    fontSize: 14,
    color: colors.gray,
  },
  totalContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginTop: 15,
    paddingTop: 15,
    borderTopWidth: 1,
    borderTopColor: colors.lightGray,
  },
  totalLabel: {
    fontSize: 16,
    fontWeight: 'bold',
    color: colors.primary,
  },
  totalValue: {
    fontSize: 16,
    fontWeight: 'bold',
    color: colors.primary,
  },
  modalActions: {
    flexDirection: 'row',
    justifyContent: 'space-around',
  },
  editButton: {
    backgroundColor: colors.secondary,
    paddingHorizontal: 20,
    paddingVertical: 10,
    borderRadius: 20,
    flex: 1,
    marginRight: 10,
    alignItems: 'center',
  },
  editButtonText: {
    color: colors.white,
    fontWeight: 'bold',
  },
  shareButton: {
    backgroundColor: colors.primary,
    paddingHorizontal: 20,
    paddingVertical: 10,
    borderRadius: 20,
    flex: 1,
    marginLeft: 10,
    alignItems: 'center',
  },
  shareButtonText: {
    color: colors.white,
    fontWeight: 'bold',
  },
});

export default ContratosScreen;