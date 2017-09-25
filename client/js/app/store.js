import { createStore, applyMiddleware, combineReducers, compose } from 'redux';
import thunkMiddleware from 'redux-thunk';
import { createLogger } from 'redux-logger';
import createHistory from 'history/createBrowserHistory';
import { Route } from 'react-router';
import client from '../../mobile/shared/graphql/client';
import networkInterface from '../../mobile/shared/graphql/networkInterface';
import { routerMiddleware } from 'react-router-redux';
import reducers from './reducers';

const loggerMiddleware = createLogger({ predicate: (getState, action) => true });
const historyObject = createHistory();
const historyMiddleware = routerMiddleware(historyObject);

function configureStore(initialState) {
  const enhancer = compose(
    applyMiddleware(
      thunkMiddleware,
      loggerMiddleware,
      historyMiddleware,
      client.middleware()
    ),
    (typeof window.__REDUX_DEVTOOLS_EXTENSION__ !== 'undefined') ? window.__REDUX_DEVTOOLS_EXTENSION__() : f => f
  );
  // const finalReducers = combineReducers({ ...reducers, router: routerReducer });
  return createStore(reducers, initialState, enhancer);
}

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

let initialStore = {
  // On window or undefined
  currentUser: currentUser,
  token: token
};

export const store = configureStore(initialStore);
export const history = historyObject;
