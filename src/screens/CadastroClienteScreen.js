// src/screens/CadastroClienteScreen.js
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
} from 'react-native';
import { Picker } from '@react-native-picker/picker';
import DatePicker from 'react-native-date-picker';
import { colors, texts } from '../utils';

const CadastroClienteScreen = ({ navigation }) => {
  const [formData, setFormData] = useState({
    nome: '',
    cpf: '',
    endereco: '',
    numeroContrato: '',
    dataEvento: new Date(),
    formaPagamento: '',
  });
  
  const [showDatePicker, setShowDatePicker] = useState(false);
  const [loading, setLoading] = useState(false);

  const formasPagamento = [
    { label: 'Selecione uma forma de pagamento', value: '' },
    { label: texts.formasPagamento.dinheiro, value: 'dinheiro' },
    { label: texts.formasPagamento.cartaoCredito, value: 'cartao_credito' },
    { label: texts.formasPagamento.cartaoDebito, value: 'cartao_debito' },
    { label: texts.formasPagamento.pix, value: 'pix' },
    { label: texts.formasPagamento.transferencia, value: 'transferencia' },
    { label: texts.formasPagamento.cheque, value: 'cheque' },
  ];

  const formatCPF = (text) => {
    const numbers = text.replace(/\D/g, '');
    if (numbers.length <= 3) return numbers;
    if (numbers.length <= 6) return `${numbers.slice(0, 3)}.${numbers.slice(3)}`;
    if (numbers.length <= 9) return `${numbers.slice(0, 3)}.${numbers.slice(3, 6)}.${numbers.slice(6)}`;
    return `${numbers.slice(0, 3)}.${numbers.slice(3, 6)}.${numbers.slice(6, 9)}-${numbers.slice(9, 11)}`;
  };

  const validateForm = () => {
    const { nome, cpf, endereco, numeroContrato, formaPagamento } = formData;
    
    if (!nome.trim()) {
      Alert.alert('Erro', 'Nome é obrigatório');
      return false;
    }
    if (!cpf || cpf.length < 14) {
      Alert.alert('Erro', 'CPF inválido');
      return false;
    }
    if (!endereco.trim()) {
      Alert.alert('Erro', 'Endereço é obrigatório');
      return false;
    }
    if (!numeroContrato.trim()) {
      Alert.alert('Erro', 'Número do contrato é obrigatório');
      return false;
    }
    if (!formaPagamento) {
      Alert.alert('Erro', 'Forma de pagamento é obrigatória');
      return false;
    }
    
    return true;
  };

  const handleAvancar = async () => {
    if (!validateForm()) return;
    
    setLoading(true);
    try {
      // Aqui você faria a chamada para a API
      // await clienteService.create(formData);
      
      // Simular sucesso e navegar para próxima tela
      setTimeout(() => {
        setLoading(false);
        navigation.navigate('Servicos', { clienteData: formData });
      }, 1000);
      
    } catch (error) {
      setLoading(false);
      Alert.alert('Erro', 'Erro ao cadastrar cliente. Tente novamente.');
    }
  };

  const updateFormData = (field, value) => {
    setFormData(prev => ({ ...prev, [field]: value }));
  };

  const formatDate = (date) => {
    return date.toLocaleDateString('pt-BR');
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
        <Text style={styles.headerTitle}>{texts.cadastroCliente.title}</Text>
        <View style={styles.headerIcon}>
          <Text style={styles.headerIconText}>👤</Text>
        </View>
      </View>

      <ScrollView style={styles.content}>
        <Text style={styles.subtitle}>
          {texts.cadastroCliente.subtitle}
        </Text>

        <View style={styles.form}>
          <TextInput
            style={styles.input}
            placeholder={texts.cadastroCliente.nome}
            placeholderTextColor={colors.gray}
            value={formData.nome}
            onChangeText={(text) => updateFormData('nome', text)}
          />

          <TextInput
            style={styles.input}
            placeholder={texts.cadastroCliente.cpf}
            placeholderTextColor={colors.gray}
            value={formData.cpf}
            onChangeText={(text) => updateFormData('cpf', formatCPF(text))}
            keyboardType="numeric"
            maxLength={14}
          />

          <TextInput
            style={styles.input}
            placeholder={texts.cadastroCliente.endereco}
            placeholderTextColor={colors.gray}
            value={formData.endereco}
            onChangeText={(text) => updateFormData('endereco', text)}
            multiline
          />

          <TextInput
            style={styles.input}
            placeholder={texts.cadastroCliente.numeroContrato}
            placeholderTextColor={colors.gray}
            value={formData.numeroContrato}
            onChangeText={(text) => updateFormData('numeroContrato', text)}
          />

          <TouchableOpacity
            style={styles.dateInput}
            onPress={() => setShowDatePicker(true)}
          >
            <Text style={styles.dateText}>
              {formData.dataEvento ? 
                `${texts.cadastroCliente.dataEvento}: ${formatDate(formData.dataEvento)}` : 
                texts.cadastroCliente.dataEvento
              }
            </Text>
          </TouchableOpacity>

          <View style={styles.pickerContainer}>
            <Picker
              selectedValue={formData.formaPagamento}
              style={styles.picker}
              onValueChange={(itemValue) => updateFormData('formaPagamento', itemValue)}
            >
              {formasPagamento.map((forma, index) => (
                <Picker.Item 
                  key={index} 
                  label={forma.label} 
                  value={forma.value}
                />
              ))}
            </Picker>
          </View>
        </View>
      </ScrollView>

      <TouchableOpacity
        style={[styles.avancarButton, loading && styles.buttonDisabled]}
        onPress={handleAvancar}
        disabled={loading}
      >
        <Text style={styles.avancarButtonText}>
          {loading ? 'Processando...' : texts.cadastroCliente.avancarButton}
        </Text>
      </TouchableOpacity>

      <DatePicker
        modal
        open={showDatePicker}
        date={formData.dataEvento}
        mode="date"
        locale="pt-BR"
        title="Selecionar Data do Evento"
        confirmText="Confirmar"
        cancelText="Cancelar"
        minimumDate={new Date()}
        onConfirm={(date) => {
          setShowDatePicker(false);
          updateFormData('dataEvento', date);
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
    color: colors.primary,
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
  input: {
    borderWidth: 1,
    borderColor: colors.gray,
    borderRadius: 8,
    padding: 15,
    marginBottom: 15,
    fontSize: 16,
    backgroundColor: colors.lightGray,
  },
  dateInput: {
    borderWidth: 1,
    borderColor: colors.gray,
    borderRadius: 8,
    padding: 15,
    marginBottom: 15,
    backgroundColor: colors.lightGray,
  },
  dateText: {
    fontSize: 16,
    color: colors.darkGray,
  },
  pickerContainer: {
    borderWidth: 1,
    borderColor: colors.gray,
    borderRadius: 8,
    marginBottom: 15,
    backgroundColor: colors.lightGray,
  },
  picker: {
    height: 50,
  },
  avancarButton: {
    backgroundColor: colors.primary,
    borderRadius: 25,
    padding: 15,
    margin: 20,
    alignItems: 'center',
  },
  buttonDisabled: {
    opacity: 0.6,
  },
  avancarButtonText: {
    color: colors.white,
    fontSize: 18,
    fontWeight: 'bold',
  },
});

export default CadastroClienteScreen;