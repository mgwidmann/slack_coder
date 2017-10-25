import React, { Component } from 'react';
import { View, TouchableHighlight, StyleSheet } from 'react-native';

import synchronizePR from '../../shared/graphql/mutations/synchronize';
import Title from './pr/Title';
import StatusText from './pr/StatusText';
import RepoText from './pr/RepoText';
import ExpandedPRRow from './pr/ExpandedPRRow';

class PRRow extends Component {
  componentDidMount() {
    let { tab, pr, subscribe } = this.props;
    this.unsubscribe = subscribe(pr, tab);
  }

  componentWillUnmount() {
    this.unsubscribe();
  }

  render() {
    let { pr, togglePRRow, expandedPr, synchronize } = this.props;
    return (
      <View>
        <TouchableHighlight style={styles.rowView} onPress={() => togglePRRow(pr) } activeOpacity={0.9} underlayColor={'#EEE'}>
          <View style={styles.titleView}>
            <Title image={pr.user && pr.user.avatarUrl} title={pr.title} branch={pr.baseBranch} />
            <StatusText status={pr.buildStatus} link={pr.buildUrl}>
              <RepoText repo={pr.repository} />
            </StatusText>
          </View>
        </TouchableHighlight>
        <ExpandedPRRow
          show={expandedPr == pr.id}
          githubUrl={pr.htmlUrl}
          analysisUrl={pr.analysisUrl}
          synchronize={() => { synchronize({ variables: {owner: pr.owner, repo: pr.repository, number: pr.number }}) }}
        />
      </View>
    );
  }
}

const styles = StyleSheet.create({
  rowView: {
    borderTopWidth: 1,
    borderBottomWidth: 1,
    borderColor: '#BBBBCC',
    padding: 5,
    marginLeft: 5,
    marginRight: 5,
    marginTop: -1,
    height: 75
  },
  titleView: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'space-between'
  }
});

export default synchronizePR(PRRow);
