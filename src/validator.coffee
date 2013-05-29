#
# Provides Model validation
#
class Wraith.Validator
  @STRING: 'string'
  @is: (obj, type) -> return if typeof obj is type or obj instanceof type
  @isString: (obj) -> @is(obj, @STRING)
