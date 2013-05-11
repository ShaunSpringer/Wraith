root = exports ? @


#
# Global Wraith Object
# Used to name space
#
# @include Wraith
@Wraith =
  Controllers: []
  controllers: {}
  Collections: []
  Models: []
  models: []
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
  # @param [String] prefix A prefix to append to the UID
  # Unfortunately this is here because zepto doesn't like id's
  # in selectors to start with numbers.
  #
  uniqueId: (length = 16, prefix = "wraith-") ->
    id = ""
    id += Math.random().toString(36).substr(2) while id.length < length
    id.substr 0, length
    id = prefix + id
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
    $('[data-view]').forEach (item) => @loadView $(item).data('view'), $(item)

    # Activate our controllers via .init
    for id, controller of Wraith.controllers
      controller.init()
    @
  #
  # Loads a given controller by id and HTML element
  # @param [String] id The controllers id
  # @param [Object] $item The HTML element to bind to
  #
  loadController: (id, $item) ->
    throw Error('Controller does not exist') unless Controller = Wraith.Controllers[id]
    controller = new Controller($item)
    Wraith.controllers[controller.id] = controller

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
  # Loads a given template based on the HTML element
  # @param [Object] $template The HTML element to grab the template from
  #
  loadView: (id, $view) ->
    throw Error('View is invalid') unless View = Wraith.Views[id]

    $controller = $view.parent('[data-controller]')
    throw Error('Views must be defined inside of a controller.') unless $controller.length > 0

    id = $controller.data('id')
    controller = Wraith.controllers[id]
    throw Error('Controller instance not found.') unless controller

    controller.registerView(new View($view))

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
  constructor: -> @listeners = {}

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

  emit: (event, args ...) => if @listeners[event]? then listener(args ...) for listener in @listeners[event]
  @proxy: (func) -> => func.apply(@, arguments)
  proxy: (func) -> => func.apply(@, arguments)

class @Wraith.Validator
  @STRING: 'string'
  @is: (obj, type) -> return if typeof obj is type or obj instanceof type
  @isString: (obj) -> @is(obj, @STRING)


class @Wraith.Collection extends Wraith.Base
  constructor: (@parent, @as, @klass) -> @members = []

  create: (attr) => @add(new @klass(attr))

  add: (item) =>
    @members.push(item)
    @parent.emit('add:' + @as, item)
    item

  remove: (id) =>
    for item, i in @members when item.get('_id') is id
      @parent.emit('remove:' + @as, item)
      @members.splice(i, 1)
      break
    @

  all: => @members
  length: => @members.length
  at: (index) => @members[index]
  findById: (id) => return item for item, i in @members when item.get('_id') is id

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

    Wraith.models[@attributes['_id']] = @

    @

  get: (key) =>
    @attributes?[key]

  set: (key, val) =>
    throw Error('Trying to set an non-existent property!') unless field = @constructor.fields[key]
    # Ignore a re-setting of the same value
    return if val == @get(key)
    @attributes[key] = val
    # Emit change events!
    @emit('change', key, val)
    @emit("change:#{key}", val)

  toJSON: =>
    @attributes

#
# The template handles rendering logic. It calles
# Wraith.compile which depends on Hogan, but if you
# wish to change that just override Wraith.compile
# and use any renderer of your choice.
#
class @Wraith.Template extends Wraith.Base
  #
  # Constructor
  # @param [String] template The template string to register
  #
  constructor: (@template) ->
    throw Error('Template is required') unless @template
    @template = '<div wraith-view data-id="{{_id}}">' + @template + '</div>'
    @template_fn = Wraith.compile(@template)

  #
  # Renders the given data. Expects data to be an object
  # that has a .toJSON method.
  # @param [Object] data The data object to be rendered.
  #
  render: (data) -> @template_fn.render(data.toJSON())

#
# Blah
#
class @Wraith.View extends Wraith.Base
  #
  # Constructor
  #
  constructor: (@$el) ->
    super()
    @model_maps = []
    @init()

  #
  # Initialize the view. This includes crawling the dom
  # for template elements
  #
  init: ->
    # Find all child views and register them
    @$el.find('[data-template]').forEach (item) =>
      $view = $(item)
      template = $view.data('template')
      model_map = $view.data('map')

      if template and model_map
        @model_maps.push { model_map, template, $view }

  createView: (model, map) =>
    return unless $view = map.$view
    return unless template = map.template
    return unless Template = Wraith.Templates[template]

    $view.append(Template.render(model))
    model.bind 'change', => @updateView(model, map)

  updateView: (model, map) =>
    return unless $view = map.$view
    return unless template = map.template
    return unless Template = Wraith.Templates[template]

    $view = $('[data-id=' + model.get('_id') + ']')
    $view.replaceWith(Template.render(model))

  removeView: (model, map) =>
    $view = $('[data-id=' + model.get('_id') + ']')
    $view.remove()

#
# The proverbial 'controller' in the MVC pattern.
# The Controller handles the logic your applications or
# components may have. This controller handles automatical registration
# and mapping of models to views.
#
# @include Wraith.Controller
# @extends Wraith.Base
# @example Example markup in HTML.
#   This will create a SelectList controller
#   and then create a view using the template with id "ListItem"
#   mapping to the model list.items (belonging to SelectList)
#
#   <ul data-view="SelectList">
#     <div data-template="ListItem" data-map="list.items"></div>
#   </ul>
#
class @Wraith.Controller extends Wraith.Base
  #
  # Constructor
  #
  constructor: (@$el) ->
    super()
    @id = Wraith.uniqueId()
    @$el.data 'id', @id
    @models = []
    @views = []
    @$els = []

  init: ->
    @loadViewEvents()
    @loadElements()

  loadViewEvents: ->
    if @view_events
      for event, i in @view_events
        @bind 'ui:' + event.type + ':' + event.selector, @[event.cb]
    @

  loadElements: ->
    els = @$el.find('[data-element]')
    for el, i in els when el.id
      @$els[el.id] = $(el)?[0]
    @

  registerModel: (name, model) =>
    throw Error('Model name is already in use') if @models[name]
    @models[name] = model

    # Use the length to know how much to slice off the model string to compare
    l = name.length
    nl = name.toLowerCase()

    # Iterate over all our views, and see if the
    for view, i in @views
      # Each model map needs to be registered if applicable
      model_maps = view.model_maps
      for map, j in model_maps when map.model_map[0..l].toLowerCase() is nl + '.'
        mapping = map.model_map[l+1..]
        if model.get(mapping) instanceof Wraith.Collection
          model.bind 'add:' + mapping, (model) => view.createView(model, map)
          model.bind 'remove:' + mapping, (model) => view.removeView(model, map)
        else
          model.bind 'change', (model) => view.updateView(model, map)
    @

  registerView: (view) => @views.push view
  findViewByElement: (el) => return $(el).closest('[wraith-view]')
  findIdByView: (el) => return $(el).data('id')
  findModelById: (id) => Wraith.models[id]

  bind: (ev, cb) =>
    keys = ev.split ':'
    # Format is ui:event:selector
    if keys[0] is 'ui'
      throw Error('Invalid UI event given') unless (uievent = keys[1]) and uievent in Wraith.UIEvents
      throw Error('Invalid selector given') unless (selector = keys[2])
      @$el.on uievent, selector, (e) =>
        $view = @findViewByElement e.currentTarget
        id = @findIdByView $view
        model = @findModelById id
        cb.apply(@, [e, $view, model])
    else
      super(ev, cb)
