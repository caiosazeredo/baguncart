// src/screens/NotificacaoScreen.js
import React, { useState } from 'react';
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
import { colors, texts } from '../utils';

const NotificacaoScreen = ({ navigation }) => {
  const [formData, setFormData] = useState({
    clienteId: '',
    contratoId: '',
    servicosIds: [],
    mensagem: '',
  });

  const [showClientesModal, setShowClientesModal] = useState(false);
  const [showContratosModal, setShowContratosModal] = useState(false);
  const [showServicosModal, setShowServicosModal] = useState(false);
  const [loading, setLoading] = useState(false);

  // Dados simulados
  const clientesDisponiveis = [
    { id: 1, nome: 'Gabriel Oliveira', telefone: '(21)99999-9999', email: 'gabriel.oliveira@gmail.com' },
    { id: 2, nome: 'Maria Silva', telefone: '(21)88888-8888', email: 'maria.silva@gmail.com' },
    { id: 3, nome: 'João Santos', telefone: '(21)77777-7777', email: 'joao.santos@gmail.com' },
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

  // Templates de mensagem predefinidos
  const templatesMensagem = [
    {
      id: 1,
      titulo: 'Lembrete de Evento',
      texto: 'Olá! Este é um lembrete de que seu evento está se aproximando. Nossa equipe está preparada para tornar este dia inesquecível!'
    },
    {
      id: 2,
      titulo: 'Confirmação de Serviços',
      texto: 'Gostaríamos de confirmar os serviços contratados para seu evento. Por favor, entre em contato para validarmos todos os detalhes.'
    },
    {
      id: 3,
      titulo: 'Promoção Especial',
      texto: 'Temos uma promoção especial para você! Confira nossos novos serviços com desconto especial para clientes VIP.'
    },
    {
      id: 4,
      titulo: 'Agradecimento',
      texto: 'Obrigado por escolher a BagunçArt para seu evento! Foi um prazer fazer parte deste momento especial.'
    },
  ];

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

  const aplicarTemplate = (template) => {
    Alert.alert(
      template.titulo,
      'Deseja usar este template?',
      [
        { text: 'Cancelar', style: 'cancel' },
        { 
          text: 'Usar', 
          onPress: () => {
            setFormData(prev => ({ ...prev, mensagem: template.texto }));
          }
        },
      ]
    );
  };

  const validateForm = () => {
    if (!formData.clienteId) {
      Alert.alert('Erro', 'Selecione um cliente');
      return false;
    }
    if (!formData.mensagem.trim()) {
      Alert.alert('Erro', 'Digite uma mensagem');
      return false;
    }
    return true;
  };

  const handleNotificar = async () => {
    if (!validateForm()) return;

    const cliente = clienteSelecionado;
    const contrato = contratoSelecionado;
    const servicos = servicosSelecionados;

    let resumo = `Cliente: ${cliente.nome}\n`;
    if (contrato) {
      resumo += `Contrato: ${contrato.numero}\n`;
    }
    if (servicos.length > 0) {
      resumo += `Serviços: ${servicos.map(s => s.nome).join(', ')}\n`;
    }
    resumo += `\nMensagem:\n${formData.mensagem}`;

    Alert.alert(
      'Confirmar Notificação',
      resumo,
      [
        { text: 'Cancelar', style: 'cancel' },
        { 
          text: 'Enviar', 
          onPress: async () => {
            setLoading(true);
            try {
              // Aqui você faria a chamada para a API
              // await notificacaoService.enviar(formData);

              setTimeout(() => {
                setLoading(false);
                Alert.alert(
                  'Sucesso',
                  'Notificação enviada com sucesso!',
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
              Alert.alert('Erro', 'Erro ao enviar notificação. Tente novamente.');
            }
          }
        },
      ]
    );
  };

  const renderClienteItem = ({ item }) => (
    <TouchableOpacity
      style={styles.modalItem}
      onPress={() => selecionarCliente(item)}
    >
      <Text style={styles.modalItemText}>{item.nome}</Text>
      <Text style={styles.modalItemSubtext}>{item.telefone}</Text>
      <Text style={styles.modalItemSubtext}>{item.email}</Text>
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
          <Text style={styles.servicoPreco}>R$ {item.preco.toFixed(2).replace('.', ',')}</Text>
        </View>
        <View style={styles.checkbox}>
          {isSelected && <Text style={styles.checkmark}>✓</Text>}
        </View>
      </TouchableOpacity>
    );
  };

  const renderTemplateItem = ({ item }) => (
    <TouchableOpacity
      style={styles.templateItem}
      onPress={() => aplicarTemplate(item)}
    >
      <Text style={styles.templateTitulo}>{item.titulo}</Text>
      <Text style={styles.templateTexto} numberOfLines={2}>
        {item.texto}
      </Text>
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
        <Text style={styles.headerTitle}>{texts.notificacao.title}</Text>
        <View style={styles.headerIcon}>
          <Text style={styles.headerIconText}>🔔</Text>
        </View>
      </View>

      <ScrollView style={styles.content}>
        <Text style={styles.subtitle}>
          {texts.notificacao.subtitle}
        </Text>

        <View style={styles.form}>
          {/* Cliente */}
          <Text style={styles.label}>
            {texts.notificacao.cliente} {texts.notificacao.required}
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
          <Text style={styles.label}>{texts.notificacao.contrato}</Text>
          <TouchableOpacity
            style={[styles.selectorButton, !formData.clienteId && styles.disabled]}
            onPress={() => formData.clienteId && setShowContratosModal(true)}
            disabled={!formData.clienteId}
          >
            <Text style={[styles.selectorText, !contratoSelecionado && styles.placeholder]}>
              {contratoSelecionado ? `Contrato ${contratoSelecionado.numero}` : 'Selecionar contrato (opcional)'}
            </Text>
            <Text style={styles.selectorIcon}>+</Text>
          </TouchableOpacity>

          {/* Serviços */}
          <Text style={styles.label}>{texts.notificacao.servicos}</Text>
          <TouchableOpacity
            style={styles.selectorButton}
            onPress={() => setShowServicosModal(true)}
          >
            <Text style={[styles.selectorText, servicosSelecionados.length === 0 && styles.placeholder]}>
              {servicosSelecionados.length > 0 
                ? `${servicosSelecionados.length} serviço(s) selecionado(s)`
                : 'Selecionar serviços (opcional)'
              }
            </Text>
            <Text style={styles.selectorIcon}>+</Text>
          </TouchableOpacity>

          {/* Templates de Mensagem */}
          <Text style={styles.label}>Templates de Mensagem</Text>
          <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.templatesContainer}>
            {templatesMensagem.map((template) => (
              <TouchableOpacity
                key={template.id}
                style={styles.templateCard}
                onPress={() => aplicarTemplate(template)}
              >
                <Text style={styles.templateCardTitulo}>{template.titulo}</Text>
              </TouchableOpacity>
            ))}
          </ScrollView>

          {/* Mensagem */}
          <Text style={styles.label}>
            {texts.notificacao.mensagem} {texts.notificacao.required}
          </Text>
          <TextInput
            style={styles.textArea}
            placeholder="Digite sua mensagem aqui..."
            placeholderTextColor={colors.gray}
            value={formData.mensagem}
            onChangeText={(text) => setFormData(prev => ({ ...prev, mensagem: text }))}
            multiline
            numberOfLines={6}
            textAlignVertical="top"
          />
          
          {/* Contador de caracteres */}
          <Text style={styles.characterCount}>
            {formData.mensagem.length}/500 caracteres
          </Text>
        </View>
      </ScrollView>

      <TouchableOpacity
        style={[styles.notificarButton, loading && styles.buttonDisabled]}
        onPress={handleNotificar}
        disabled={loading}
      >
        <Text style={styles.notificarButtonText}>
          {loading ? 'Enviando...' : texts.notificacao.notificarButton}
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
  templatesContainer: {
    marginVertical: 10,
  },
  templateCard: {
    backgroundColor: colors.primary,
    paddingHorizontal: 15,
    paddingVertical: 10,
    borderRadius: 20,
    marginRight: 10,
  },
  templateCardTitulo: {
    color: colors.white,
    fontSize: 14,
    fontWeight: 'bold',
  },
  textArea: {
    borderWidth: 1,
    borderColor: colors.gray,
    borderRadius: 8,
    padding: 15,
    fontSize: 16,
    backgroundColor: colors.lightGray,
    height: 120,
    textAlignVertical: 'top',
  },
  characterCount: {
    fontSize: 12,
    color: colors.gray,
    textAlign: 'right',
    marginTop: 5,
  },
  notificarButton: {
    backgroundColor: colors.primary,
    borderRadius: 25,
    padding: 15,
    margin: 20,
    alignItems: 'center',
  },
  buttonDisabled: {
    opacity: 0.6,
  },
  notificarButtonText: {
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
  templateItem: {
    padding: 15,
    borderBottomWidth: 1,
    borderBottomColor: colors.lightGray,
  },
  templateTitulo: {
    fontSize: 16,
    fontWeight: 'bold',
    color: colors.primary,
    marginBottom: 5,
  },
  templateTexto: {
    fontSize: 14,
    color: colors.gray,
  },
  emptyText: {
    textAlign: 'center',
    color: colors.gray,
    fontSize: 16,
    padding: 20,
  },
});

export default NotificacaoScreen;