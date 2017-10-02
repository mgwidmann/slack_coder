import React, { Component } from 'react';
import { withRouter } from 'react-router';
import { compose } from 'react-apollo';
import userQuery from '../../../mobile/shared/graphql/queries/user';
import searchUsersQuery from '../../../mobile/shared/graphql/queries/searchUsers';
import updateUserMutation from '../../../mobile/shared/graphql/mutations/updateUser';
import Loading from '../components/Loading';
import LargeAvatar from '../components/user/LargeAvatar';
import EditUser from '../components/user/EditUser';

class User extends Component {
  constructor(props) {
    super(props);
    this.state = { success: false };
  }

  successfulSubmit() {
    this.setState({ success: true });
  }

  render() {
    let { user, loading, search, updateUser } = this.props;
    if (loading) {
      return <Loading />;
    }
    if (this.state.success) {
      return <Redirect to="/" />;
    }

    return (
      <div>
        <LargeAvatar avatarUrl={user.avatarUrl} github={user.github} name={user.name} />
        <EditUser user={user} search={search} updateUser={updateUser} success={::this.successfulSubmit} />
      </div>
    );
  }
}

export default compose(
  withRouter,
  userQuery,
  searchUsersQuery,
  updateUserMutation
)(User);
