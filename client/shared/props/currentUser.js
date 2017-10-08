import PropTypes from 'prop-types';

export default PropTypes.shape({
  id: PropTypes.string.isRequired,
  slack: PropTypes.string.isRequired,
  github: PropTypes.string.isRequired,
  avatarUrl: PropTypes.string.isRequired,
  htmlUrl: PropTypes.string.isRequired,
  name: PropTypes.string.isRequired,
  monitors: PropTypes.arrayOf(PropTypes.shape({
    github: PropTypes.string.isRequired
  })).isRequired,
  muted: PropTypes.bool.isRequired,
  admin: PropTypes.bool.isRequired
});
