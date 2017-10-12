import PRList from './PRList';
import subscribeMonitorsPullRequests from '../../../shared/graphql/subscriptions/monitorsPullRequest';
import subscribeNew from '../../../shared/graphql/subscriptions/subscribeNew';

export default subscribeNew(subscribeMonitorsPullRequests(PRList));
