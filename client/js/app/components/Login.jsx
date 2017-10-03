import React from 'react';

export default () => {
  return (
    <div className="center sign-in">
      <a className="btn btn-default btn-xxl" href="/auth/github">
        <i className="fa fa-github"></i>
        Sign in with GitHub
        <i className="fa fa-angle-right"></i>
      </a>
    </div>
  );
}
