import { combineReducers } from 'redux'
import immutable from '../shared/reducers/immutable';
import login from '../shared/reducers/login';
import expandPR from '../shared/reducers/expandPR';
import nav from './reducers/nav';
import client from './client';

const reducers = combineReducers({
  graphql: client.reducer(),
  currentUser: immutable('currentUser'),
  login: login,
  expandedPr: expandPR,
  nav: nav
})

export default reducers;
