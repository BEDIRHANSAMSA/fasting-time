import React, { createContext, useContext, useState, useEffect } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { PrayerTime } from '../types/api';

interface PrayerTimesContextType {
  prayerTimes: PrayerTime[] | null;
  loading: boolean;
  error: string | null;
  fetchPrayerTimes: (districtId: string) => Promise<void>;
}

const PrayerTimesContext = createContext<PrayerTimesContextType | undefined>(undefined);

export function usePrayerTimes() {
  const context = useContext(PrayerTimesContext);
  if (context === undefined) {
    throw new Error('usePrayerTimes must be used within a PrayerTimesProvider');
  }
  return context;
}

export function PrayerTimesProvider({ children }: { children: React.ReactNode }) {
  const [prayerTimes, setPrayerTimes] = useState<PrayerTime[] | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    loadStoredPrayerTimes();
  }, []);

  const loadStoredPrayerTimes = async () => {
    try {
      const storedTimes = await AsyncStorage.getItem('prayer-times');
      if (storedTimes) {
        const { times, timestamp } = JSON.parse(storedTimes);
        const today = new Date().toISOString().split('T')[0];
        const storedDate = new Date(timestamp).toISOString().split('T')[0];

        // Only use stored times if they're from today
        if (today === storedDate) {
          setPrayerTimes(times);
        }
      }
    } catch (error) {
      console.error('Error loading prayer times:', error);
    }
  };

  const fetchPrayerTimes = async (districtId: string) => {
    try {
      setLoading(true);
      setError(null);

      const response = await fetch(`https://ezanvakti.emushaf.net/vakitler/${districtId}`);
      if (!response.ok) {
        throw new Error('Failed to fetch prayer times');
      }

      const data = await response.json();
      setPrayerTimes(data);

      // Store the times with current timestamp
      await AsyncStorage.setItem('prayer-times', JSON.stringify({
        times: data,
        timestamp: new Date().toISOString()
      }));
    } catch (err) {
      setError('Failed to load prayer times. Please try again.');
      console.error('Error fetching prayer times:', err);
    } finally {
      setLoading(false);
    }
  };

  return (
    <PrayerTimesContext.Provider value={{ prayerTimes, loading, error, fetchPrayerTimes }}>
      {children}
    </PrayerTimesContext.Provider>
  );
}