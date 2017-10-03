export function setImmutable(key, value) {
  return {
    type: 'SET',
    key: key,
    value: value
  };
}
