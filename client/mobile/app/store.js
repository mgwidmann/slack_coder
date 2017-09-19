import { createStore, applyMiddleware, combineReducers, compose } from 'redux';
import thunkMiddleware from 'redux-thunk';
import { createLogger } from 'redux-logger';
import reducers from './reducers';
import client from '../shared/graphql/client';
import networkInterface from '../shared/graphql/networkInterface';

const loggerMiddleware = createLogger({ predicate: (getState, action) => true });

function configureStore(initialState) {
  const enhancer = compose(
    applyMiddleware(
      thunkMiddleware,
      loggerMiddleware,
      client.middleware()
    )
  );
  // const finalReducers = combineReducers({ ...reducers, router: routerReducer });
  return createStore(reducers, initialState, enhancer);
}

let initialStore = {};

export const store = configureStore(initialStore);

networkInterface.use([{
  applyMiddleware(req, next) {
    if (!req.options.headers) {
      req.options.headers = {};  // Create the header object if needed.
    }
    const token = store.getState().token;
    req.options.headers.authorization = token ? `Bearer ${token}` : null;

    next();
  }
}]);
