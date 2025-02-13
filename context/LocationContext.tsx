import React, { createContext, useContext, useState, useEffect } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { useRouter, useSegments } from 'expo-router';

interface Location {
  country: {
    id: string;
    name: string;
    code: string;
  };
  city: {
    id: string;
    name: string;
  };
  district: {
    id: string;
    name: string;
  };
}

interface LocationContextType {
  location: Location | null;
  setLocation: (location: Location) => void;
  clearLocation: () => void;
}

const LocationContext = createContext<LocationContextType | undefined>(undefined);

export function useLocation() {
  const context = useContext(LocationContext);
  if (context === undefined) {
    throw new Error('useLocation must be used within a LocationProvider');
  }
  return context;
}

export function LocationProvider({ children }: { children: React.ReactNode }) {
  const [location, setLocationState] = useState<Location | null>(null);
  const [isReady, setIsReady] = useState(false);
  const segments = useSegments();
  const router = useRouter();

  useEffect(() => {
    loadLocation();
  }, []);

  useEffect(() => {
    if (!isReady) {
      return;
    }

    const inAuthGroup = segments[0] === '(tabs)';

    if (location && !inAuthGroup) {
      router.replace('/(tabs)');
    } else if (!location && inAuthGroup) {
      router.replace('/onboarding');
    }
  }, [location, segments, isReady]);

  const loadLocation = async () => {
    try {
      const savedLocation = await AsyncStorage.getItem('user-location');
      if (savedLocation) {
        setLocationState(JSON.parse(savedLocation));
      }
    } catch (error) {
      console.error('Error loading location:', error);
    } finally {
      setIsReady(true);
    }
  };

  const setLocation = async (newLocation: Location) => {
    try {
      await AsyncStorage.setItem('user-location', JSON.stringify(newLocation));
      setLocationState(newLocation);
    } catch (error) {
      console.error('Error saving location:', error);
    }
  };

  const clearLocation = async () => {
    try {
      await AsyncStorage.removeItem('user-location');
      setLocationState(null);
    } catch (error) {
      console.error('Error clearing location:', error);
    }
  };

  return (
    <LocationContext.Provider value={{ location, setLocation, clearLocation }}>
      {isReady ? children : null}
    </LocationContext.Provider>
  );
}