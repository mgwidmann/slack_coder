import { combineReducers } from 'redux'
import { routerReducer } from 'react-router-redux';
import client from './client';
import immutable from '../../shared/reducers/immutable';

const reducers = combineReducers({
  currentUser: immutable('currentUser'),
  token: immutable('token'),
  router: routerReducer,
  graphql: client.reducer()
})

export default reducers;
