import { combineReducers } from 'redux'
import immutable from '../shared/reducers/immutable';
import expandPR from '../shared/reducers/expandPR';
import client from './client';

const reducers = combineReducers({
  graphql: client.reducer(),
  currentUser: immutable('currentUser'),
  token: immutable('token'),
  expandedPr: expandPR
})

export default reducers;
