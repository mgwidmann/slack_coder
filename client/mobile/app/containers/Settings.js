import React from 'react';
import { connect } from 'react-redux';

import SettingsView from '../components/SettingsView';

function mapStateToProps(state, props) {
  return {
    ...props,
  };
}

function mapDispatchToProps(dispatch) {
  return {

  };
}

export default connect(mapStateToProps, mapDispatchToProps)(SettingsView);