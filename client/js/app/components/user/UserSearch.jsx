import React, { Component } from 'react';
import Select from 'react-select';

export default class UserSearch extends Component {
  constructor(props) {
    super(props);
    this.state = { value: null };
  }

  getUsers(input) {
    if (!input) {
      return Promise.resolve({ options: [] });
    }
    const { search } = this.props;
    return search(input).then((json) => {
      return { options: json.data.users.entries };
    });
  }

  render() {
    let { initial, multiple } = this.props;
    let value = this.state.value || initial;
    return (
      <Select.Async
        value={value}
        onChange={(v) => this.setState({ value: v })}
        loadOptions={::this.getUsers}
        valueKey="github"
        labelKey="name"
        multi={multiple}
      />
    )
  }
}
