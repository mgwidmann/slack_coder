import React from 'react';
import { View, Text, StyleSheet, ListView } from 'react-native';
import PRRow from './PRRow';
import Loading from './Loading';

const dataSource = new ListView.DataSource({
  rowHasChanged: (r1, r2) => r1 != r2
});

const PRView = ({ tab, pullRequests, loading, togglePRRow, expandedPr, children }) => {
  const renderPR = (pr) => {
    return <PRRow key={pr.id} pr={pr} tab={tab} togglePRRow={togglePRRow} expandedPr={expandedPr} />;
  }

  if (loading) {
    return <Loading />;
  } else if (pullRequests.length == 0) {
    return children;
  } else {
    return (
      <ListView
        dataSource={dataSource.cloneWithRows(pullRequests)}
        renderRow={renderPR}
      />
    )
  }
}

export default PRView;
