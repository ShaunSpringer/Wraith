root = exports ? @


#
# Global Wraith Object
# Used to name space
#
# @include Wraith
@Wraith =
  Controllers: []
  Collections: []
  Models: []
  Templates: []
  Views: []
  UIEvents: ['click', 'dblclick', 'mousedown', 'mouseup', 'mousemove', 'scroll', 'keypress', 'keyup', 'keydown', 'change', 'blur', 'focus']

  #
  # Checks to see if a given object
  # is a funciton.
  # @param [Object] obj The object to test
  #
  isFunction: (obj) -> Object.prototype.toString.call(obj) == '[object Function]'

  #
  # Delays the execution of a function for the
  # given time in ms
  # @param [Number] ms The time to delay in ms
  # @param [Function] func The function to execute after the given time
  #
  delay: (ms, func) -> setTimeout func, ms

  #
  # Compiles a template with Hogan.
  # Note: Override this if you want to use a different
  # template system.
  # @param [String] template The template to compile
  #
  compile: (template) -> Hogan.compile(template)

  #
  # Generates a UID at the desired length
  # @param [Number] length Desired length of the UID
  #
  uniqueId: (length = 16) ->
    id = ""
    id += Math.random().toString(36).substr(2) while id.length < length
    id.substr 0, length

#
# Our bootloader object. This should be
# instantiated after all JS is loaded on the page
#
# @example
#   bootloader = new Wraith.Bootloader
#
# @include Wraith.Bootloader
#
class @Wraith.Bootloader
  #
  # Constructor
  #
  constructor: ->
    $('script[type="text/template"]').forEach (item) => @loadTemplate $(item)
    $('[data-controller]').forEach (item) => @loadController $(item).data('controller'), $(item)

  #
  # Loads a given controller by id and HTML element
  # @param [String] id The controllers id
  # @param [Object] $item The HTML element to bind to
  #
  loadController: (id, $item) ->
    throw Error('Controller does not exist') unless Controller = Wraith.Controllers[id]
    $parent = $item.parent('[data-controller]')
    $parent = undefined if $parent.length is 0
    controller = new Controller($item, $parent)

  #
  # Loads a given template based on the HTML element
  # @param [Object] $template The HTML element to grab the template from
  #
  loadTemplate: ($template) ->
    throw Error('Template is invalid') unless $template
    id = $template.attr('id')
    template = $template.html()
    Wraith.Templates[id] = new Wraith.Template(template)


#
# The base class for all Wraith objects.
# Includes binding to events, and emitting events.
#
# @include Wraith.Base
#
class @Wraith.Base
  #
  # Constructor
  #
  constructor: ->
    @listeners = {}

  #
  # Binds the given function (cb) to the given
  # event (ev)
  # @param [String] ev Event to listen for.
  # @param [Function] cb Callback to be executed on event.
  #
  bind: (ev, cb) =>
    throw Error('Callback is not a function') unless Wraith.isFunction(cb)
    list = @listeners[ev] ?= []
    list.push(cb)
    @

  #
  # Unbinds the given function (cb) from the given
  # event (ev)
  # @param [String] ev Event to unbind.
  # @param [Function] cb Callback to unbind.
  #
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

  remove: (obj) =>
    for item, i in @members when item.get('_id') is obj
      @parent.emit('remove', item)
      @parent.emit('remove:' + @as, item)
      @members.splice(i, 1)
      break

  all: => @members
  length: => @members.length
  at: (index) => @members[index]

  findById: (id) =>
    for item, i in @members when item.get('_id') is id
      return item


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
      @attributes[name] = new Wraith.Collection(@, options.as, options.klass)

  get: (key) =>
    @attributes?[key]

  set: (key, val) =>
    field = @constructor.fields[key]
    throw Error('Trying to set an non-existent property!') unless field
    # Ignore a re-setting of the same value
    return if val == @get(key)
    @attributes[key] = val
    # Emit change events!
    @emit('change', key, val)
    @emit("change:#{key}", val)

  toJSON: =>
    @attributes


class @Wraith.Template extends Wraith.Base
  constructor: (@template) ->
    throw Error('Template is required') unless @template
    @template = @template
    @template_fn = Wraith.compile(@template)

  render: (data) -> @template_fn.render(data.toJSON())


class @Wraith.Controller extends Wraith.Base
  constructor: (@$el, @$parent) ->
    super()
    @model_maps = []
    @models = []
    @init()

  init: ->
    # Find all child views and register them
    @$el.children('[data-template]').forEach (item) =>
      $view = $(item)
      template = $view.attr('data-template')
      model_map = $view.attr('data-map')

      if template and model_map
        @model_maps.push { model_map, template, $view }

    if @events
      for event, i in @view_events
        @bind 'ui:' + event.type + ':' + event.selector, @[event.cb]

  registerModel: (name, model) =>
    throw Error('Model name is already in use') if @models[name]
    @models[name] = model

    # Use the length to know how much to slice off the model string to compare
    l = name.length
    nl = name.toLowerCase()

    # Each model map needs to be registered if applicable
    for map, i in @model_maps when map.model_map[0..l].toLowerCase() is nl + '.'
      mapping = map.model_map[l+1..]
      model.bind 'add:' + mapping, (model) => @add(model, map)
      model.bind 'remove:' + mapping, (model) => @remove(model, map)

  add: (model, map) =>
    return unless $view = map.$view
    return unless template = map.template
    return unless Template = Wraith.Templates[template]

    console.log model
    $view.append(Template.render(model))

    model.bind 'change', => @update(model, map)
    model.bind 'remove', => @remove(model, map)

  remove: (model, map) =>
    $view = map.$view
    $view.remove()

  ###
  update: (model) =>
    $view = $('#' + model.get('_id'))
    $view.replaceWith(@View.render(model))

  append: ($item) =>
    @$el.append($item)

  registerCollection: (key, collection) =>
    @list.bind 'add:items', @add
    @list.bind 'remove:items', @remove
  ###

  findViewOfElement: (el) =>
    return unless $parent = $(el).closest('[wraith-view]')
    return $parent.attr('data-id')

  bind: (ev, cb) =>
    keys = ev.split ':'
    # Format is ui:event:selector
    if keys[0] is 'ui'
      throw Error('Invalid UI event given') unless (uievent = keys[1]) and uievent in Wraith.UIEvents
      throw Error('Invalid selector given') unless (selector = keys[2])
      @$el.on uievent, selector, cb
    else
      super(ev, cb)
