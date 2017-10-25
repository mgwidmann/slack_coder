import { createStore, applyMiddleware, combineReducers, compose } from 'redux';
import thunkMiddleware from 'redux-thunk';
import { createLogger } from 'redux-logger';
import client from './client';
import reducers from './reducers';

let middleware = [
  thunkMiddleware,
  client.middleware()
]

if (__DEV__) {
  const loggerMiddleware = createLogger({ predicate: (getState, action) => true, collapsed: true });
  middleware.push(loggerMiddleware);
}

function configureStore(initialState) {
  const enhancer = compose(
    applyMiddleware(...middleware),
    (typeof window.__REDUX_DEVTOOLS_EXTENSION__ !== 'undefined') ? window.__REDUX_DEVTOOLS_EXTENSION__() : f => f
  );
  return createStore(reducers, initialState, enhancer);
}

let initialStore = {};

export default configureStore(initialStore);
