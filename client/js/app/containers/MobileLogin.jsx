import React, { Component } from 'react';
import QRCode from 'qrcode.react';

export default class MobileLogin extends Component {
  render() {
    const { token } = this.props;
    return (
      <div className="text-center">
        <h1>Scan with the mobile app to log in</h1>
        <br/>
        <QRCode value={token} size={384} />
      </div>
    );
  }
}
