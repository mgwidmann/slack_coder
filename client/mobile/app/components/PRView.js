import React, { Component } from 'react';
import { AppState, View, Text, StyleSheet, FlatList } from 'react-native';

import PRRow from './PRRow';
import Loading from './Loading';

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

  renderPR({ item: pr }) {
    let { tab, togglePRRow, expandedPr, subscribe } = this.props;
    return <PRRow key={pr.id} pr={pr} tab={tab} togglePRRow={togglePRRow} expandedPr={expandedPr} subscribe={subscribe} />;
  }

  render() {
    let { pullRequests, loading, expandedPr, children } = this.props;

    if (loading || !pullRequests) {
      return <Loading main={false} />;
    } else if (pullRequests.length == 0) {
      return children;
    } else {
      return (
        <FlatList
          data={pullRequests}
          renderItem={this.renderPR}
          keyExtractor={(pr) => { return pr.id }}
          extraData={expandedPr}
        />
      )
    }
  }
}

export default PRView;
