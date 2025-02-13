import { createStackNavigator } from '@react-navigation/stack';
import CountryScreen from './country';
import CityScreen from './city';
import DistrictScreen from './district';

const Stack = createStackNavigator();

export default function LocationLayout() {
  return (
    <Stack.Navigator screenOptions={{ headerShown: false }}>
      <Stack.Screen name="country" component={CountryScreen} />
      <Stack.Screen name="city" component={CityScreen} />
      <Stack.Screen name="district" component={DistrictScreen} />
    </Stack.Navigator>
  );
}
