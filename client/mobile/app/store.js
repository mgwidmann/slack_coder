import { createStore, applyMiddleware, combineReducers, compose } from 'redux';
import thunkMiddleware from 'redux-thunk';
import { createLogger } from 'redux-logger';
import reducers from './reducers';

const loggerMiddleware = createLogger({ predicate: (getState, action) => true });

function configureStore(initialState) {
  const enhancer = compose(
    applyMiddleware(
      thunkMiddleware,
      loggerMiddleware
    )
  );
  // const finalReducers = combineReducers({ ...reducers, router: routerReducer });
  return createStore(reducers, initialState, enhancer);
}

let initialStore = {};

export const store = configureStore(initialStore);
