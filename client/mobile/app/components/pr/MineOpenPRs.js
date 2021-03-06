import PRView from '../PRView';
import subscribeMinePullRequests from '../../../shared/graphql/subscriptions/minePullRequest';
import subscribeNew from '../../../shared/graphql/subscriptions/subscribeNew';

export default subscribeNew(subscribeMinePullRequests(PRView));
