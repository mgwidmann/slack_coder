import PropTypes from 'prop-types';

export default PropTypes.shape({
  closeSelf: PropTypes.bool.isRequired,
  closeMonitors: PropTypes.bool.isRequired,
  conflictSelf: PropTypes.bool.isRequired,
  conflictMonitors: PropTypes.bool.isRequired,
  failSelf: PropTypes.bool.isRequired,
  failMonitors: PropTypes.bool.isRequired,
  mergeSelf: PropTypes.bool.isRequired,
  mergeMonitors: PropTypes.bool.isRequired,
  openSelf: PropTypes.bool.isRequired,
  openMonitors: PropTypes.bool.isRequired,
  passSelf: PropTypes.bool.isRequired,
  passMonitors: PropTypes.bool.isRequired
});
