import React, { Component } from 'react';
import { connect } from 'react-redux'
import ScrollableTabView from 'react-native-scrollable-tab-view';
import tabStyles from '../styles/tab';
import { PRIMARY_COLOR, SECONDARY_COLOR, FOREGROUND_COLOR } from '../styles/constants';
import PRView from '../components/PRView'

class Main extends Component {
  render () {
    const { dispatch, pullRequests } = this.props;
    return (
      <ScrollableTabView
        tabBarPosition="bottom"
        style={tabStyles.tabBarContainer}
        tabBarBackgroundColor={PRIMARY_COLOR}
        tabBarActiveTextColor={FOREGROUND_COLOR}
        tabBarUnderlineStyle={tabStyles.tabBarUnderline}
        >
        <PRView tabLabel='Main' dispatch={dispatch} tab={'main'} prs={pullRequests.main} />
        <PRView tabLabel='Monitors' dispatch={dispatch} tab={'monitors'} prs={pullRequests.monitors} />
        <PRView tabLabel='Hidden' dispatch={dispatch} tab={'hidden'} prs={pullRequests.hidden} />
      </ScrollableTabView>
    )
  }
}

const mapStateToProps = (state) => { return state; }

export default connect(mapStateToProps)(Main);
