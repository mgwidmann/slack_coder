import React, { Component } from 'react';
import SynchronizePRLink from './SynchronizePRLink';

export default class PRRow extends Component {
  statusClass(status) {
    switch(status) {
      case 'FAILURE':
      case 'ERROR':
        return 'danger';
      case 'SUCCESS':
        return 'success';
      case 'PENDING':
        return 'warning';
      case 'CONFLICT':
        return 'highlight';
      default:
        return 'info';
    }
  }

  render() {
    const { pr, synchronize } = this.props;
    return (
      <tr key={pr.id}>
        <td>
          <img src={pr.user && pr.user.avatarUrl} className="img-circle user-avatar" />
        </td>
        <td className="hidden-xs">
          {pr.user && pr.user.github}
        </td>
        <td className="hidden-xs">
          <a href={`https://github.com/${pr.owner}/${pr.repo}/`}>{pr.repo}</a>
        </td>
        <td className="hidden-xs hidden-sm hidden-md">
          {pr.branch}
        </td>
        <td>
          <a href={pr.htmlUrl} target="_blank">{pr.title}</a>
        </td>
        <td>
          <a href={pr.buildUrl} className={`label label-${this.statusClass(pr.buildStatus)} text-uppercase`} target="_blank" data-placement='top' data-toggle="tooltip" title="Current Status">
            {pr.buildStatus || 'Unknown'}
          </a>
        </td>
        <td className="hidden-xs">
          {pr.analysisUrl && (
            <a href={pr.analysisUrl} target="_blank" data-placement="top" data-toggle="tooltip" title="CodeClimate">
              <i className='code-climate'></i>
            </a>
          )}
        </td>
        <td>
          <SynchronizePRLink owner={pr.owner} repository={pr.repository} number={pr.number} />
        </td>
      </tr>
    );
  }
}
