import { StackRouter } from 'react-navigation';

import MainScreen from './screens/MainScreen';
import SettingsScreen from './screens/SettingsScreen';

const Router = StackRouter({
  Main: {
    screen: MainScreen,
  },
  Settings: {
    screen: SettingsScreen,
    path: 'settings',
  },
});

export default Router;