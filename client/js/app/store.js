import { createStore, applyMiddleware, combineReducers, compose } from 'redux';
import thunkMiddleware from 'redux-thunk';
import { createLogger } from 'redux-logger';
import createHistory from 'history/createBrowserHistory';
import { Route } from 'react-router';
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
      historyMiddleware
    )
  );
  // const finalReducers = combineReducers({ ...reducers, router: routerReducer });
  return createStore(reducers, initialState, enhancer);
}

let initialStore = {
  // On window or undefined
  currentUser: currentUser,
  token: token
};

export const store = configureStore(initialStore);
export const history = historyObject;
