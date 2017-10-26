import React, { Component } from 'react';
import { connect } from 'react-redux';
import { addNavigationHelpers, createNavigator, Transitioner } from 'react-navigation';

import Router from '../router';

const Navigation = ({ state, dispatch }) => {
  const { routes, index } = state;
  
  // Figure out what to render based on the navigation state and the router:
  const Component = Router.getComponentForState(state);
  
  // The state of the active child screen can be found at routes[index]
  let childNavigation = { dispatch, state: routes[index] };
  // If we want, we can also tinker with the dispatch function here, to limit
  // or augment our children's actions
  
  // Assuming our children want the convenience of calling .navigate() and so on,
  // we should call addNavigationHelpers to augment our navigation prop:
  childNavigation = addNavigationHelpers(childNavigation);
  
  const render = () => {
    return <Component navigation={childNavigation} />;
  };

  const configureTransition = (transitionProps, prevTransitionProps) => {
    return {
      // duration in milliseconds, default: 250
      duration: 500,
      // An easing function from `Easing`, default: Easing.inOut(Easing.ease)
      easing: Easing.bounce,
    }
  };

  return (
    <Transitioner
      configureTransition={configureTransition}
      navigation={childNavigation}
      render={render}
    />
  );
}

const Navigator = createNavigator(Router)(Navigation);

const mapStateToProps = (state) => ({
  state: state.nav
});

export default connect(mapStateToProps)(Navigator);