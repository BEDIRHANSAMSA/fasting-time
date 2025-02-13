import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { NavigationContainer } from '@react-navigation/native';
import { ThemeProvider } from '../context/ThemeContext';
import { LocationProvider } from '../context/LocationContext';
import DashboardScreen from './dashboard';
import OnboardingScreen from './onboarding';
import LocationLayout from './location/_layout';
import { createStackNavigator } from '@react-navigation/stack';
import SettingsScreen from './settings';
import { PrayerTimesProvider } from '../context/PrayerTimesContext';
import '../localization/i18n';

const Stack = createStackNavigator();

export default function RootLayout() {
  return (
    <ThemeProvider>
      <LocationProvider>
        <PrayerTimesProvider>
          <Stack.Navigator screenOptions={{ headerShown: false }}>
            <Stack.Screen name="dashboard" component={DashboardScreen} />
            <Stack.Screen name="settings" component={SettingsScreen} />
            <Stack.Screen name="onboarding" component={OnboardingScreen} />
            <Stack.Screen name="location" component={LocationLayout} />
          </Stack.Navigator>
        </PrayerTimesProvider>
      </LocationProvider>
    </ThemeProvider>
  );
}
