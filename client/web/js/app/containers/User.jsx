import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { withRouter } from 'react-router';
import { compose } from 'react-apollo';
import userQuery from '../../../shared/graphql/queries/user';
import searchUsersQuery from '../../../shared/graphql/queries/searchUsers';
import updateUserMutation from '../../../shared/graphql/mutations/updateUser';
import Loading from '../components/Loading';
import LargeAvatar from '../components/user/LargeAvatar';
import EditUser from '../components/user/EditUser';

class User extends Component {
  successfulSubmit() {
    this.props.history.push('/');
  }

  render() {
    let { user, loading, search, updateUser } = this.props;
    if (loading) {
      return <Loading />;
    }

    return (
      <div>
        <LargeAvatar avatarUrl={user.avatarUrl} github={user.github} name={user.name} />
        <EditUser user={user} search={search} updateUser={updateUser} success={::this.successfulSubmit} />
      </div>
    );
  }
}

import editUserType from '../../../shared/props/editUser';

User.propTypes = {
  history: PropTypes.shape({
    push: PropTypes.func.isRequired
  }).isRequired,
  user: editUserType,
  loading: PropTypes.bool.isRequired,
  search: PropTypes.func.isRequired,
  updateUser: PropTypes.func.isRequired
}

export default compose(
  withRouter,
  userQuery,
  searchUsersQuery,
  updateUserMutation
)(User);
