import PropTypes from 'prop-types';

export default PropTypes.shape({
  id: PropTypes.string.isRequired,
  analysisStatus: PropTypes.string,
  analysisUrl: PropTypes.string,
  backoff: PropTypes.number.isRequired,
  branch: PropTypes.string.isRequired,
  number: PropTypes.number.isRequired,
  buildStatus: PropTypes.string,
  buildUrl: PropTypes.string,
  htmlUrl: PropTypes.string.isRequired,
  owner: PropTypes.string.isRequired,
  repository: PropTypes.string.isRequired,
  closedAt: PropTypes.string,
  mergedAt: PropTypes.string,
  title: PropTypes.string.isRequired,
  user: PropTypes.shape({
    id: PropTypes.string.isRequired,
    avatarUrl: PropTypes.string.isRequired,
    name: PropTypes.string.isRequired,
  }).isRequired
});
