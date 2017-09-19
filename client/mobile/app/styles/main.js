import { StyleSheet } from 'react-native';
import { PRIMARY_COLOR, SECONDARY_COLOR } from './constants';


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
    backgroundColor: PRIMARY_COLOR,
  },
  loginText: {
    fontSize: 36,
  },
  logo: {
    width: 250,
    height: 250,
  },
  logoWithScanner: {
    marginTop: 300,
  },
  scanner: {
    width: '100%',
    height: 300
  }
});
