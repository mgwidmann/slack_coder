import { StackNavigator } from 'react-navigation';

import MainScreen from './screens/MainScreen';
import SettingsScreen from './screens/SettingsScreen';

const Router = StackNavigator({
  Main: {
    screen: MainScreen,
    path: '',
  },
  Settings: {
    screen: SettingsScreen,
    path: 'settings',
  },
}, {
  initialRouteName: 'Main',
  headerMode: 'none',
  cardStyle: {
    backgroundColor: 'white',
  }
});

export default Router;