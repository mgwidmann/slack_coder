import { StyleSheet } from 'react-native';
import { PRIMARY_COLOR, SECONDARY_COLOR, FOREGROUND_COLOR } from './constants';


export default tabStyles = StyleSheet.create({
  tabBarContainer: {
    marginTop: 20
  },
  tabBarUnderline: {
    backgroundColor: SECONDARY_COLOR
  },
  loginContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  main: {
    backgroundColor: PRIMARY_COLOR
  },
  secondary: {
    backgroundColor: FOREGROUND_COLOR
  },
  loginText: {
    fontSize: 36,
    textAlign: 'center'
  },
  loginSubText: {
    fontSize: 24,
    textAlign: 'center',
    color: 'gray'
  },
  logo: {
    width: 125,
    height: 125,
  },
  devTokenInput: {
    height: 40,
    width: 250,
    backgroundColor: 'white',
    borderColor: 'gray',
    borderWidth: 1
  }
});
