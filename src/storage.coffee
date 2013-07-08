class Wraith.Storage.Local extends Wraith.Base
  constructor: (@model) ->
    console.log 'here---'
    return unless localStorage
    @model.bind('change', @update)

  update: =>
    return if not @model.isValid()

    obj = localStorage[@model.constructor.name] or '{}'
    obj = JSON.parse(obj)
    obj[@model.get('_id')] = @model.toJSON()
    localStorage[@model.constructor.name] = JSON.stringify(obj)


