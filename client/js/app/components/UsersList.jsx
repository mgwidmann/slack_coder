import React from 'react';
import PropTypes from 'prop-types';
import UserRow from '../components/UserRow';
import Pagination from '../components/Pagination';

const UsersList = ({ loading, users, admin, pageNumber, totalPages, gotoPage }) => {
  return (
    <section className="panel panel-default">
      <div className="panel-heading">
        <span className="h3">
          Users
        </span>
      </div>
      <div className="panel-body">
        <table className="table table-striped">
          <tbody id="users">
            {!loading && users != null ? users.map((user) => {
              return <UserRow key={user.id} user={user} editable={admin} />;
            }) : null}
          </tbody>
        </table>
        <div className="text-center">
          <Pagination page={pageNumber} totalPages={totalPages} gotoPage={gotoPage} />
        </div>
      </div>
    </section>
  );
}

import userListType from '../../../mobile/shared/props/userList';

UsersList.propTypes = {
  users: PropTypes.arrayOf(userListType),
  loading: PropTypes.bool.isRequired,
  pageNumber: PropTypes.number,
  totalPages: PropTypes.number,
  gotoPage: PropTypes.func,
  admin: PropTypes.bool.isRequired
}

export default UsersList;
