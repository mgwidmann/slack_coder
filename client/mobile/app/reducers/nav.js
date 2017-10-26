import Router from '../router';

const initialState = Router.getStateForAction(Router.getActionForPathAndParams('Main'));

export default (state = initialState, action) => {
  const nextState = Router.getStateForAction(action, state);

  return nextState || state;
};