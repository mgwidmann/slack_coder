import React, { Component } from 'react';
import { AppState, View, Text, StyleSheet, ListView } from 'react-native';

import PRRow from './PRRow';
import Loading from './Loading';

const dataSource = new ListView.DataSource({
  rowHasChanged: (r1, r2) => r1 != r2
});

class PRView extends Component {
  constructor(props) {
    super(props);
    this.renderPR = this.renderPR.bind(this);
    this._handleAppStateChange = this._handleAppStateChange.bind(this);
  }

  componentDidMount() {
    AppState.addEventListener('change', this._handleAppStateChange);
  }

  componentWillUnmount() {
    AppState.removeEventListener('change', this._handleAppStateChange);
  }

  _handleAppStateChange(nextAppState) {
    if (nextAppState === 'active') {
      this.props.refetch();
    }
  }

  renderPR(pr) {
    let { tab, togglePRRow, expandedPr, subscribe } = this.props;
    return <PRRow key={pr.id} pr={pr} tab={tab} togglePRRow={togglePRRow} expandedPr={expandedPr} subscribe={subscribe} />;
  }

  render() {
    let { pullRequests, loading, children } = this.props;

    if (loading || !pullRequests) {
      return <Loading main={false} />;
    } else if (pullRequests.length == 0) {
      return children;
    } else {
      return (
        <ListView
          dataSource={dataSource.cloneWithRows(pullRequests)}
          renderRow={this.renderPR}
        />
      )
    }
  }
}

export default PRView;
