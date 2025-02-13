import { useLocation } from '@/context/LocationContext';
import { Redirect } from 'expo-router';

export default function Index() {
  const { location } = useLocation();

  if (!location) return <Redirect href="/onboarding" />;
}
