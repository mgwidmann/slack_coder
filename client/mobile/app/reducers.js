import { combineReducers } from 'redux'
import immutable from '../shared/reducers/immutable';
import client from './client';

const reducers = combineReducers({
  graphql: client.reducer(),
  currentUser: immutable('currentUser'),
  token: immutable('token')
})

export default reducers;
