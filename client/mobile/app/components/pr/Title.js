import React from 'react';
import { View, Image, Text, StyleSheet } from 'react-native';

const Title = ({ image, title, branch }) => {
  return (
    <View style={styles.titleView}>
      {image && (<Image source={{uri: image}} style={styles.avatar} />)}
      <View style={styles.titleContainer}>
        <Text style={styles.title} numberOfLines={2}>
          {title}
        </Text>
        <Text style={styles.branchText}>{branch}</Text>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  titleView: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'flex-start'
  },
  titleContainer: {
    flex: 1,
    flexDirection: 'column',
    justifyContent: 'flex-end'
  },
  branchText: {
    fontSize: 12,
    color: '#BBBBCC'
  },
  avatar: {
    width: 60,
    height: 60,
    borderRadius: 30
  },
  title: {
    marginTop: 7,
    height: 60,
    flexWrap: 'wrap',
    flex: 1,
    paddingRight: 3,
    paddingLeft: 3
  }
});

export default Title;