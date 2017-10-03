import React from 'react';
import PropTypes from 'prop-types';
import QRCode from 'qrcode.react';

const MobileLogin = ({ token }) => {
  return (
    <div className="text-center">
      <h1>Scan with the mobile app to log in</h1>
      <br/>
      <QRCode value={token} size={384} />
    </div>
  );
}

MobileLogin.propTypes = {
  token: PropTypes.string.isRequired
}

export default MobileLogin;
