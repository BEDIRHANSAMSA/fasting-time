import React, { useEffect, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  ActivityIndicator,
  Dimensions,
  SafeAreaView,
  ScrollView,
} from 'react-native';
import { useRouter, Redirect } from 'expo-router';
import { useTheme } from '../context/ThemeContext';
import { useLocation } from '../context/LocationContext';
import { usePrayerTimes } from '../context/PrayerTimesContext';
import { Ionicons } from '@expo/vector-icons';
import { toTitleCaseUTF8 } from '../utils/string';
import dayjs from 'dayjs';
import relativeTime from 'dayjs/plugin/relativeTime';
import locale_en from 'dayjs/locale/en';
import locale_tr from 'dayjs/locale/tr';
import { useTranslation } from 'react-i18next';
import updateLocale from 'dayjs/plugin/updateLocale';
import durationPlugin from 'dayjs/plugin/duration'; // Plugin'i ekle

dayjs.extend(updateLocale);
dayjs.extend(relativeTime);
dayjs.extend(durationPlugin);

// Yeni threshold'ları tanımlıyoruz
const thresholds = [
  { l: 's', r: 59, d: 'second' }, // 59 saniyeye kadar "x saniye önce" göster
  { l: 'm', r: 1 }, // 1 dakikaya kadar "bir dakika önce"
  { l: 'mm', r: 59, d: 'minute' }, // 59 dakikaya kadar "x dakika önce"
  { l: 'h', r: 1 }, // 1 saate kadar "bir saat önce"
  { l: 'hh', r: 23, d: 'hour' }, // 23 saate kadar "x saat önce"
  { l: 'd', r: 1 }, // 1 güne kadar "dün"
  { l: 'dd', r: 29, d: 'day' }, // 29 güne kadar "x gün önce"
  { l: 'M', r: 1 }, // 1 aya kadar "geçen ay"
  { l: 'MM', r: 11, d: 'month' }, // 11 aya kadar "x ay önce"
  { l: 'y', r: 1 }, // 1 yıla kadar "geçen yıl"
  { l: 'yy', d: 'year' }, // Daha büyük zamanlar için "x yıl önce"
];

// Eşikleri ayarla
dayjs.extend(relativeTime, { thresholds });

function getFlagEmoji(countryCode: string) {
  const codePoints = countryCode
    .toUpperCase()
    .split('')
    .map((char) => 127397 + char.charCodeAt(0));
  return String.fromCodePoint(...codePoints);
}

function calculateRemainingTime(
  prayerTime: string,
  lang: string,
  isTomorrow = false
) {
  const [hours, minutes] = prayerTime.split(':').map(Number);
  const prayerDate = new Date();
  if (isTomorrow) {
    prayerDate.setDate(prayerDate.getDate() + 1);
  }

  prayerDate.setHours(hours, minutes, 0, 0);

  return dayjs(prayerDate)
    .locale(lang === 'tr' ? locale_tr : locale_en)
    .fromNow(true);
}

const Header = ({ isDark, onSettingsPress }: any) => (
  <View style={styles.header}>
    <TouchableOpacity style={styles.settingsButton} onPress={onSettingsPress}>
      <Ionicons
        name="settings-outline"
        size={24}
        color={isDark ? '#fff' : '#000'}
      />
    </TouchableOpacity>
  </View>
);

const LocationInfo = ({ location, isDark }: any) => (
  <View
    style={[styles.card, { backgroundColor: isDark ? '#1a1a1a' : '#f5f5f5' }]}
  >
    <View style={styles.locationHeader}>
      <Text style={styles.flag}>{getFlagEmoji(location.country.code)}</Text>
      <View>
        <Text
          style={[styles.locationTitle, { color: isDark ? '#fff' : '#000' }]}
        >
          {toTitleCaseUTF8(location.district.name)}
        </Text>
        <Text
          style={[styles.locationSubtitle, { color: isDark ? '#ccc' : '#666' }]}
        >
          {toTitleCaseUTF8(location.city.name)}, {location.country.name}
        </Text>
      </View>
    </View>
  </View>
);

const PrayerTimes = ({ todaysPrayers, isDark }: any) => (
  <SafeAreaView
    style={[styles.card, { backgroundColor: isDark ? '#1a1a1a' : '#f5f5f5' }]}
  >
    <View style={styles.prayerHeader}>
      <Text style={[styles.prayerDate, { color: isDark ? '#fff' : '#000' }]}>
        {todaysPrayers.MiladiTarihUzun}
      </Text>
      <Text style={[styles.hijriDate, { color: isDark ? '#ccc' : '#666' }]}>
        {todaysPrayers.HicriTarihUzun}
      </Text>
    </View>

    <View style={styles.prayerTimesGrid}>
      <PrayerTimeCard
        icon="sunny-outline"
        name="İmsak"
        time={todaysPrayers.Imsak}
        isDark={isDark}
      />
      <PrayerTimeCard
        icon="partly-sunny-outline"
        name="Güneş"
        time={todaysPrayers.Gunes}
        isDark={isDark}
      />
      <PrayerTimeCard
        icon="sunny"
        name="Öğle"
        time={todaysPrayers.Ogle}
        isDark={isDark}
      />
      <PrayerTimeCard
        icon="partly-sunny"
        name="İkindi"
        time={todaysPrayers.Ikindi}
        isDark={isDark}
      />
      <PrayerTimeCard
        icon="cloudy-night-outline"
        name="Akşam"
        time={todaysPrayers.Aksam}
        isDark={isDark}
      />
      <PrayerTimeCard
        icon="moon-outline"
        name="Yatsı"
        time={todaysPrayers.Yatsi}
        isDark={isDark}
      />
    </View>
  </SafeAreaView>
);

const PrayerTimeCard = ({ icon, name, time, isDark }: any) => (
  <View style={styles.prayerTimeItem}>
    <View
      style={[
        styles.prayerTimeCard,
        { backgroundColor: isDark ? '#333' : '#fff' },
      ]}
    >
      <Ionicons name={icon} size={24} color={isDark ? '#fff' : '#000'} />
      <Text style={[styles.prayerName, { color: isDark ? '#fff' : '#000' }]}>
        {name}
      </Text>
      <Text style={[styles.prayerTime, { color: isDark ? '#fff' : '#000' }]}>
        {time}
      </Text>
    </View>
  </View>
);

const RemainingTimeCard = ({
  prayerTimes,
  todaysPrayers,
  today,
  i18n,
  t,
  isDark,
}: any) => {
  const [remainingTime, setRemainingTime] = useState<string | null>(null);
  const [remainingTitle, setRemainingTitle] = useState<string | null>(null);

  useEffect(() => {
    let interval: NodeJS.Timeout;

    const updateCountdown = () => {
      if (!todaysPrayers || !prayerTimes) return;

      const now = dayjs();
      let targetTime: dayjs.Dayjs;

      // Aksam vaktini al
      const [hours, minutes] = todaysPrayers.Aksam.split(':').map(Number);
      const aksamTime = dayjs(today).hour(hours).minute(minutes).second(0);

      if (now.isAfter(aksamTime)) {
        // Eğer Aksam geçtiyse, ertesi günün İmsak vaktine geç
        const tomorrow = dayjs(today).add(1, 'day');
        const tomorrowPrayers = prayerTimes.find(
          (time: any) =>
            time.MiladiTarihUzunIso8601.split('T')[0] ===
            tomorrow.format('YYYY-MM-DD')
        );

        if (tomorrowPrayers) {
          const [imsakHours, imsakMinutes] =
            tomorrowPrayers.Imsak.split(':').map(Number);
          targetTime = tomorrow.hour(imsakHours).minute(imsakMinutes).second(0);

          setRemainingTitle(t('remainingTimeToFajr'));
        } else {
          return;
        }
      } else {
        targetTime = aksamTime;
        setRemainingTitle(t('remainingTimeToMaghrib'));
      }

      const timeDiff = targetTime.diff(now);
      setRemainingTime(formatTime(timeDiff));
    };

    updateCountdown();
    interval = setInterval(updateCountdown, 1000);

    return () => clearInterval(interval);
  }, [todaysPrayers, prayerTimes, today, i18n.language, t]);

  return (
    <View
      style={[
        styles.card,
        {
          backgroundColor: isDark ? '#1a1a1a' : '#f5f5f5',
          justifyContent: 'center',
          alignItems: 'center',
        },
      ]}
    >
      <Text style={[styles.prayerName, { color: isDark ? '#fff' : '#000' }]}>
        {remainingTitle}
      </Text>
      <Text style={[styles.prayerTime, { color: isDark ? '#fff' : '#000' }]}>
        {remainingTime}
      </Text>
    </View>
  );
};

const formatTime = (milliseconds: number) => {
  const timeDuration = dayjs.duration(milliseconds);
  return `${String(timeDuration.hours()).padStart(2, '0')}:${String(
    timeDuration.minutes()
  ).padStart(2, '0')}:${String(timeDuration.seconds()).padStart(2, '0')}`;
};

export default function DashboardScreen() {
  const { isDark } = useTheme();
  const { location } = useLocation();
  const { prayerTimes, loading, error } = usePrayerTimes();
  const router = useRouter();
  const { t, i18n } = useTranslation();

  if (!location) {
    return <Redirect href="/onboarding" />;
  }

  const today = new Date().toISOString().split('T')[0];
  const todaysPrayers = prayerTimes?.find(
    (time) => time.MiladiTarihUzunIso8601.split('T')[0] === today
  );

  return (
    <SafeAreaView
      style={[styles.container, { backgroundColor: isDark ? '#000' : '#fff' }]}
    >
      <Header
        isDark={isDark}
        onSettingsPress={() => router.push('/settings')}
      />

      <ScrollView contentContainerStyle={styles.content}>
        <LocationInfo location={location} isDark={isDark} />

        {loading ? (
          <View
            style={[
              styles.card,
              styles.centered,
              { backgroundColor: isDark ? '#1a1a1a' : '#f5f5f5' },
            ]}
          >
            <ActivityIndicator size="large" color={isDark ? '#fff' : '#000'} />
          </View>
        ) : error ? (
          <View
            style={[
              styles.card,
              { backgroundColor: isDark ? '#1a1a1a' : '#f5f5f5' },
            ]}
          >
            <Text
              style={[
                styles.errorText,
                { color: isDark ? '#ff6b6b' : '#dc3545' },
              ]}
            >
              {error}
            </Text>
          </View>
        ) : todaysPrayers ? (
          <>
            <RemainingTimeCard
              prayerTimes={prayerTimes}
              todaysPrayers={todaysPrayers}
              today={today}
              i18n={i18n}
              t={t}
              isDark={isDark}
            />

            <PrayerTimes todaysPrayers={todaysPrayers} isDark={isDark} />
          </>
        ) : null}
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'flex-end',
  },
  headerTitle: {
    fontSize: 32,
    fontWeight: 'bold',
  },
  settingsButton: {
    width: 40,
    height: 40,
    borderRadius: 20,
    alignItems: 'center',
    justifyContent: 'center',
  },
  content: {
    flexGrow: 1,
    padding: 20,
    gap: 20,
  },
  card: {
    padding: 20,
    borderRadius: 16,
  },
  centered: {
    alignItems: 'center',
    justifyContent: 'center',
    minHeight: 200,
  },
  locationHeader: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  flag: {
    fontSize: 24,
    marginRight: 12,
  },
  locationTitle: {
    fontSize: 20,
    fontWeight: 'bold',
  },
  locationSubtitle: {
    fontSize: 14,
    marginTop: 2,
  },
  errorText: {
    fontSize: 16,
    textAlign: 'center',
  },
  prayerHeader: {
    marginBottom: 20,
  },
  prayerDate: {
    fontSize: 18,
    fontWeight: '600',
    marginBottom: 4,
  },
  hijriDate: {
    fontSize: 14,
  },
  prayerTimesGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 12,
  },
  prayerTimeItem: {
    width: '48%',
    marginBottom: 12,
  },
  prayerTimeCard: {
    padding: 16,
    borderRadius: 12,
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 3.84,
    elevation: 5,
  },
  prayerName: {
    fontSize: 16,
    fontWeight: '500',
    marginTop: 8,
  },
  prayerTime: {
    fontSize: 20,
    fontWeight: 'bold',
    marginTop: 4,
  },
});
