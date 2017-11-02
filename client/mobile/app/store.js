import { createStore, applyMiddleware, combineReducers, compose } from 'redux';
import Reactotron from 'reactotron-react-native';
import thunkMiddleware from 'redux-thunk';
import { createLogger } from 'redux-logger';
import client from './client';
import reducers from './reducers';

let middleware = [
  thunkMiddleware,
  client.middleware()
]

let createReduxStore;
if (__DEV__) {
  const loggerMiddleware = createLogger({ predicate: (getState, action) => true, collapsed: true });
  middleware.push(loggerMiddleware);
  createReduxStore = Reactotron.createStore;
} else {
  createReduxStore = createStore;
}

function configureStore(initialState) {
  const enhancer = compose(
    applyMiddleware(...middleware),
    (typeof window.__REDUX_DEVTOOLS_EXTENSION__ !== 'undefined') ? window.__REDUX_DEVTOOLS_EXTENSION__() : f => f
  );
  return createReduxStore(reducers, initialState, enhancer);
}

let initialStore = {};

export default configureStore(initialStore);
