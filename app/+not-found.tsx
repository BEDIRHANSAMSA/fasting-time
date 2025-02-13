import { Stack, useRouter } from 'expo-router';
import { StyleSheet, Text, View, TouchableOpacity } from 'react-native';
import { useTheme } from '../context/ThemeContext';
import { Ionicons } from '@expo/vector-icons';

export default function NotFoundScreen() {
  const { isDark } = useTheme();
  const router = useRouter();

  return (
    <View style={[styles.container, { backgroundColor: isDark ? '#000' : '#fff' }]}>
      <Stack.Screen options={{ headerShown: false }} />
      
      <Ionicons 
        name="alert-circle-outline" 
        size={64} 
        color={isDark ? '#fff' : '#000'} 
        style={styles.icon}
      />
      
      <Text style={[styles.title, { color: isDark ? '#fff' : '#000' }]}>
        Oops! Page Not Found
      </Text>
      
      <Text style={[styles.subtitle, { color: isDark ? '#ccc' : '#666' }]}>
        The screen you're looking for doesn't exist.
      </Text>

      <TouchableOpacity 
        style={[styles.button, { backgroundColor: isDark ? '#fff' : '#000' }]}
        onPress={() => router.replace('/')}
      >
        <Ionicons 
          name="home-outline" 
          size={20} 
          color={isDark ? '#000' : '#fff'} 
          style={styles.buttonIcon}
        />
        <Text style={[styles.buttonText, { color: isDark ? '#000' : '#fff' }]}>
          Go to Home Screen
        </Text>
      </TouchableOpacity>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 20,
  },
  icon: {
    marginBottom: 20,
  },
  title: {
    fontSize: 24,
    fontWeight: '600',
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 16,
    textAlign: 'center',
    marginBottom: 32,
  },
  button: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 24,
    paddingVertical: 12,
    borderRadius: 30,
  },
  buttonIcon: {
    marginRight: 8,
  },
  buttonText: {
    fontSize: 16,
    fontWeight: '500',
  },
});