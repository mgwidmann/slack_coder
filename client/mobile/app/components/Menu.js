import React from 'react';
import Icon from 'react-native-vector-icons/MaterialIcons';
import ActionButton from 'react-native-action-button';

import mainStyles from '../styles/main';
import { PRIMARY_COLOR_RGBA, SECONDARY_COLOR } from '../styles/constants';

const Menu = ({ logout }) => {
  return (
    <ActionButton buttonColor={PRIMARY_COLOR_RGBA} offsetY={60} buttonText={'≡'} buttonTextStyle={mainStyles.menu}>
      <ActionButton.Item buttonColor={SECONDARY_COLOR} title="Logout" onPress={logout}>
        <Icon name='exit-to-app' color='white' size={24} />
      </ActionButton.Item>
    </ActionButton>
  )
}

export default Menu;