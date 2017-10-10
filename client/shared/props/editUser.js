import PropTypes from 'prop-types';
import userConfigType from './userConfig';

export default PropTypes.shape({
  slack: PropTypes.string.isRequired,
  muted: PropTypes.bool.isRequired,
  config: userConfigType,
  monitors: PropTypes.arrayOf(
    PropTypes.shape({
      github: PropTypes.string.isRequired,
      name: PropTypes.string.isRequired
    })
  ).isRequired,
});
