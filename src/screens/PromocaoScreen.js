// src/screens/PromocaoScreen.js
import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  SafeAreaView,
  ScrollView,
  Alert,
  Modal,
  FlatList,
} from 'react-native';
import { Picker } from '@react-native-picker/picker';
import DatePicker from 'react-native-date-picker';
import { colors, texts } from '../utils';

const PromocaoScreen = ({ navigation }) => {
  const [formData, setFormData] = useState({
    clienteId: '',
    contratoId: '',
    servicosIds: [],
    valorPromocional: '',
    validadePromocao: new Date(),
    descricao: '',
  });

  const [showDatePicker, setShowDatePicker] = useState(false);
  const [showClientesModal, setShowClientesModal] = useState(false);
  const [showContratosModal, setShowContratosModal] = useState(false);
  const [showServicosModal, setShowServicosModal] = useState(false);
  const [loading, setLoading] = useState(false);

  // Dados simulados
  const clientesDisponiveis = [
    { id: 1, nome: 'Gabriel Oliveira', telefone: '(21)99999-9999' },
    { id: 2, nome: 'Maria Silva', telefone: '(21)88888-8888' },
    { id: 3, nome: 'João Santos', telefone: '(21)77777-7777' },
  ];

  const contratosDisponiveis = [
    { id: 1, numero: '7.589', clienteId: 1, dataEvento: '25/05/25' },
    { id: 2, numero: '7.709', clienteId: 1, dataEvento: '30/06/25' },
    { id: 3, numero: '7.852', clienteId: 2, dataEvento: '30/09/25' },
  ];

  const servicosDisponiveis = [
    { id: 1, nome: 'Pula pula', preco: 20.00 },
    { id: 2, nome: 'Garçom', preco: 20.00 },
    { id: 3, nome: 'Barman', preco: 20.00 },
    { id: 4, nome: 'Palhaço', preco: 20.00 },
    { id: 5, nome: 'Recepção', preco: 20.00 },
    { id: 6, nome: 'DJ', preco: 50.00 },
    { id: 7, nome: 'Decoração', preco: 100.00 },
  ];

  const [clienteSelecionado, setClienteSelecionado] = useState(null);
  const [contratoSelecionado, setContratoSelecionado] = useState(null);
  const [servicosSelecionados, setServicosSelecionados] = useState([]);

  const filtrarContratosPorCliente = () => {
    if (!formData.clienteId) return [];
    return contratosDisponiveis.filter(contrato => contrato.clienteId === formData.clienteId);
  };

  const selecionarCliente = (cliente) => {
    setClienteSelecionado(cliente);
    setFormData(prev => ({ 
      ...prev, 
      clienteId: cliente.id,
      contratoId: '', // Reset contrato quando cliente muda
    }));
    setContratoSelecionado(null);
    setShowClientesModal(false);
  };

  const selecionarContrato = (contrato) => {
    setContratoSelecionado(contrato);
    setFormData(prev => ({ ...prev, contratoId: contrato.id }));
    setShowContratosModal(false);
  };

  const toggleServico = (servico) => {
    const isSelected = servicosSelecionados.find(s => s.id === servico.id);
    
    if (isSelected) {
      const novosServicos = servicosSelecionados.filter(s => s.id !== servico.id);
      setServicosSelecionados(novosServicos);
      setFormData(prev => ({
        ...prev,
        servicosIds: novosServicos.map(s => s.id)
      }));
    } else {
      const novosServicos = [...servicosSelecionados, servico];
      setServicosSelecionados(novosServicos);
      setFormData(prev => ({
        ...prev,
        servicosIds: novosServicos.map(s => s.id)
      }));
    }
  };

  const calcularPrecoTotal = () => {
    return servicosSelecionados.reduce((total, servico) => total + servico.preco, 0);
  };

  const validateForm = () => {
    if (!formData.clienteId) {
      Alert.alert('Erro', 'Selecione um cliente');
      return false;
    }
    if (servicosSelecionados.length === 0) {
      Alert.alert('Erro', 'Selecione pelo menos um serviço');
      return false;
    }
    if (!formData.valorPromocional || parseFloat(formData.valorPromocional) <= 0) {
      Alert.alert('Erro', 'Insira um valor promocional válido');
      return false;
    }
    return true;
  };

  const handleEnviar = async () => {
    if (!validateForm()) return;

    setLoading(true);
    try {
      // Aqui você faria a chamada para a API
      // await promocaoService.create(formData);

      setTimeout(() => {
        setLoading(false);
        Alert.alert(
          'Sucesso',
          'Promoção criada com sucesso!',
          [
            {
              text: 'OK',
              onPress: () => navigation.goBack(),
            },
          ]
        );
      }, 1000);

    } catch (error) {
      setLoading(false);
      Alert.alert('Erro', 'Erro ao criar promoção. Tente novamente.');
    }
  };

  const formatCurrency = (value) => {
    return `R$ ${value.toFixed(2).replace('.', ',')}`;
  };

  const formatDate = (date) => {
    return date.toLocaleDateString('pt-BR');
  };

  const renderClienteItem = ({ item }) => (
    <TouchableOpacity
      style={styles.modalItem}
      onPress={() => selecionarCliente(item)}
    >
      <Text style={styles.modalItemText}>{item.nome}</Text>
      <Text style={styles.modalItemSubtext}>{item.telefone}</Text>
    </TouchableOpacity>
  );

  const renderContratoItem = ({ item }) => (
    <TouchableOpacity
      style={styles.modalItem}
      onPress={() => selecionarContrato(item)}
    >
      <Text style={styles.modalItemText}>Contrato {item.numero}</Text>
      <Text style={styles.modalItemSubtext}>Data: {item.dataEvento}</Text>
    </TouchableOpacity>
  );

  const renderServicoItem = ({ item }) => {
    const isSelected = servicosSelecionados.find(s => s.id === item.id);
    
    return (
      <TouchableOpacity
        style={[styles.servicoItem, isSelected && styles.servicoSelecionado]}
        onPress={() => toggleServico(item)}
      >
        <View style={styles.servicoInfo}>
          <Text style={styles.servicoNome}>{item.nome}</Text>
          <Text style={styles.servicoPreco}>{formatCurrency(item.preco)}</Text>
        </View>
        <View style={styles.checkbox}>
          {isSelected && <Text style={styles.checkmark}>✓</Text>}
        </View>
      </TouchableOpacity>
    );
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity 
          style={styles.backButton}
          onPress={() => navigation.goBack()}
        >
          <Text style={styles.backButtonText}>←</Text>
        </TouchableOpacity>
        <Text style={styles.headerTitle}>{texts.promocao.title}</Text>
        <View style={styles.headerIcon}>
          <Text style={styles.headerIconText}>📢</Text>
        </View>
      </View>

      <ScrollView style={styles.content}>
        <Text style={styles.subtitle}>
          {texts.promocao.subtitle}
        </Text>

        <View style={styles.form}>
          {/* Cliente */}
          <Text style={styles.label}>
            {texts.promocao.cliente} {texts.promocao.required}
          </Text>
          <TouchableOpacity
            style={styles.selectorButton}
            onPress={() => setShowClientesModal(true)}
          >
            <Text style={[styles.selectorText, !clienteSelecionado && styles.placeholder]}>
              {clienteSelecionado ? clienteSelecionado.nome : 'Selecionar cliente'}
            </Text>
            <Text style={styles.selectorIcon}>+</Text>
          </TouchableOpacity>

          {/* Contrato */}
          <Text style={styles.label}>{texts.promocao.contrato}</Text>
          <TouchableOpacity
            style={[styles.selectorButton, !formData.clienteId && styles.disabled]}
            onPress={() => formData.clienteId && setShowContratosModal(true)}
            disabled={!formData.clienteId}
          >
            <Text style={[styles.selectorText, !contratoSelecionado && styles.placeholder]}>
              {contratoSelecionado ? `Contrato ${contratoSelecionado.numero}` : 'Selecionar contrato'}
            </Text>
            <Text style={styles.selectorIcon}>+</Text>
          </TouchableOpacity>

          {/* Serviços */}
          <Text style={styles.label}>
            {texts.promocao.servicos} {texts.promocao.required}
          </Text>
          <TouchableOpacity
            style={styles.selectorButton}
            onPress={() => setShowServicosModal(true)}
          >
            <Text style={[styles.selectorText, servicosSelecionados.length === 0 && styles.placeholder]}>
              {servicosSelecionados.length > 0 
                ? `${servicosSelecionados.length} serviço(s) selecionado(s)`
                : 'Selecionar serviços'
              }
            </Text>
            <Text style={styles.selectorIcon}>+</Text>
          </TouchableOpacity>

          {/* Resumo dos serviços selecionados */}
          {servicosSelecionados.length > 0 && (
            <View style={styles.resumoServicos}>
              <Text style={styles.resumoTitle}>Serviços selecionados:</Text>
              {servicosSelecionados.map((servico) => (
                <Text key={servico.id} style={styles.resumoItem}>
                  • {servico.nome} - {formatCurrency(servico.preco)}
                </Text>
              ))}
              <Text style={styles.resumoTotal}>
                Total: {formatCurrency(calcularPrecoTotal())}
              </Text>
            </View>
          )}

          {/* Valor Promocional */}
          <Text style={styles.label}>
            {texts.promocao.valorPromocional} {texts.promocao.required}
          </Text>
          <TextInput
            style={styles.input}
            placeholder="0,00"
            placeholderTextColor={colors.gray}
            value={formData.valorPromocional}
            onChangeText={(text) => setFormData(prev => ({ ...prev, valorPromocional: text }))}
            keyboardType="numeric"
          />

          {/* Validade */}
          <Text style={styles.label}>
            {texts.promocao.validadePromocao} {texts.promocao.required}
          </Text>
          <TouchableOpacity
            style={styles.dateButton}
            onPress={() => setShowDatePicker(true)}
          >
            <Text style={styles.dateText}>
              {formatDate(formData.validadePromocao)}
            </Text>
            <Text style={styles.calendarIcon}>📅</Text>
          </TouchableOpacity>

          {/* Descrição */}
          <Text style={styles.label}>Descrição (opcional)</Text>
          <TextInput
            style={[styles.input, styles.textArea]}
            placeholder="Descreva os detalhes da promoção..."
            placeholderTextColor={colors.gray}
            value={formData.descricao}
            onChangeText={(text) => setFormData(prev => ({ ...prev, descricao: text }))}
            multiline
            numberOfLines={4}
          />
        </View>
      </ScrollView>

      <TouchableOpacity
        style={[styles.enviarButton, loading && styles.buttonDisabled]}
        onPress={handleEnviar}
        disabled={loading}
      >
        <Text style={styles.enviarButtonText}>
          {loading ? 'Enviando...' : texts.promocao.enviarButton}
        </Text>
      </TouchableOpacity>

      {/* Modal Clientes */}
      <Modal visible={showClientesModal} animationType="slide" transparent>
        <View style={styles.modalOverlay}>
          <View style={styles.modalContent}>
            <View style={styles.modalHeader}>
              <Text style={styles.modalTitle}>Selecionar Cliente</Text>
              <TouchableOpacity
                style={styles.closeButton}
                onPress={() => setShowClientesModal(false)}
              >
                <Text style={styles.closeButtonText}>×</Text>
              </TouchableOpacity>
            </View>
            <FlatList
              data={clientesDisponiveis}
              renderItem={renderClienteItem}
              keyExtractor={(item) => item.id.toString()}
            />
          </View>
        </View>
      </Modal>

      {/* Modal Contratos */}
      <Modal visible={showContratosModal} animationType="slide" transparent>
        <View style={styles.modalOverlay}>
          <View style={styles.modalContent}>
            <View style={styles.modalHeader}>
              <Text style={styles.modalTitle}>Selecionar Contrato</Text>
              <TouchableOpacity
                style={styles.closeButton}
                onPress={() => setShowContratosModal(false)}
              >
                <Text style={styles.closeButtonText}>×</Text>
              </TouchableOpacity>
            </View>
            <FlatList
              data={filtrarContratosPorCliente()}
              renderItem={renderContratoItem}
              keyExtractor={(item) => item.id.toString()}
              ListEmptyComponent={
                <Text style={styles.emptyText}>Nenhum contrato encontrado para este cliente</Text>
              }
            />
          </View>
        </View>
      </Modal>

      {/* Modal Serviços */}
      <Modal visible={showServicosModal} animationType="slide" transparent>
        <View style={styles.modalOverlay}>
          <View style={styles.modalContent}>
            <View style={styles.modalHeader}>
              <Text style={styles.modalTitle}>Selecionar Serviços</Text>
              <TouchableOpacity
                style={styles.closeButton}
                onPress={() => setShowServicosModal(false)}
              >
                <Text style={styles.closeButtonText}>✓</Text>
              </TouchableOpacity>
            </View>
            <FlatList
              data={servicosDisponiveis}
              renderItem={renderServicoItem}
              keyExtractor={(item) => item.id.toString()}
            />
          </View>
        </View>
      </Modal>

      {/* Date Picker */}
      <DatePicker
        modal
        open={showDatePicker}
        date={formData.validadePromocao}
        mode="date"
        locale="pt-BR"
        title="Selecionar Data de Validade"
        confirmText="Confirmar"
        cancelText="Cancelar"
        minimumDate={new Date()}
        onConfirm={(date) => {
          setShowDatePicker(false);
          setFormData(prev => ({ ...prev, validadePromocao: date }));
        }}
        onCancel={() => {
          setShowDatePicker(false);
        }}
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
  headerIcon: {
    padding: 10,
  },
  headerIconText: {
    fontSize: 24,
  },
  content: {
    flex: 1,
    paddingHorizontal: 20,
  },
  subtitle: {
    fontSize: 14,
    color: colors.gray,
    textAlign: 'center',
    marginVertical: 20,
    lineHeight: 20,
  },
  form: {
    flex: 1,
  },
  label: {
    fontSize: 16,
    fontWeight: 'bold',
    color: colors.darkGray,
    marginBottom: 8,
    marginTop: 15,
  },
  input: {
    borderWidth: 1,
    borderColor: colors.gray,
    borderRadius: 8,
    padding: 15,
    fontSize: 16,
    backgroundColor: colors.lightGray,
  },
  textArea: {
    height: 100,
    textAlignVertical: 'top',
  },
  selectorButton: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    borderWidth: 1,
    borderColor: colors.gray,
    borderRadius: 8,
    padding: 15,
    backgroundColor: colors.lightGray,
  },
  disabled: {
    opacity: 0.5,
  },
  selectorText: {
    fontSize: 16,
    color: colors.darkGray,
    flex: 1,
  },
  placeholder: {
    color: colors.gray,
  },
  selectorIcon: {
    fontSize: 20,
    color: colors.primary,
    fontWeight: 'bold',
  },
  dateButton: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    borderWidth: 1,
    borderColor: colors.gray,
    borderRadius: 8,
    padding: 15,
    backgroundColor: colors.lightGray,
  },
  dateText: {
    fontSize: 16,
    color: colors.darkGray,
  },
  calendarIcon: {
    fontSize: 20,
  },
  resumoServicos: {
    backgroundColor: colors.lightGray,
    padding: 15,
    borderRadius: 8,
    marginTop: 10,
  },
  resumoTitle: {
    fontSize: 14,
    fontWeight: 'bold',
    color: colors.darkGray,
    marginBottom: 8,
  },
  resumoItem: {
    fontSize: 14,
    color: colors.gray,
    marginBottom: 4,
  },
  resumoTotal: {
    fontSize: 16,
    fontWeight: 'bold',
    color: colors.primary,
    marginTop: 8,
    textAlign: 'right',
  },
  enviarButton: {
    backgroundColor: colors.primary,
    borderRadius: 25,
    padding: 15,
    margin: 20,
    alignItems: 'center',
  },
  buttonDisabled: {
    opacity: 0.6,
  },
  enviarButtonText: {
    color: colors.white,
    fontSize: 18,
    fontWeight: 'bold',
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
    maxHeight: '70%',
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
    fontSize: 18,
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
    fontSize: 18,
    color: colors.gray,
    fontWeight: 'bold',
  },
  modalItem: {
    padding: 15,
    borderBottomWidth: 1,
    borderBottomColor: colors.lightGray,
  },
  modalItemText: {
    fontSize: 16,
    fontWeight: 'bold',
    color: colors.darkGray,
  },
  modalItemSubtext: {
    fontSize: 14,
    color: colors.gray,
    marginTop: 4,
  },
  servicoItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 15,
    borderBottomWidth: 1,
    borderBottomColor: colors.lightGray,
  },
  servicoSelecionado: {
    backgroundColor: colors.lightGray,
  },
  servicoInfo: {
    flex: 1,
  },
  servicoNome: {
    fontSize: 16,
    fontWeight: 'bold',
    color: colors.darkGray,
  },
  servicoPreco: {
    fontSize: 14,
    color: colors.gray,
    marginTop: 4,
  },
  checkbox: {
    width: 24,
    height: 24,
    borderWidth: 2,
    borderColor: colors.primary,
    borderRadius: 4,
    justifyContent: 'center',
    alignItems: 'center',
  },
  checkmark: {
    color: colors.primary,
    fontSize: 16,
    fontWeight: 'bold',
  },
  emptyText: {
    textAlign: 'center',
    color: colors.gray,
    fontSize: 16,
    padding: 20,
  },
});

export default PromocaoScreen;