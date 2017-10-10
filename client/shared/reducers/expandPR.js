import { TOGGLE_EXPAND_PR } from '../actions/constants/pullRequest';

export default (state = null, action) => {
  switch (action.type) {
    case TOGGLE_EXPAND_PR:
      if (state === null || state !== action.id) {
        return action.id;
      } else {
        return null;
      }
    default:
      return state;
  }
}
