#let padLeft(value, padCharacter, length) = {
  let stringValue = str(value)

  for _ in range(stringValue.len(), length) {
    stringValue = str(padCharacter) + stringValue
  }

  return stringValue
}

#let id(count, ..args) = {
  return args.at("prefix", default: "") + padLeft(count, "0", args.at("length", default: 2))
}
