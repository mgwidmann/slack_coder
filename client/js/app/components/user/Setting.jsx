import React from 'react';

export default ({ setting, label, value }) => {
  console.log("Setting:", setting, "with value", value);
  return (
    <label htmlFor={setting}>
      <input type="checkbox" id={setting} defaultChecked={value} />
      &nbsp;
      {label}
    </label>
  )
}
