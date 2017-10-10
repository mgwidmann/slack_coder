import React, { Component } from 'react';
import PropTypes from 'prop-types';
import Select from 'react-select';

class UserSearch extends Component {
  constructor(props) {
    super(props);
    this.state = { value: this.props.initial || [] };
  }

  getUsers() {
    return this.state.value;
  }

  searchUsers(input) {
    if (!input) {
      return Promise.resolve({ options: [] });
    }
    const { search } = this.props;
    return search(input).then((json) => {
      return { options: json.data.users.entries };
    });
  }

  render() {
    let { multiple } = this.props;
    let value = this.state.value;
    return (
      <Select.Async
        value={value}
        onChange={(v) => this.setState({ value: v })}
        loadOptions={::this.searchUsers}
        valueKey="github"
        labelKey="name"
        multi={multiple}
      />
    )
  }
}

UserSearch.propTypes = {
  initial: PropTypes.arrayOf(PropTypes.shape({
    name: PropTypes.string.isRequired,
    github: PropTypes.string.isRequired
  })),
  multiple: PropTypes.bool,
  search: PropTypes.func.isRequired
}

export default UserSearch;
