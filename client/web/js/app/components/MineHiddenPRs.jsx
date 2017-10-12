import PRList from './PRList';
import subscribeMineHiddenPullRequests from '../../../shared/graphql/subscriptions/mineHiddenPullRequest';

export default subscribeMineHiddenPullRequests(PRList);
