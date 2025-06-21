// src/screens/DashboardScreen.js
import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  SafeAreaView,
  ScrollView,
  Dimensions,
} from 'react-native';
import { colors, texts } from '../utils';

const { width } = Dimensions.get('window');

const DashboardScreen = ({ navigation }) => {
  const [diasRestantes, setDiasRestantes] = useState(15);
  const [proximoEvento, setProximoEvento] = useState('01/01/25');

  const menuItems = [
    {
      id: 1,
      title: texts.menu.clientes,
      icon: '👥',
      screen: 'Clientes',
      color: colors.secondary,
    },
    {
      id: 2,
      title: texts.menu.contratos,
      icon: '📋',
      screen: 'Contratos',
      color: colors.secondary,
    },
    {
      id: 3,
      title: texts.menu.promocao,
      icon: '📢',
      screen: 'Promocao',
      color: colors.secondary,
    },
    {
      id: 4,
      title: texts.menu.cadastrarCliente,
      icon: '👤',
      screen: 'CadastroCliente',
      color: colors.secondary,
    },
    {
      id: 5,
      title: texts.menu.notificacao,
      icon: '🔔',
      screen: 'Notificacao',
      color: colors.secondary,
    },
  ];

  const handleMenuPress = (screen) => {
    navigation.navigate(screen);
  };

  const calculateDaysRemaining = () => {
    // Lógica para calcular dias restantes até o próximo evento
    const today = new Date();
    const eventDate = new Date('2025-01-01');
    const diffTime = eventDate - today;
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    return diffDays > 0 ? diffDays : 0;
  };

  useEffect(() => {
    setDiasRestantes(calculateDaysRemaining());
  }, []);

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView contentContainerStyle={styles.scrollContainer}>
        {/* Header */}
        <View style={styles.header}>
          <Text style={styles.logoText}>BagunçArt</Text>
          <Text style={styles.userRole}>{texts.dashboard.administrator}</Text>
        </View>

        {/* Welcome Section */}
        <View style={styles.welcomeSection}>
          <Text style={styles.welcomeText}>
            {texts.dashboard.welcomeMessage}
          </Text>
          <Text style={styles.companyName}>
            {texts.dashboard.baguncartEventos}
          </Text>
          
          <View style={styles.countdownContainer}>
            <Text style={styles.daysNumber}>{diasRestantes}</Text>
            <Text style={styles.daysText}>{texts.dashboard.daysRemaining}</Text>
          </View>
          
          <Text style={styles.bestDayText}>
            {texts.dashboard.bestDay}
          </Text>
          
          <View style={styles.specialDayContainer}>
            <Text style={styles.specialDayLabel}>
              {texts.dashboard.specialDay}
            </Text>
            <Text style={styles.specialDayDate}>{proximoEvento}</Text>
          </View>
        </View>

        {/* Menu Grid */}
        <View style={styles.menuContainer}>
          <View style={styles.menuRow}>
            {menuItems.slice(0, 3).map((item) => (
              <TouchableOpacity
                key={item.id}
                style={[styles.menuItem, { backgroundColor: item.color }]}
                onPress={() => handleMenuPress(item.screen)}
              >
                <Text style={styles.menuIcon}>{item.icon}</Text>
                <Text style={styles.menuText}>{item.title}</Text>
              </TouchableOpacity>
            ))}
          </View>
          
          <View style={styles.menuRow}>
            {menuItems.slice(3, 5).map((item) => (
              <TouchableOpacity
                key={item.id}
                style={[styles.menuItem, { backgroundColor: item.color }]}
                onPress={() => handleMenuPress(item.screen)}
              >
                <Text style={styles.menuIcon}>{item.icon}</Text>
                <Text style={styles.menuText}>{item.title}</Text>
              </TouchableOpacity>
            ))}
            {/* Item vazio para manter o layout */}
            <View style={styles.emptyItem} />
          </View>
        </View>

        {/* Social Media Footer */}
        <View style={styles.socialContainer}>
          <TouchableOpacity style={styles.socialButton}>
            <Text style={styles.socialIcon}>📱</Text>
          </TouchableOpacity>
          <TouchableOpacity style={styles.socialButton}>
            <Text style={styles.socialIcon}>📷</Text>
          </TouchableOpacity>
          <TouchableOpacity style={styles.socialButton}>
            <Text style={styles.socialIcon}>👍</Text>
          </TouchableOpacity>
          <TouchableOpacity style={styles.socialButton}>
            <Text style={styles.socialIcon}>▶️</Text>
          </TouchableOpacity>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.white,
  },
  scrollContainer: {
    flexGrow: 1,
  },
  header: {
    alignItems: 'center',
    paddingVertical: 20,
    paddingHorizontal: 20,
  },
  logoText: {
    fontSize: 28,
    fontWeight: 'bold',
    color: colors.primary,
    marginBottom: 5,
  },
  userRole: {
    fontSize: 16,
    color: colors.gray,
    alignSelf: 'flex-start',
  },
  welcomeSection: {
    backgroundColor: colors.primary,
    paddingVertical: 30,
    paddingHorizontal: 20,
    alignItems: 'center',
    marginHorizontal: 20,
    borderRadius: 15,
    marginBottom: 30,
  },
  welcomeText: {
    color: colors.white,
    fontSize: 16,
    textAlign: 'center',
    marginBottom: 5,
  },
  companyName: {
    color: colors.secondary,
    fontSize: 18,
    fontWeight: 'bold',
    textAlign: 'center',
    marginBottom: 20,
  },
  countdownContainer: {
    alignItems: 'center',
    marginBottom: 15,
  },
  daysNumber: {
    color: colors.secondary,
    fontSize: 48,
    fontWeight: 'bold',
  },
  daysText: {
    color: colors.white,
    fontSize: 16,
    fontWeight: 'bold',
  },
  bestDayText: {
    color: colors.white,
    fontSize: 14,
    textAlign: 'center',
    marginBottom: 20,
  },
  specialDayContainer: {
    alignItems: 'center',
  },
  specialDayLabel: {
    color: colors.white,
    fontSize: 16,
    fontWeight: 'bold',
  },
  specialDayDate: {
    color: colors.white,
    fontSize: 14,
  },
  menuContainer: {
    paddingHorizontal: 20,
    marginBottom: 30,
  },
  menuRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 20,
  },
  menuItem: {
    width: (width - 60) / 3,
    height: 100,
    borderRadius: 10,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 10,
  },
  menuIcon: {
    fontSize: 24,
    marginBottom: 5,
  },
  menuText: {
    color: colors.white,
    fontSize: 12,
    fontWeight: 'bold',
    textAlign: 'center',
  },
  emptyItem: {
    width: (width - 60) / 3,
  },
  socialContainer: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    paddingHorizontal: 20,
    paddingVertical: 20,
    backgroundColor: colors.secondary,
  },
  socialButton: {
    width: 50,
    height: 50,
    backgroundColor: colors.white,
    borderRadius: 8,
    justifyContent: 'center',
    alignItems: 'center',
  },
  socialIcon: {
    fontSize: 20,
  },
});

export default DashboardScreen;