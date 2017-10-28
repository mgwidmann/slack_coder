import React from 'react';
import { View, StyleSheet } from 'react-native';

import MenuContainer from '../containers/Menu';
import Loading from './general/Loading';
import Login from './general/Login';
import PRTabs from './pr/PRTabs';
import ConnectionStatus from './general/ConnectionStatus';

const MainView = ({ loggedIn, loading, offline, reconnecting, loginWithToken, togglePRRow, expandedPr, navigation }) => {
  if (loggedIn && !loading) {
    return (
      <View style={styles.mainContainer}>
        <ConnectionStatus offline={offline} reconnecting={reconnecting} />
        <PRTabs togglePRRow={togglePRRow} expandedPr={expandedPr} />
        <MenuContainer navigation={navigation} />
      </View>
    )
  } else if (loading) {
    return <Loading />;
  } else {
    return <Login loginWithToken={loginWithToken} />
  }
}

const styles = StyleSheet.create({
  mainContainer: {
    flex: 1,
    paddingTop: 20
  }
});

export default MainView;
