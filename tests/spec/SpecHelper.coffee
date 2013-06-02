beforeEach ->
  @addMatchers
    toBeFunction: -> return typeof(this.actual) is 'function'
    toExist: -> this.actual isnt null
