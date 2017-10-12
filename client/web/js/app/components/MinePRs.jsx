import React from 'react';
import { Tabs, Tab } from 'react-bootstrap';
import MineOpenPRs from '../components/MineOpenPRs';
import MineHiddenPRs from '../components/MineHiddenPRs';

const MinePRs = ({ type, empty, currentUser }) => {
  return (
    <Tabs defaultActiveKey={1} >
      <Tab eventKey={1} title='Open' >
        <MineOpenPRs type={type} currentUser={currentUser} >
          {empty()}
        </MineOpenPRs>
      </Tab>
      <Tab eventKey={2} title='Hidden' >
        <MineHiddenPRs type={type} currentUser={currentUser} >
          {empty()}
        </MineHiddenPRs>
      </Tab>
    </Tabs>
  )
}

export default MinePRs;
