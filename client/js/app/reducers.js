import { combineReducers } from 'redux'
import { routerReducer } from 'react-router-redux';
import pullRequests from '../../mobile/shared/reducers/pullRequests';
import immutable from '../../mobile/shared/reducers/immutable';

const reducers = combineReducers({
  currentUser: immutable,
  token: immutable,
  router: routerReducer,
  pullRequests
})

export default reducers;
