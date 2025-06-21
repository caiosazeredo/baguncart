// src/navigation/AppNavigator.js
import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';

// Importar suas telas
import LoginScreen from '../screens/LoginScreen';
import DashboardScreen from '../screens/DashboardScreen';
import CadastroClienteScreen from '../screens/CadastroClienteScreen';
import ServicosScreen from '../screens/ServicosScreen';
import ClientesScreen from '../screens/ClientesScreen';
import ContratosScreen from '../screens/ContratosScreen';
import PromocaoScreen from '../screens/PromocaoScreen';
import NotificacaoScreen from '../screens/NotificacaoScreen';

const Stack = createStackNavigator();

const AppNavigator = () => {
  return (
    <NavigationContainer>
      <Stack.Navigator
        initialRouteName="Login"
        screenOptions={{
          headerShown: false, // Esconder header padrão
          gestureEnabled: true,
        }}
      >
        <Stack.Screen name="Login" component={LoginScreen} />
        <Stack.Screen name="Dashboard" component={DashboardScreen} />
        <Stack.Screen name="CadastroCliente" component={CadastroClienteScreen} />
        <Stack.Screen name="Servicos" component={ServicosScreen} />
        <Stack.Screen name="Clientes" component={ClientesScreen} />
        <Stack.Screen name="Contratos" component={ContratosScreen} />
        <Stack.Screen name="Promocao" component={PromocaoScreen} />
        <Stack.Screen name="Notificacao" component={NotificacaoScreen} />
      </Stack.Navigator>
    </NavigationContainer>
  );
};

export default AppNavigator;

// App.js (arquivo principal)
import React from 'react';
import { StatusBar } from 'react-native';
import AppNavigator from './src/navigation/AppNavigator';
import { colors } from './src/utils/colors';

const App = () => {
  return (
    <>
      <StatusBar backgroundColor={colors.primary} barStyle="light-content" />
      <AppNavigator />
    </>
  );
};

export default App;