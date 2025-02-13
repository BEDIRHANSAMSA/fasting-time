export interface PrayerTime {
  Aksam: string;
  AyinSekliURL: string;
  GreenwichOrtalamaZamani: number;
  Gunes: string;
  GunesBatis: string;
  GunesDogus: string;
  HicriTarihKisa: string;
  HicriTarihKisaIso8601: string | null;
  HicriTarihUzun: string;
  HicriTarihUzunIso8601: string | null;
  Ikindi: string;
  Imsak: string;
  KibleSaati: string;
  MiladiTarihKisa: string;
  MiladiTarihKisaIso8601: string;
  MiladiTarihUzun: string;
  MiladiTarihUzunIso8601: string;
  Ogle: string;
  Yatsi: string;
}

export interface City {
  SehirAdi: string;
  SehirAdiEn: string;
  SehirID: string;
}

export interface District {
  IlceAdi: string;
  IlceAdiEn: string;
  IlceID: string;
}
