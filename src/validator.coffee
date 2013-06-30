#
# The core validator used to validated Models. Really just supplies an
# interface, for now.
#
# Defined on the model through the @field method like so:
# @example
#   class App.Model extends Wraith.Model
#     @field 'text', { default: '', type: new Wraith.Validators.String{ min: 2, max: 30 } }
#
class Wraith.Validator
  #
  # Takes in a string|object and runs validation on it. Returns
  # true if valid or a string containing the error description if
  # false. Meant to be overridden.
  #
  # @param [String|Object] content The string or object to be validated
  #
  # @return [Boolean|String] True if valid or a string with an error message if not.
  #
  isValid: (content) -> throw 'Override the validate function!'

#
# Validates Text. Will accept any string with a length
# greater than or equal min and less than or equal to max.
#
class Wraith.Validators.Text extends Wraith.Validator
  #
  # Creates an instance of the validator.
  #
  constructor: ({ @min, @max }) ->
    @min ?=  0
    @max ?=  Number.MAX_VALUE
    @

  #
  # @inheritDoc
  #
  isValid: (content) =>
    isValid = content.match('^.{' + (@min || 0) + ',' + (@max || '') + '}$') isnt null
    return true if isValid
    return 'String must be between ' + @min + ' and ' + @max + ' characters long.'

class Wraith.Validators.Num extends Wraith.Validator
  #
  # Creates an instance of the validator.
  #
  constructor: ({ @min, @max }) ->
    @min ?=  Number.MIN_VALUE
    @max ?=  Number.MAX_VALUE
    @

  #
  # @inheritDoc
  #
  isValid: (content) =>
    num = Number(content)
    return true if content isnt '' and not isNaN(num) and @min <= num <= @max
    return 'Number must be between ' + @min + ' and ' + @max + '.'
