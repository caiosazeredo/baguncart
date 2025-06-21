// src/services/api.js
import axios from 'axios';

const API_BASE_URL = 'https://sua-api-url.com/api'; // Substitua pela sua URL

const api = axios.create({
  baseURL: API_BASE_URL,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Interceptor para adicionar token de autenticação
api.interceptors.request.use(
  (config) => {
    // Aqui você pode adicionar token de autenticação se necessário
    // const token = AsyncStorage.getItem('token');
    // if (token) {
    //   config.headers.Authorization = `Bearer ${token}`;
    // }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Interceptor para tratar respostas e erros
api.interceptors.response.use(
  (response) => {
    return response.data;
  },
  (error) => {
    if (error.response?.status === 401) {
      // Token expirado, redirecionar para login
      // AsyncStorage.removeItem('token');
      // NavigationService.navigate('Login');
    }
    return Promise.reject(error);
  }
);

export default api;

// src/services/authService.js
import api from './api';
import AsyncStorage from '@react-native-async-storage/async-storage';

export const authService = {
  login: async (cnpj, senha) => {
    try {
      const response = await api.post('/auth/login', {
        cnpj,
        senha,
      });
      
      if (response.token) {
        await AsyncStorage.setItem('token', response.token);
        await AsyncStorage.setItem('user', JSON.stringify(response.user));
      }
      
      return response;
    } catch (error) {
      throw error;
    }
  },

  logout: async () => {
    try {
      await AsyncStorage.removeItem('token');
      await AsyncStorage.removeItem('user');
    } catch (error) {
      console.error('Erro ao fazer logout:', error);
    }
  },

  getCurrentUser: async () => {
    try {
      const user = await AsyncStorage.getItem('user');
      return user ? JSON.parse(user) : null;
    } catch (error) {
      return null;
    }
  },

  isAuthenticated: async () => {
    try {
      const token = await AsyncStorage.getItem('token');
      return !!token;
    } catch (error) {
      return false;
    }
  },
};

// src/services/clienteService.js
import api from './api';

export const clienteService = {
  // Listar todos os clientes
  getAll: async (search = '') => {
    try {
      const response = await api.get('/clientes', {
        params: { search }
      });
      return response;
    } catch (error) {
      throw error;
    }
  },

  // Buscar cliente por ID
  getById: async (id) => {
    try {
      const response = await api.get(`/clientes/${id}`);
      return response;
    } catch (error) {
      throw error;
    }
  },

  // Criar novo cliente
  create: async (clienteData) => {
    try {
      const response = await api.post('/clientes', clienteData);
      return response;
    } catch (error) {
      throw error;
    }
  },

  // Atualizar cliente
  update: async (id, clienteData) => {
    try {
      const response = await api.put(`/clientes/${id}`, clienteData);
      return response;
    } catch (error) {
      throw error;
    }
  },

  // Deletar cliente
  delete: async (id) => {
    try {
      const response = await api.delete(`/clientes/${id}`);
      return response;
    } catch (error) {
      throw error;
    }
  },
};

// src/services/contratoService.js
import api from './api';

export const contratoService = {
  // Listar todos os contratos
  getAll: async (search = '') => {
    try {
      const response = await api.get('/contratos', {
        params: { search }
      });
      return response;
    } catch (error) {
      throw error;
    }
  },

  // Buscar contrato por ID
  getById: async (id) => {
    try {
      const response = await api.get(`/contratos/${id}`);
      return response;
    } catch (error) {
      throw error;
    }
  },

  // Criar novo contrato
  create: async (contratoData) => {
    try {
      const response = await api.post('/contratos', contratoData);
      return response;
    } catch (error) {
      throw error;
    }
  },

  // Atualizar contrato
  update: async (id, contratoData) => {
    try {
      const response = await api.put(`/contratos/${id}`, contratoData);
      return response;
    } catch (error) {
      throw error;
    }
  },

  // Buscar contratos por cliente
  getByCliente: async (clienteId) => {
    try {
      const response = await api.get(`/contratos/cliente/${clienteId}`);
      return response;
    } catch (error) {
      throw error;
    }
  },
};

// src/services/servicoService.js
import api from './api';

export const servicoService = {
  // Listar todos os serviços
  getAll: async () => {
    try {
      const response = await api.get('/servicos');
      return response;
    } catch (error) {
      throw error;
    }
  },

  // Criar novo serviço
  create: async (servicoData) => {
    try {
      const response = await api.post('/servicos', servicoData);
      return response;
    } catch (error) {
      throw error;
    }
  },

  // Atualizar serviço
  update: async (id, servicoData) => {
    try {
      const response = await api.put(`/servicos/${id}`, servicoData);
      return response;
    } catch (error) {
      throw error;
    }
  },
};

// src/services/promocaoService.js
import api from './api';

export const promocaoService = {
  // Criar nova promoção
  create: async (promocaoData) => {
    try {
      const response = await api.post('/promocoes', promocaoData);
      return response;
    } catch (error) {
      throw error;
    }
  },

  // Listar promoções
  getAll: async () => {
    try {
      const response = await api.get('/promocoes');
      return response;
    } catch (error) {
      throw error;
    }
  },

  // Buscar promoções por cliente
  getByCliente: async (clienteId) => {
    try {
      const response = await api.get(`/promocoes/cliente/${clienteId}`);
      return response;
    } catch (error) {
      throw error;
    }
  },
};

// src/services/notificacaoService.js
import api from './api';

export const notificacaoService = {
  // Enviar notificação
  enviar: async (notificacaoData) => {
    try {
      const response = await api.post('/notificacoes', notificacaoData);
      return response;
    } catch (error) {
      throw error;
    }
  },

  // Listar notificações
  getAll: async () => {
    try {
      const response = await api.get('/notificacoes');
      return response;
    } catch (error) {
      throw error;
    }
  },

  // Marcar notificação como enviada
  marcarComoEnviada: async (id) => {
    try {
      const response = await api.patch(`/notificacoes/${id}/enviada`);
      return response;
    } catch (error) {
      throw error;
    }
  },
};

// src/utils/helpers.js
export const formatCPF = (cpf) => {
  return cpf
    .replace(/\D/g, '')
    .replace(/(\d{3})(\d)/, '$1.$2')
    .replace(/(\d{3})(\d)/, '$1.$2')
    .replace(/(\d{3})(\d{1,2})/, '$1-$2')
    .replace(/(-\d{2})\d+?$/, '$1');
};

export const formatCNPJ = (cnpj) => {
  return cnpj
    .replace(/\D/g, '')
    .replace(/(\d{2})(\d)/, '$1.$2')
    .replace(/(\d{3})(\d)/, '$1.$2')
    .replace(/(\d{3})(\d)/, '$1/$2')
    .replace(/(\d{4})(\d)/, '$1-$2')
    .replace(/(-\d{2})\d+?$/, '$1');
};

export const formatCurrency = (value) => {
  return new Intl.NumberFormat('pt-BR', {
    style: 'currency',
    currency: 'BRL',
  }).format(value);
};

export const formatDate = (date) => {
  return new Date(date).toLocaleDateString('pt-BR');
};

export const validateCPF = (cpf) => {
  cpf = cpf.replace(/\D/g, '');
  
  if (cpf.length !== 11) return false;
  
  // Verifica se todos os dígitos são iguais
  if (/^(\d)\1{10}$/.test(cpf)) return false;
  
  // Validação do primeiro dígito verificador
  let soma = 0;
  for (let i = 0; i < 9; i++) {
    soma += parseInt(cpf.charAt(i)) * (10 - i);
  }
  let resto = 11 - (soma % 11);
  if (resto === 10 || resto === 11) resto = 0;
  if (resto !== parseInt(cpf.charAt(9))) return false;
  
  // Validação do segundo dígito verificador
  soma = 0;
  for (let i = 0; i < 10; i++) {
    soma += parseInt(cpf.charAt(i)) * (11 - i);
  }
  resto = 11 - (soma % 11);
  if (resto === 10 || resto === 11) resto = 0;
  if (resto !== parseInt(cpf.charAt(10))) return false;
  
  return true;
};

export const validateCNPJ = (cnpj) => {
  cnpj = cnpj.replace(/\D/g, '');
  
  if (cnpj.length !== 14) return false;
  
  // Verifica se todos os dígitos são iguais
  if (/^(\d)\1{13}$/.test(cnpj)) return false;
  
  // Validação do primeiro dígito verificador
  let tamanho = cnpj.length - 2;
  let numeros = cnpj.substring(0, tamanho);
  let digitos = cnpj.substring(tamanho);
  let soma = 0;
  let pos = tamanho - 7;
  
  for (let i = tamanho; i >= 1; i--) {
    soma += numeros.charAt(tamanho - i) * pos--;
    if (pos < 2) pos = 9;
  }
  
  let resultado = soma % 11 < 2 ? 0 : 11 - (soma % 11);
  if (resultado !== parseInt(digitos.charAt(0))) return false;
  
  // Validação do segundo dígito verificador
  tamanho = tamanho + 1;
  numeros = cnpj.substring(0, tamanho);
  soma = 0;
  pos = tamanho - 7;
  
  for (let i = tamanho; i >= 1; i--) {
    soma += numeros.charAt(tamanho - i) * pos--;
    if (pos < 2) pos = 9;
  }
  
  resultado = soma % 11 < 2 ? 0 : 11 - (soma % 11);
  if (resultado !== parseInt(digitos.charAt(1))) return false;
  
  return true;
};

// src/utils/storage.js
import AsyncStorage from '@react-native-async-storage/async-storage';

export const storage = {
  // Salvar dados
  save: async (key, value) => {
    try {
      const jsonValue = JSON.stringify(value);
      await AsyncStorage.setItem(key, jsonValue);
    } catch (error) {
      console.error('Erro ao salvar dados:', error);
    }
  },

  // Recuperar dados
  get: async (key) => {
    try {
      const jsonValue = await AsyncStorage.getItem(key);
      return jsonValue != null ? JSON.parse(jsonValue) : null;
    } catch (error) {
      console.error('Erro ao recuperar dados:', error);
      return null;
    }
  },

  // Remover dados
  remove: async (key) => {
    try {
      await AsyncStorage.removeItem(key);
    } catch (error) {
      console.error('Erro ao remover dados:', error);
    }
  },

  // Limpar todos os dados
  clear: async () => {
    try {
      await AsyncStorage.clear();
    } catch (error) {
      console.error('Erro ao limpar dados:', error);
    }
  },
};