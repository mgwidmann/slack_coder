import PRView from '../PRView';
import subscribeMonitorsPullRequests from '../../../shared/graphql/subscriptions/monitorsPullRequest';
import subscribeNew from '../../../shared/graphql/subscriptions/subscribeNew';

export default subscribeNew(subscribeMonitorsPullRequests(PRView));
