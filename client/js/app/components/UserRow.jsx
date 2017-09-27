import React, { Component } from 'react';

export default class UserRow extends Component {
  render() {
    let { user, editable } = this.props;
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
            <a href={`/users/${user.id}/edit`}>
              <i className='glyphicon glyphicon-pencil'></i>
            </a>
          </td>
        ) : null}
      </tr>

    );
  }
}
