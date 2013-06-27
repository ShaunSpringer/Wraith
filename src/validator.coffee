#
# The core validator used to validated Models.
# Defined on the model through the @field method like so:
# @example
#   class App.Model extends Wraith.Model
#     @field 'text', { default: '', type: Wraith.Validators.String,  max: 30, min: 2 }
#
class Wraith.Validator extends Wraith.Base
  @validate: (contents) -> throw 'Override the validate function!'

Wraith.Validators = {}
class Wraith.Validators.String extends Wraith.Validator
  @validate: (contents, { min, max }) -> return contents.match('(.*){' + min + ',' + max + '}') isnt null

