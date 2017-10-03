import React, { Component } from 'react';
import { compose } from 'react-apollo';
import { withRouter } from 'react-router';
import UsersList from '../components/UsersList';
import usersQuery from '../../../mobile/shared/graphql/queries/users';

const Users = ({ users, loading, pageNumber, totalPages, gotoPage, admin }) => {
  return (
    <UsersList
      users={users}
      loading={loading}
      pageNumber={pageNumber}
      totalPages={totalPages}
      gotoPage={gotoPage}
      admin={admin}
    />
  );
}

export default compose(
  withRouter,
  usersQuery
)(Users);
