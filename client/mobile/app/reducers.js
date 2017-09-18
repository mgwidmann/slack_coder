import { combineReducers } from 'redux'
import pullRequests from '../shared/reducers/pullRequests';
import immutable from '../shared/reducers/immutable';

const reducers = combineReducers({
  currentUser: immutable,
  token: immutable,
  pullRequests
})

export default reducers;
