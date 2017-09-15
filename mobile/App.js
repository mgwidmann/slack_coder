import React, { Component } from 'react';
import { Text, View } from 'react-native';
import ScrollableTabView from 'react-native-scrollable-tab-view';
import tabStyles from './app/styles/tab';
import { PRIMARY_COLOR, SECONDARY_COLOR, FOREGROUND_COLOR } from './app/styles/constants';
import PRView from './app/components/PRView'

export default class App extends React.Component {
  render() {
    return (
      <ScrollableTabView
        tabBarPosition="bottom"
        style={tabStyles.tabBarContainer}
        tabBarBackgroundColor={PRIMARY_COLOR}
        tabBarActiveTextColor={FOREGROUND_COLOR}
        tabBarUnderlineStyle={tabStyles.tabBarUnderline}
        >
        <PRView tabLabel='My PRs' />
        <PRView tabLabel='Monitors' />
        <PRView tabLabel='Hidden' />
      </ScrollableTabView>
    );
  }
}
