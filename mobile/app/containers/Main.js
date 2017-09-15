import React, { Component } from 'react';
import { connect } from 'react-redux'
import ScrollableTabView from 'react-native-scrollable-tab-view';
import tabStyles from '../styles/tab';
import { PRIMARY_COLOR, SECONDARY_COLOR, FOREGROUND_COLOR } from '../styles/constants';
import PRView from '../components/PRView'

class Main extends Component {
  componentDidMount() {
    this.props.dispatch({type: '-'});
  }
  render () {
    return (
      <ScrollableTabView
        tabBarPosition="bottom"
        style={tabStyles.tabBarContainer}
        tabBarBackgroundColor={PRIMARY_COLOR}
        tabBarActiveTextColor={FOREGROUND_COLOR}
        tabBarUnderlineStyle={tabStyles.tabBarUnderline}
        >
        <PRView tabLabel='My PRs' count={this.props.simple} />
        <PRView tabLabel='Monitors' count={this.props.simple + 1} />
        <PRView tabLabel='Hidden' count={this.props.simple - 1}/>
      </ScrollableTabView>
    )
  }
}

const mapStateToProps = (state) => { return state; }

export default connect(mapStateToProps)(Main);
