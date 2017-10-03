import React from 'react';
import PropTypes from 'prop-types';
import { Link } from 'react-router-dom';

const UserRow = ({ user, editable }) => {
  return (
    <tr>
      <td>
        <img src={user.avatarUrl} className="img-circle user-avatar" />
      </td>
      <td>
        {user.name} ({user.github})
      </td>
      <td>
        {user.muted ? (
          <span className="label label-danger">MUTED</span>
        ) : (
          <span className="label label-success">UNMUTED</span>
        )}
      </td>
      {editable ? (
        <td>
          <Link to={`/users/${user.id}/edit`}>
            <i className='glyphicon glyphicon-pencil'></i>
          </Link>
        </td>
      ) : null}
    </tr>
  );
}

import userListType from '../../../mobile/shared/props/userList';

UserRow.propTypes = {
  user: userListType,
  editable: PropTypes.bool.isRequired
}

export default UserRow;
