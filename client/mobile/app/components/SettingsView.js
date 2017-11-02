import React, { Component } from 'react';
import { View, Text, Image, StyleSheet, Button } from 'react-native';
import { NavigationActions } from 'react-navigation';
import { CheckBox } from 'react-native-elements'

import { PRIMARY_COLOR } from '../styles/constants';

class SettingsView extends Component {
  render() {
    const { currentUser } = this.props.navigation.state.params;

    return (
      <View style={styles.container}>
        <Text style={styles.name}>{currentUser.name}</Text>
        <Text style={styles.githubName}>{currentUser.github}</Text>
        <CheckBox title='Mute all notifications' />
      </View>
    );
  }
}

SettingsView.navigationOptions = ({ navigation: { state: { params }}}) => {
  return {
    headerTitle: (
      <View style={styles.headerImageContainer}>
        <Image source={{uri: params.currentUser.avatarUrl}} style={styles.headerImage} />
      </View>
    ),
    headerRight: (
      <Button color='white' title='Edit' onPress={() => {}} />
    ),
    headerStyle: { backgroundColor: PRIMARY_COLOR },
    headerTintColor: 'white',
  };
}

const styles = StyleSheet.create({
  headerImage: {
    width: 80,
    height: 80,
    borderRadius: 40,
    marginTop: 30
  },
  headerImageContainer: {
    borderColor: PRIMARY_COLOR,
    borderWidth: 15,
    borderRadius: 100
  },
  container: {
    marginTop: 50
  },
  name: {
    fontSize: 36,
    fontWeight: 'bold',
    textAlign: 'center',
    textShadowColor: PRIMARY_COLOR,
    textShadowOffset: {width: 2, height: 2},
    textShadowRadius: 1,
  },
  githubName: {
    fontSize: 20,
    color: 'gray',
    textAlign: 'center',
  },
});

export default SettingsView;