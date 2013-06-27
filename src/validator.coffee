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
  isValid: (str) =>
    isValid = str.match('^.{' + (@min || 0) + ',' + (@max || '') + '}$') isnt null
    return true if isValid
    return 'String must be a minimum of ' + @min + ' characters and a maximum of ' + @max + ' characters long.'


