import React, { Component } from 'react';
import { View, Animated, Easing } from 'react-native';
import mainStyles from '../../styles/main';
import { PRIMARY_COLOR, FOREGROUND_COLOR } from '../../styles/constants';

export default class Loading extends Component {
  constructor (props) {
    super(props);
    this.spinValue = new Animated.Value(0);
    // this.springValue = new Animated.Value(0.3);
  }

  componentDidMount() {
    if (this.props.animate !== false) {
      this.animate();
    }
  }

  animate () {
    this.spinValue.setValue(0);
    // this.springValue.setValue(0.3);
    // Animated.spring(
    //   this.springValue,
    //   {
    //     toValue: 1,
    //     friction: 1
    //   }
    // )
    Animated.timing(
      this.spinValue,
      {
        toValue: 1,
        duration: 4000,
        easing: Easing.linear
      }
    )
    .start(() => this.animate())
  }

  render() {
    const spin = this.spinValue.interpolate({
      inputRange: [0, 1],
      outputRange: ['0deg', '360deg']
    });
    // const scale = this.springValue.interpolate({
    //   inputRange: [0, 1],
    //   outputRange: [0.5, 1.25]
    // });
    return (
      <View style={[mainStyles.tabBarContainer, mainStyles.loginContainer, this.props.main === false ? mainStyles.secondary : mainStyles.main]}>
        <Animated.Image source={require('../../assets/botlogo.png')} style={[mainStyles.logo, { transform: [{rotate: spin}] }]} />
      </View>
    );
  }
}
