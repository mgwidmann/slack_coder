import React, { Component } from 'react';
import Select from 'react-select';

export default class UserSearch extends Component {
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
