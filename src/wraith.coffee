root = exports ? @
@Wraith = {}

class @Wraith.Bootloader
  constructor: ->
    self = @
    $('script[type="text/template"]')
      .forEach (view) ->
        self.load $(view).attr('id')

  load: (id) ->
    $view = $('#' + id)
    throw Error('Controller does not exist') unless controller = $view.data('controller')
    throw Error('Model does not exist') unless model = $view.data('model')
    Model = root.Models[model]
    view = new Wraith.View($view.html())
    Controller = root.Controllers[controller]
    new Controller(Model, view)


class @Wraith.Base
  constructor: ->
    @listeners = {}

  bind: (ev, cb) ->
    list = @listeners[ev] ?= []
    list.push(cb)

  unbind: (ev, cb) ->
    list = @listeners?[ev]
    for callback, i in list when callback is cb
      list.slice()
      list.splice(i, 1)
      @listeners[ev] = list
      break
    @

  emit: (event, args ...) ->
     if @listeners[event] then listener(args ...) for listener in @listeners[event]

  @proxy: (func) ->
    => func.apply(@, arguments)

  proxy: (func) ->
    => func.apply(@, arguments)


class @Wraith.Validator
  @STRING: 'string'

  @is: (obj, type) ->
    return true if typeof obj is type or obj instanceof type
    false

  @isString: (obj) ->
    @is(obj, @STRING)

class @Wraith.Model extends Wraith.Base
  @field: (name, opt) ->
    return unless Wraith.Validator.isString(name)
    @fields ?= {}
    @fields[name] = options ? {}

  constructor: (@attributes) ->

  get: (key) =>
    @attributes?[key]

  set: (key, val) =>
    throw Error('Attribute does not exist on model') if not @attributes[key]
    @attributes[key] = val


class @Wraith.Collection extends Wraith.Base
  constructor: (@parent, { as: @field, klass: @klass }) ->
    @members = []


class @Wraith.Model.Ajax extends Wraith.Model
  constructor: (@attributes, @url) ->
    super(@attributes)


class @Wraith.View extends Wraith.Base
  constructor: (@template) ->


class @Wraith.Controller extends Wraith.Base
  constructor: (@model, @view) ->
    throw Error('Model is required') unless @model
    throw Error('View is required') unless @view

    super()
