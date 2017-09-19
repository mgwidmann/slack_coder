import { combineReducers } from 'redux'
import pullRequests from '../shared/reducers/pullRequests';
import immutable from '../shared/reducers/immutable';
import client from '../shared/graphql/client';

const reducers = combineReducers({
  graphql: client.reducer(),
  currentUser: immutable('currentUser'),
  token: immutable('token'),
  pullRequests
})

export default reducers;
