export default (key) => {
  return (state = null, action) => {
    switch(action.type) {
      case 'SET':
        if (key == action.key) {
          return action.value;
        } else {
          return state;
        }
      default:
        return state
    }
  }
}
