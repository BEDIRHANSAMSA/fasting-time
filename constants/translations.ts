const translations = {
  en: {
    // App Info
    appName: 'Fasting Times',
    appDescription: 'Track daily fasting times for your location',

    // Location Detection
    detectingLocation: 'Detecting your location...',
    locationDetected: 'Location Detected',
    locationConfirmMessage:
      'We detected you are in {district}, {city}. Is this correct?',
    locationConfirmCityMessage:
      'We detected you are in {city}. Is this correct?',
    locationError: 'Location Error',
    locationErrorMessage:
      'Could not detect your location. Please select manually.',
    locationPermissionDenied: 'Location Permission Denied',
    locationPermissionMessage:
      'We need location permission to detect your location. Please select manually.',
    detectLocation: 'Detect My Location',
    selectManually: 'Select Location Manually',
    yes: 'Yes',
    no: 'No',
    ok: 'OK',

    continue: 'Continue',

    selectCountry: 'Select Your Country',
    selectCountrySub: 'Continue by selecting your country',
    searchCountry: 'Search country...',

    // Settings
    settings: 'Settings',
    language: 'Language',
    turkish: 'Turkish',
    english: 'English',
    location: 'Location',
    changeLocation: 'Change Location',
    appearance: 'Appearance',
    darkMode: 'Dark Mode',
  },
  tr: {
    // Uygulama Bilgisi
    appName: 'Oruç Vakitleri',
    appDescription: 'Bulunduğunuz yerin günlük oruç vakitlerini takip edin',

    // Konum Tespiti
    detectingLocation: 'Konumunuz tespit ediliyor...',
    locationDetected: 'Konum Tespit Edildi',
    locationConfirmMessage:
      'Konumunuz {district}, {city} olarak tespit edildi. Doğru mu?',
    locationConfirmCityMessage:
      'Konumunuz  {city} olarak tespit edildi. Doğru mu?',

    locationError: 'Konum Hatası',
    locationErrorMessage:
      'Konumunuz tespit edilemedi. Lütfen manuel olarak seçin.',
    locationPermissionDenied: 'Konum İzni Reddedildi',
    locationPermissionMessage:
      'Konumunuzu tespit etmek için izne ihtiyacımız var. Lütfen manuel olarak seçin.',
    detectLocation: 'Konumumu Tespit Et',
    selectManually: 'Manuel Olarak Seç',
    yes: 'Evet',
    no: 'Hayır',
    ok: 'Tamam',

    continue: 'Devam et',
    selectCountry: 'Ülkeni Seç',
    selectCountrySub: 'Bulunduğun ülkeyi seçerek devam et',
    searchCountry: 'Ülke ara...',

    // Ayarlar
    settings: 'Ayarlar',
    language: 'Dil',
    turkish: 'Türkçe',
    english: 'İngilizce',
    location: 'Konum',
    changeLocation: 'Konumu Değiştir',
    appearance: 'Görünüm',
    darkMode: 'Karanlık Mod',
  },
} as const;

export default translations;
