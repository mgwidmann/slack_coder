import { StackNavigator } from 'react-navigation';

import MainScreen from './screens/MainScreen';
import SettingsScreen from './screens/SettingsScreen';

const Router = StackNavigator({
  Main: {
    screen: MainScreen,
    path: '',
    navigationOptions: {
      header: null,
    }
  },
  Settings: {
    screen: SettingsScreen,
    path: 'settings',
    headerMode: 'screen',
  },
}, {
  initialRouteName: 'Main',
  cardStyle: {
    backgroundColor: 'white',
  }
});

export default Router;