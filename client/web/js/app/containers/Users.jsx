import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { compose } from 'react-apollo';
import { withRouter } from 'react-router';
import UsersList from '../components/UsersList';
import usersQuery from '../../../shared/graphql/queries/users';

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

import userListType from '../../../shared/props/userList';

Users.propTypes = {
  users: PropTypes.arrayOf(userListType),
  loading: PropTypes.bool.isRequired,
  pageNumber: PropTypes.number,
  totalPages: PropTypes.number,
  gotoPage: PropTypes.func,
  admin: PropTypes.bool.isRequired
}

export default compose(
  withRouter,
  usersQuery
)(Users);
