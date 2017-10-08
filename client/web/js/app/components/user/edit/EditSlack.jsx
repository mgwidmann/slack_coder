import React, { Component } from 'react';
import PropTypes from 'prop-types';

class EditSlack extends Component {
  getValue() {
    return this._slack.value;
  }

  render() {
    let { github, slack } = this.props;
    return (
      <div>
        <h4>Slack Info</h4>
        <label htmlFor="slack" className="control-label">Slack</label>
        <input ref={(i) => { this._slack = i; }} id="slack" className="form-control" placeholder={github} defaultValue={slack} />
        <p className="help-block">Enter your name on slack without the @</p>
      </div>
    )
  }
}

EditSlack.propTypes = {
  slack: PropTypes.string,
  github: PropTypes.string
};

export default EditSlack;
