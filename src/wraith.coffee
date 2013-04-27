root = exports ? @

@Wraith =
  Controllers: []
  Collections: []
  Models: []
  Templates: []
  Views: []
  isFunction: (obj) ->
    Object.prototype.toString.call(obj) == '[object Function]'
  delay: (ms, func) ->
    setTimeout func, ms
  compile: (template) ->
    Hogan.compile(template)
  uniqueId: (length = 16) ->
    id = ""
    id += Math.random().toString(36).substr(2) while id.length < length
    id.substr 0, length

class @Wraith.Bootloader
  constructor: ->
    $('script[type="text/template"]').forEach (item) => @loadTemplate $(item)
    $('[data-controller]').forEach (item) => @loadController $(item).data('controller'), $(item)

  loadController: (id, $item) ->
    throw Error('Controller does not exist') unless Controller = Wraith.Controllers[id]
    controller = new Controller($item)

  loadTemplate: ($template) ->
    throw Error('Template is invalid') unless $template
    id = $template.attr('id')
    template = $template.html()
    Wraith.Views[id] = new Wraith.View(template)


class @Wraith.Base
  constructor: ->
    @listeners = {}

  bind: (ev, cb) =>
    list = @listeners[ev] ?= []
    list.push(cb)
    @

  unbind: (ev, cb) =>
    list = @listeners?[ev]
    for callback, i in list when callback is cb
      list.slice()
      list.splice(i, 1)
      @listeners[ev] = list
      break
    @

  emit: (event, args ...) =>
    if @listeners[event]? then listener(args ...) for listener in @listeners[event]

  @proxy: (func) ->
    =>
      func.apply(@, arguments)

  proxy: (func) ->
    =>
      func.apply(@, arguments)


class @Wraith.Validator
  @STRING: 'string'

  @is: (obj, type) ->
    return true if typeof obj is type or obj instanceof type
    false

  @isString: (obj) ->
    @is(obj, @STRING)


class @Wraith.Collection extends Wraith.Base
  constructor: (@parent, @as, @klass) ->
    @members = []

  create: (attr) =>
    @add(new @klass(attr))

  add: (item) =>
    @members.push(item)
    @parent.emit('add:' + @as, item)
    item

  remove: (item) =>
    for t, i in @members when t == thing
      delete @members[i]
      @parent.emit('remove:' + @as, thing)
      break

  all: =>
    @members

  length: =>
    @members.length

  at: (index) =>
    @members[index]


class @Wraith.Model extends Wraith.Base
  @field: (name, opt) ->
    @fields ?= {}
    @fields[name] = options ? {}

  @hasMany: (klass, options) ->
    options ?= {}
    options.klass ?= klass
    @collections ?= {}
    @collections[options.as] = options

  constructor: (attributes) ->
    super()

    # Create unique ID if one doesnt exist
    # Could use a refactor
    @constructor.fields ?= {}
    @constructor.fields['_id'] = { default: Wraith.uniqueId } unless attributes?['_id']

    @listeners = {}
    @attributes = {}
    for name, options of @constructor.fields
      if attributes?[name]?
        d = attributes?[name]
      else
        d = if (Wraith.isFunction(options.default)) then options.default() else options.default
      @set name, d

    for name, options of @constructor.collections
      @[name] = new Wraith.Collection(@, options.as, options.klass)

  get: (key) =>
    @attributes?[key]

  set: (key, val) =>
    field = @constructor.fields[key]
    throw Error('Trying to set an non-existent property!') if not field
    # Ignore a re-setting of the same value
    return if val == @get(key)
    @attributes[key] = val
    # Emit change events!
    @emit('change', key, val)
    @emit("change:#{key}", val)

  toJSON: =>
    @attributes

class @Wraith.View extends Wraith.Base
  constructor: (@template) ->
    throw Error('Template is required') unless @template
    @template = '<div id="{{_id}}">' + @template + '</div>'
    @template_fn = Wraith.compile(@template)

  render: (data) ->
    @template_fn.render(data.toJSON())

class @Wraith.Controller extends Wraith.Base
  constructor: (@$el) ->
    super()
    @init()

  init: ->
    @View = Wraith.Views[@view]

  add: (model) =>
    @append(@View.render(model))
    model.bind 'change', =>
      @update(model)

  update: (model) =>
    $view = $('#' + model.get('_id'))
    $view.html(@View.render(model))

  append: ($item) =>
    @$el.append($item)
