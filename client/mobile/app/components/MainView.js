import React from 'react';
import { View, StyleSheet } from 'react-native';

import MenuContainer from '../containers/Menu';
import Loading from './Loading';
import Login from './Login';
import PRTabs from './PRTabs';
import ConnectionStatus from './ConnectionStatus';

const MainView = ({ loggedIn, loading, offline, reconnecting, loginWithToken, togglePRRow, expandedPr }) => {
  if (loggedIn && !loading) {
    return (
      <View style={styles.mainContainer}>
        <ConnectionStatus offline={offline} reconnecting={reconnecting} />
        <PRTabs togglePRRow={togglePRRow} expandedPr={expandedPr} />
        <MenuContainer/>
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
