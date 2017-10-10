import React, { Component } from 'react';
import { Text, View, TouchableHighlight, StyleSheet } from 'react-native';
import Title from './pr/Title';
import StatusText from './pr/StatusText';
import RepoText from './pr/RepoText';

export default ({ pr, togglePRRow, expandedPr }) => {
  return (
    <View>
      <TouchableHighlight style={styles.rowView} onPress={() => togglePRRow(pr) } activeOpacity={0.9} underlayColor={'#EEE'}>
        <View style={styles.titleView}>
          <Title image={pr.user && pr.user.avatarUrl} title={pr.title} />
          <StatusText status={pr.buildStatus} link={pr.buildUrl}>
            <RepoText repo={pr.repo} />
          </StatusText>
        </View>
      </TouchableHighlight>
      <View style={[{display: expandedPr == pr.id ? 'flex' : 'none'}, styles.hiddenView]}>
        <Text>Shows up when clicked</Text>
      </View>
    </View>
  );
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
