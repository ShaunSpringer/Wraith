class Controller
  constructor: ->

class Model
  @field: (name, opt) ->
    @fields ?= {}
    @fields[name] = options ? {}

  constructor: (@attributes) ->

  get: (key) =>
    @attributes?[key]

  set: (key, val) =>
    throw Error('Attribute does not exist on model') if not @attributes[key]
    @attributes[key] = val

