import { combineReducers } from 'redux'
import immutable from '../shared/reducers/immutable';
import token from '../shared/reducers/token';
import expandPR from '../shared/reducers/expandPR';
import client from './client';

const reducers = combineReducers({
  graphql: client.reducer(),
  currentUser: immutable('currentUser'),
  token: token,
  expandedPr: expandPR
})

export default reducers;
