import React from 'react';

import Loading from './Loading';
import Login from './Login';
import PRTabs from './PRTabs';

const MainView = ({ loggedIn, loading, error, setToken, togglePRRow, expandedPr }) => {
  // Cannot use null/undefined to determine difference between unknown and no value
  if (loggedIn && !loading && !error) {
    return <PRTabs togglePRRow={togglePRRow} expandedPr={expandedPr} />;
  } else if (error) {
    return <Loading animate={false} />;
  } else if (loading) {
    return <Loading />;
  } else {
    return <Login setToken={setToken} />
  }
}

export default MainView;
