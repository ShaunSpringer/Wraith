#
# The core validator used to validated Models.
# Defined on the model through the @field method like so:
# @example
#   class App.Model extends Wraith.Model
#     @field 'text', { default: '', type: Wraith.Validators.String,  max: 30, min: 2 }
#
class Wraith.Validator extends Wraith.Base
  validate: (str) -> throw 'Override the validate function!'

class Wraith.Validators.Text extends Wraith.Validator
  constructor: ({ @min, @max }) -> @
  isValid: (content) =>
    isValid = content.match('^.{' + (@min || 0) + ',' + (@max || '') + '}$') isnt null
    return true if isValid
    return 'String must be between ' + @min + ' and ' + @max + ' characters long.'

class Wraith.Validators.Num extends Wraith.Validator
  constructor: ({ @min, @max }) ->
    @min ?=  Number.MIN_VALUE
    @max ?=  Number.MAX_VALUE
    @
  isValid: (content) =>
    isValid = Number(content)
    return true if isValid and @min <= content <= @max
    return 'Number must be between ' + @min + ' and ' + @max + '.'


