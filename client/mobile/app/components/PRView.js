import React from 'react';
import { ScrollView, StyleSheet } from 'react-native';
import PRRow from './PRRow';
import { gql, graphql } from 'react-apollo';

const PRView = ({ tab, prs }) => {
  const renderPR = (pr) => {
    return <PRRow key={pr.id} pr={pr} tab={tab} />;
  }

  return (
    <ScrollView>
      {prs.map(renderPR)}
    </ScrollView>
  );
}

export default PRView;
