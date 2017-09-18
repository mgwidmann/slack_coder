export default (state = null, action) => {
  switch(action.type) {
    case 'SET':
      return action.state;
    default:
      return state
  }
}
