import React from 'react';
import { View, Text } from 'react-native';
import ScrollableTabView from 'react-native-scrollable-tab-view';

import { PRIMARY_COLOR, SECONDARY_COLOR, FOREGROUND_COLOR } from '../styles/constants';
import mainStyles from '../styles/main';
import prStyles from '../styles/pullRequests';
import MineOpenPRs from './pr/MineOpenPRs';
import MonitorsOpenPRs from './pr/MonitorsOpenPRs';


const PRTabs = ({ togglePRRow, expandedPr }) => {
  return (
    <ScrollableTabView
      tabBarPosition="bottom"
      style={mainStyles.tabBarContainer}
      tabBarBackgroundColor={PRIMARY_COLOR}
      tabBarActiveTextColor={FOREGROUND_COLOR}
      tabBarUnderlineStyle={mainStyles.tabBarUnderline}
      >
      <MineOpenPRs tabLabel='Main' tab='mine' togglePRRow={togglePRRow} expandedPr={expandedPr}>
        <View style={[prStyles.emptyView]}>
          <Text style={[prStyles.emptyMainText]}>
            Looks like you have no pull requests!
          </Text>
          <Text style={[prStyles.emptySubText]}>
            You should start coding
            some Elixir! 💻
          </Text>
        </View>
      </MineOpenPRs>
      <MonitorsOpenPRs tabLabel='Monitors' tab='monitors' togglePRRow={togglePRRow} expandedPr={expandedPr}>
        <View style={[prStyles.emptyView]}>
          <Text style={[prStyles.emptyMainText]}>
            None of your friends have pull requests...
          </Text>
          <Text style={[prStyles.emptySubText]}>
            or do you not have any friends? 🤓
          </Text>
        </View>
      </MonitorsOpenPRs>
      {/* <PRView tabLabel='Hidden' dispatch={dispatch} tab={'hidden'} prs={pullRequests.hidden || []} /> */}
    </ScrollableTabView>
  );
}

export default PRTabs;
