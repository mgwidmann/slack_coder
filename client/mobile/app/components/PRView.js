import React, { Component } from 'react';
import { ScrollView, StyleSheet } from 'react-native';
import PRRow from './PRRow';
import { gql, graphql } from 'react-apollo';

export default class PRView extends Component {
  constructor(props) {
    super(props);
    this.renderPR = this.renderPR.bind(this);
  }

  renderPR(pr) {
    const { tab, dispatch } = this.props;
    return <PRRow key={pr.id} pr={pr} dispatch={dispatch} tab={tab} />;
  }

  render () {
    return (
      <ScrollView>
        {this.props.prs.map(this.renderPR)}
      </ScrollView>
    )
  }
}

const styles = StyleSheet.create({
});

// export default graphql(gql`
//   query PRs {
//     pullRequests {
//       id
//     }
//   }
// `)(PRView);
