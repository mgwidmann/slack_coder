import { graphql } from 'react-apollo';
import LOG_QUERY from  './user.graphql';

export default graphql(LOG_QUERY, {
  options: (props) => ({ variables: { id: props.match.params.id } }),
  props: ({data: { log }}) => {
    const cucumber_failure = log.cucumber_failure;
    const rspec_failure = log.cucumber_failure;
    return {
      cucumber_failure,
      rspec_failure
    }
  }
});