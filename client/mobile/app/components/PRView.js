import React from 'react';
import { ScrollView, StyleSheet } from 'react-native';
import PRRow from './PRRow';

const PRView = ({ tab, prs, togglePRRow, expandedPr }) => {
  const renderPR = (pr) => {
    return <PRRow key={pr.id} pr={pr} tab={tab} togglePRRow={togglePRRow} expandedPr={expandedPr} />;
  }

  return (
    <ScrollView>
      {prs.map(renderPR)}
    </ScrollView>
  );
}

export default PRView;
