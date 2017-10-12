import PRList from './PRList';
import subscribeMonitorsHiddenPullRequests from '../../../shared/graphql/subscriptions/monitorsHiddenPullRequest';

export default subscribeMonitorsHiddenPullRequests(PRList);
