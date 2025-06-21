// src/screens/ServicosScreen.js
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
  FlatList,
} from 'react-native';
import { colors, texts } from '../utils';

const ServicosScreen = ({ navigation, route }) => {
  const [servicosSelecionados, setServicosSelecionados] = useState([]);
  const [valorTotal, setValorTotal] = useState(0);
  const [desconto, setDesconto] = useState(0);
  const [loading, setLoading] = useState(false);
  
  const clienteData = route.params?.clienteData || {};

  const servicosDisponiveis = [
    { id: 1, nome: texts.servicosDisponiveis.pulaPula, preco: 20.00 },
    { id: 2, nome: texts.servicosDisponiveis.garcom, preco: 20.00 },
    { id: 3, nome: texts.servicosDisponiveis.barman, preco: 20.00 },
    { id: 4, nome: texts.servicosDisponiveis.palhaco, preco: 20.00 },
    { id: 5, nome: texts.servicosDisponiveis.recepcao, preco: 20.00 },
  ];

  const [servicoCustomizado, setServicoCustomizado] = useState({
    nome: '',
    preco: '',
  });

  const calcularValorTotal = () => {
    const subtotal = servicosSelecionados.reduce((total, servico) => {
      return total + (servico.preco * servico.quantidade);
    }, 0);
    
    const valorComDesconto = subtotal - desconto;
    setValorTotal(Math.max(0, valorComDesconto));
  };

  useEffect(() => {
    calcularValorTotal();
  }, [servicosSelecionados, desconto]);

  const adicionarServico = (servico) => {
    const servicoExistente = servicosSelecionados.find(s => s.id === servico.id);
    
    if (servicoExistente) {
      setServicosSelecionados(prev => 
        prev.map(s => 
          s.id === servico.id 
            ? { ...s, quantidade: s.quantidade + 1 }
            : s
        )
      );
    } else {
      setServicosSelecionados(prev => [...prev, { ...servico, quantidade: 1 }]);
    }
  };

  const removerServico = (servicoId) => {
    setServicosSelecionados(prev => prev.filter(s => s.id !== servicoId));
  };

  const alterarQuantidade = (servicoId, novaQuantidade) => {
    if (novaQuantidade <= 0) {
      removerServico(servicoId);
      return;
    }
    
    setServicosSelecionados(prev =>
      prev.map(s =>
        s.id === servicoId
          ? { ...s, quantidade: novaQuantidade }
          : s
      )
    );
  };

  const adicionarServicoCustomizado = () => {
    if (!servicoCustomizado.nome.trim() || !servicoCustomizado.preco) {
      Alert.alert('Erro', 'Preencha o nome e o preço do serviço');
      return;
    }

    const novoServico = {
      id: Date.now(), // ID único temporário
      nome: servicoCustomizado.nome,
      preco: parseFloat(servicoCustomizado.preco),
      quantidade: 1,
      customizado: true,
    };

    setServicosSelecionados(prev => [...prev, novoServico]);
    setServicoCustomizado({ nome: '', preco: '' });
  };

  const formatCurrency = (value) => {
    return `R$ ${value.toFixed(2).replace('.', ',')}`;
  };

  const handleCadastrar = async () => {
    if (servicosSelecionados.length === 0) {
      Alert.alert('Erro', 'Selecione pelo menos um serviço');
      return;
    }

    setLoading(true);
    try {
      const contratoData = {
        ...clienteData,
        servicos: servicosSelecionados,
        valorTotal,
        desconto,
      };

      // Aqui você faria a chamada para a API
      // await contratoService.create(contratoData);

      setTimeout(() => {
        setLoading(false);
        Alert.alert(
          'Sucesso',
          'Contrato cadastrado com sucesso!',
          [
            {
              text: 'OK',
              onPress: () => navigation.navigate('Dashboard'),
            },
          ]
        );
      }, 1000);

    } catch (error) {
      setLoading(false);
      Alert.alert('Erro', 'Erro ao cadastrar contrato. Tente novamente.');
    }
  };

  const renderServicoSelecionado = ({ item }) => (
    <View style={styles.servicoSelecionado}>
      <View style={styles.servicoInfo}>
        <Text style={styles.servicoNome}>{item.nome}</Text>
        <Text style={styles.servicoPreco}>{formatCurrency(item.preco)}</Text>
      </View>
      
      <View style={styles.quantidadeControls}>
        <TouchableOpacity
          style={styles.quantidadeButton}
          onPress={() => alterarQuantidade(item.id, item.quantidade - 1)}
        >
          <Text style={styles.quantidadeButtonText}>-</Text>
        </TouchableOpacity>
        
        <Text style={styles.quantidade}>{item.quantidade}</Text>
        
        <TouchableOpacity
          style={styles.quantidadeButton}
          onPress={() => alterarQuantidade(item.id, item.quantidade + 1)}
        >
          <Text style={styles.quantidadeButtonText}>+</Text>
        </TouchableOpacity>
      </View>
      
      <TouchableOpacity
        style={styles.removerButton}
        onPress={() => removerServico(item.id)}
      >
        <Text style={styles.removerButtonText}>🗑️</Text>
      </TouchableOpacity>
    </View>
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
        <Text style={styles.headerTitle}>{texts.servicos.title}</Text>
        <View style={styles.headerIcon}>
          <Text style={styles.headerIconText}>🎭</Text>
        </View>
      </View>

      <ScrollView style={styles.content}>
        <Text style={styles.subtitle}>
          {texts.servicos.subtitle}
        </Text>

        {/* Serviços Disponíveis */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Serviços Disponíveis</Text>
          <View style={styles.servicosGrid}>
            {servicosDisponiveis.map((servico) => (
              <TouchableOpacity
                key={servico.id}
                style={styles.servicoItem}
                onPress={() => adicionarServico(servico)}
              >
                <Text style={styles.servicoItemNome}>{servico.nome}</Text>
                <Text style={styles.servicoItemPreco}>{formatCurrency(servico.preco)}</Text>
                <Text style={styles.adicionarText}>+</Text>
              </TouchableOpacity>
            ))}
          </View>
        </View>

        {/* Adicionar Serviço Customizado */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Adicionar Serviço Customizado</Text>
          <View style={styles.customServiceContainer}>
            <TextInput
              style={styles.customInput}
              placeholder="Nome do serviço"
              value={servicoCustomizado.nome}
              onChangeText={(text) => setServicoCustomizado(prev => ({ ...prev, nome: text }))}
            />
            <TextInput
              style={styles.customInput}
              placeholder="Preço (R$)"
              value={servicoCustomizado.preco}
              onChangeText={(text) => setServicoCustomizado(prev => ({ ...prev, preco: text }))}
              keyboardType="numeric"
            />
            <TouchableOpacity
              style={styles.addCustomButton}
              onPress={adicionarServicoCustomizado}
            >
              <Text style={styles.addCustomButtonText}>Adicionar</Text>
            </TouchableOpacity>
          </View>
        </View>

        {/* Serviços Selecionados */}
        {servicosSelecionados.length > 0 && (
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Serviços Selecionados</Text>
            <FlatList
              data={servicosSelecionados}
              renderItem={renderServicoSelecionado}
              keyExtractor={(item) => item.id.toString()}
              scrollEnabled={false}
            />
          </View>
        )}

        {/* Resumo Financeiro */}
        <View style={styles.resumoContainer}>
          <View style={styles.resumoRow}>
            <Text style={styles.resumoLabel}>Subtotal:</Text>
            <Text style={styles.resumoValue}>
              {formatCurrency(servicosSelecionados.reduce((total, s) => total + (s.preco * s.quantidade), 0))}
            </Text>
          </View>

          <View style={styles.inputRow}>
            <Text style={styles.inputLabel}>{texts.servicos.desconto}:</Text>
            <TextInput
              style={styles.valueInput}
              value={desconto.toString()}
              onChangeText={(text) => setDesconto(parseFloat(text) || 0)}
              keyboardType="numeric"
              placeholder="0,00"
            />
          </View>

          <View style={styles.totalRow}>
            <Text style={styles.totalLabel}>{texts.servicos.valorTotal}:</Text>
            <Text style={styles.totalValue}>{formatCurrency(valorTotal)}</Text>
          </View>
        </View>
      </ScrollView>

      <TouchableOpacity
        style={[styles.cadastrarButton, loading && styles.buttonDisabled]}
        onPress={handleCadastrar}
        disabled={loading}
      >
        <Text style={styles.cadastrarButtonText}>
          {loading ? 'Cadastrando...' : texts.servicos.cadastrarButton}
        </Text>
      </TouchableOpacity>
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
  },
  section: {
    marginBottom: 25,
  },
  sectionTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: colors.primary,
    marginBottom: 10,
  },
  servicosGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
  },
  servicoItem: {
    width: '48%',
    backgroundColor: colors.lightGray,
    padding: 15,
    borderRadius: 8,
    marginBottom: 10,
    alignItems: 'center',
  },
  servicoItemNome: {
    fontSize: 14,
    fontWeight: 'bold',
    textAlign: 'center',
    marginBottom: 5,
  },
  servicoItemPreco: {
    fontSize: 12,
    color: colors.gray,
    marginBottom: 5,
  },
  adicionarText: {
    fontSize: 20,
    color: colors.primary,
    fontWeight: 'bold',
  },
  customServiceContainer: {
    backgroundColor: colors.lightGray,
    padding: 15,
    borderRadius: 8,
  },
  customInput: {
    borderWidth: 1,
    borderColor: colors.gray,
    borderRadius: 6,
    padding: 10,
    marginBottom: 10,
    backgroundColor: colors.white,
  },
  addCustomButton: {
    backgroundColor: colors.secondary,
    padding: 10,
    borderRadius: 6,
    alignItems: 'center',
  },
  addCustomButtonText: {
    color: colors.white,
    fontWeight: 'bold',
  },
  servicoSelecionado: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: colors.lightGray,
    padding: 15,
    borderRadius: 8,
    marginBottom: 10,
  },
  servicoInfo: {
    flex: 1,
  },
  servicoNome: {
    fontSize: 14,
    fontWeight: 'bold',
  },
  servicoPreco: {
    fontSize: 12,
    color: colors.gray,
  },
  quantidadeControls: {
    flexDirection: 'row',
    alignItems: 'center',
    marginHorizontal: 10,
  },
  quantidadeButton: {
    backgroundColor: colors.primary,
    width: 30,
    height: 30,
    borderRadius: 15,
    justifyContent: 'center',
    alignItems: 'center',
  },
  quantidadeButtonText: {
    color: colors.white,
    fontSize: 16,
    fontWeight: 'bold',
  },
  quantidade: {
    marginHorizontal: 15,
    fontSize: 16,
    fontWeight: 'bold',
  },
  removerButton: {
    padding: 10,
  },
  removerButtonText: {
    fontSize: 16,
  },
  resumoContainer: {
    backgroundColor: colors.lightGray,
    padding: 20,
    borderRadius: 8,
    marginBottom: 20,
  },
  resumoRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 10,
  },
  resumoLabel: {
    fontSize: 16,
    color: colors.darkGray,
  },
  resumoValue: {
    fontSize: 16,
    fontWeight: 'bold',
  },
  inputRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 10,
  },
  inputLabel: {
    fontSize: 16,
    color: colors.darkGray,
  },
  valueInput: {
    borderWidth: 1,
    borderColor: colors.gray,
    borderRadius: 6,
    padding: 8,
    width: 100,
    textAlign: 'right',
    backgroundColor: colors.white,
  },
  totalRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    borderTopWidth: 1,
    borderTopColor: colors.gray,
    paddingTop: 10,
  },
  totalLabel: {
    fontSize: 18,
    fontWeight: 'bold',
    color: colors.primary,
  },
  totalValue: {
    fontSize: 18,
    fontWeight: 'bold',
    color: colors.primary,
  },
  cadastrarButton: {
    backgroundColor: colors.primary,
    borderRadius: 25,
    padding: 15,
    margin: 20,
    alignItems: 'center',
  },
  buttonDisabled: {
    opacity: 0.6,
  },
  cadastrarButtonText: {
    color: colors.white,
    fontSize: 18,
    fontWeight: 'bold',
  },
});

export default ServicosScreen;