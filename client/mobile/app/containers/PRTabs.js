import React from 'react';
import ScrollableTabView from 'react-native-scrollable-tab-view';

import { PRIMARY_COLOR, SECONDARY_COLOR, FOREGROUND_COLOR } from '../styles/constants';
import subscribePullRequests from '../../shared/graphql/subscriptions/pullRequest';
import mainStyles from '../styles/main';
import PRView from '../components/PRView';


const PRTabs = ({ mine, monitors, subscribeNew, subscribe }) => {
  return (
    <ScrollableTabView
      tabBarPosition="bottom"
      style={mainStyles.tabBarContainer}
      tabBarBackgroundColor={PRIMARY_COLOR}
      tabBarActiveTextColor={FOREGROUND_COLOR}
      tabBarUnderlineStyle={mainStyles.tabBarUnderline}
      >
      <PRView tabLabel='Main' tab='main' prs={mine || []} />
      <PRView tabLabel='Monitors' tab='monitors' prs={monitors || []} />
      {/* <PRView tabLabel='Hidden' dispatch={dispatch} tab={'hidden'} prs={pullRequests.hidden || []} /> */}
    </ScrollableTabView>
  )
}

export default subscribePullRequests(PRTabs);
