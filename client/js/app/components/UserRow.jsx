import React from 'react';
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

export default UserRow;
