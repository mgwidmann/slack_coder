import React from 'react';
import { Tabs, Tab } from 'react-bootstrap';
import MonitorsOpenPRs from '../components/MonitorsOpenPRs';
import MonitorsHiddenPRs from '../components/MonitorsHiddenPRs';

const MonitorsPRs = ({ type, empty, currentUser }) => {
  return (
    <Tabs defaultActiveKey={1} >
      <Tab eventKey={1} title='Open' >
        <MonitorsOpenPRs type={type} currentUser={currentUser} >
          {empty()}
        </MonitorsOpenPRs>
      </Tab>
      <Tab eventKey={2} title='Hidden' >
        <MonitorsHiddenPRs type={type} currentUser={currentUser} >
          {empty()}
        </MonitorsHiddenPRs>
      </Tab>
    </Tabs>
  )
}

export default MonitorsPRs;
