import React, { Component } from 'react';
import { Text, View, TouchableHighlight, StyleSheet } from 'react-native';
import Title from './pr/Title';
import StatusText from './pr/StatusText';
import RepoText from './pr/RepoText';
import { toggleExpandPR } from '../../shared/actions/pullRequest';

export default class PRView extends Component {
  constructor(props) {
    super(props);
    this.activateRow = this.activateRow.bind(this);
  }

  activateRow() {
    const { dispatch, pr, tab } = this.props;
    dispatch(toggleExpandPR(pr, tab));
  }

  render() {
    const { pr } = this.props;
    return (
      <View>
        <TouchableHighlight style={styles.rowView} onPress={this.activateRow} activeOpacity={0.9} underlayColor={'#EEE'}>
          <View style={styles.titleView}>
            <Title image={pr.avatar} title={pr.title} />
            <StatusText status={pr.status} link={pr.buildUrl}>
              <RepoText repo={pr.repo} />
            </StatusText>
          </View>
        </TouchableHighlight>
        <View style={[{display: pr.expand ? 'flex' : 'none'}, styles.hiddenView]}>
          <Text>Shows up when clicked</Text>
        </View>
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
  },
  hiddenView: {
    height: 150
  }
});
