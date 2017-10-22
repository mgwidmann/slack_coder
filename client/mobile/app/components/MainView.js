import React from 'react';
import { View } from 'react-native';

import MenuContainer from '../containers/Menu';
import Loading from './Loading';
import Login from './Login';
import PRTabs from './PRTabs';

const MainView = ({ loggedIn, loading, loginWithToken, togglePRRow, expandedPr }) => {
  // Cannot use null/undefined to determine difference between unknown and no value
  if (loggedIn && !loading) {
    return (
      <View style={{ flex: 1 }}>
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

export default MainView;
