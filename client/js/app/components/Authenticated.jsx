import React from 'react';
import PropTypes from 'prop-types';
import { Redirect, withRouter } from 'react-router';

const Authenticated = ({ currentUser, location, redirect, onlyAuthenticated, children }) => {
  if (Object.keys(currentUser).length > 0 || location.pathname == '/login' && !onlyAuthenticated) {
    return children;
  } else if (redirect === true) {
    return <Redirect to="/login" />;
  } else {
    return null;
  }
}

Authenticated.propTypes = {
  currentUser: PropTypes.object,
  location: PropTypes.shape({ pathname: PropTypes.string.isRequired }),
  redirect: PropTypes.bool,
  onlyAuthenticated: PropTypes.bool,
  children: PropTypes.element.isRequired
}

export default withRouter(Authenticated);
