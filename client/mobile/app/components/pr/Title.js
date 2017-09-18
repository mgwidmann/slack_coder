import React, { Component } from 'react';
import { View, Image, Text, StyleSheet } from 'react-native';

export default class Title extends Component {
  render() {
    const { image, title } = this.props;
    return (
      <View style={styles.titleView}>
        <Image source={{uri: image}} style={styles.avatar} />
        <Text style={styles.title} numberOfLines={3}>
          {title}
        </Text>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  titleView: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'flex-start'
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
