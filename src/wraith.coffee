root = exports ? @


#
# Global Wraith Object
# Used to name space
#
# @include Wraith
#
@Wraith =
  DEBUG: true
  Controllers: []
  controllers: {}
  Collections: {}
  Models: {}
  models: {}
  Templates: {}
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
  # Borrowed from Underscores ERB-style templates
  # @param [String] string The string to escape
  #
  escapeRegExp: (string) -> string.replace(/([.*+?^${}()|[\]\/\\])/g, '\\$1')

  #
  # This is partly borrowed from underscores ERB-style template
  # settings.
  #
  templateSettings:
    start:        '{{'
    end:          '}}'
    interpolate:  /{{(.+?)}}/g
    checked:  /data-checked=['"](.+?)['"]/g


  #
  # Compiles a template with a ERB style markup.
  # Note: Override this if you want to use a different
  # template system.
  #
  # NOTE:
  # JavaScript templating a-la **ERB**, pilfered from John Resig's
  # *Secrets of the JavaScript Ninja*, page 83.
  # Single-quote fix from Rick Strahl.
  # With alterations for arbitrary delimiters, and to preserve whitespace.
  #
  # @param [String] template The template to compile
  #
  compile: (template) ->
    c = Wraith.templateSettings
    endMatch = new RegExp("'(?=[^" + c.end.substr(0, 1) + "]*" + Wraith.escapeRegExp(c.end) + ")", "g")
    fn = new Function 'obj',
      'var p=[],print=function(){p.push.apply(p,arguments);};' +
      'with(obj||{}){p.push(\'' +
      template.replace(/\r/g, '\\r')
      .replace(/\n/g, '\\n')
      .replace(/\t/g, '\\t')
      .replace(endMatch, "✄")
      .split("'").join("\\'")
      .split("✄").join("'")
      .replace(c.interpolate, "' + ((hasOwnProperty('get') && get(\'$1\')) || $1) + '")
      .replace(c.checked, "' + ((hasOwnProperty('get') && get(\'$1\') === true) ? 'checked' : \'\') + '")
      .split(c.start).join("');")
      .split(c.end).join("p.push('") +
      "');}return p.join('');"

    return fn

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
    controllers = document.querySelectorAll('[data-controller]')
    for $controller in controllers
      @loadController $controller.attributes['data-controller'].value, $controller


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

  #
  # Emits the given event to listneers
  # @param [String] event The name of the event to emit
  # @param [Object] args The data object to emit
  #
  emit: (event, args ...) =>
    if @listeners[event]?
      listener(args ...) for listener in @listeners[event]
    @


class @Wraith.Validator
  @STRING: 'string'
  @is: (obj, type) -> return if typeof obj is type or obj instanceof type
  @isString: (obj) -> @is(obj, @STRING)


class @Wraith.Model extends @Wraith.Base
  @field: (name, opt) ->
    @fields ?= {}
    @fields[name] = opt ? {}

  @hasMany: (klass, opt) ->
    opt ?= {}
    opt.klass ?= klass
    @collections ?= {}
    @collections[opt.as] = opt

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

  get: (key) => @attributes?[key]

  set: (key, val) =>
    throw Error('Trying to set an non-existent property!') unless field = @constructor.fields[key]
    # Ignore a re-setting of the same value
    return if val == @get(key)
    @attributes[key] = val
    # Emit change events!
    @emit('change', key, val)
    @emit("change:#{key}", val)

  toJSON: => @attributes

class @Wraith.Collection extends @Wraith.Model
  constructor: (@parent, @as, @klass) ->
    super()
    @members = []

  create: (attr) => @add(new @klass(attr))

  add: (item) =>
    @members.push(item)
    @parent.emit('add:' + @as, item)
    @parent.emit('change:' + @as, @)
    item

  remove: (id) =>
    for item, i in @members when item.get('_id') is id
      @members.splice(i, 1)
      @parent.emit('remove:' + @as, item)
      @parent.emit('change:' + @as, @)
      break
    @

  all: => @members
  length: => @members.length
  at: (index) => @members[index]
  findById: (id) => return item for item, i in @members when item.get('_id') is id

#
# The template handles rendering logic. It calles
# Wraith.compile which depends on Hogan, but if you
# wish to change that just override Wraith.compile
# and use any renderer of your choice.
#
class @Wraith.Template extends @Wraith.Base
  #
  # Constructor
  # @param [String] template The template string to register
  #
  constructor: (@template) ->
    if Wraith.DEBUG then console.log '@Wraith.Template', 'constructor'

    throw Error('Template is required') unless @template
    @template_fn = Wraith.compile(@template)

  #
  # Renders the given data. Expects data to be an object
  # that has a .toJSON method.
  # @param [Object] data The data object to be rendered.
  # @return [String] The result of the execution of the template function
  #
  render: (data) -> @template_fn(data)

#
# The core Wraith View responsible for rendering a single
# instance of a view. It will bind to a models update event
# and re-render each time it changes
#
class @Wraith.View extends @Wraith.Base
  #
  # Constructor
  # @param [HTMLElement] $el The HTML Element to attach the view to
  # @param [String] template The template string to use when rendering
  #
  constructor: (@$el, @template) ->
    if Wraith.DEBUG then console.log '@Wraith.View', 'constructor'
    throw new Error('Element is required by View') unless @$el
    throw new Error('Template is required by View') unless @template

    super()

    @id = Wraith.uniqueId()
    @$parent = @$el.parentNode

    Wraith.Templates[@template] ?= new Wraith.Template(template)
    @Template = Wraith.Templates[@template]

  #
  # Renders the view given a Wraith.Model object
  # @param [Wraith.Model] model The model to render
  # @returns [HTMLElement] A HTMLElement from the resulting render
  #
  render: (model) ->
    rendered = @Template.render(model)
    $el = document.createElement('div')
    $el.innerHTML = rendered
    $el = $el.firstChild
    return $el

  updateView: (model) ->
    $view = @render(model)
    @$parent.replaceChild($view, @$el)
    @$el = $view
    @$el.setAttribute('data-model', model.get('_id'))
    @bindEvents $view, model

  bindEvents: ($view, model) =>
    @bindTo $view, $view.attributes['data-events'].value, model if $view.attributes['data-events']

    els = $view.querySelectorAll('[data-events]')
    @bindTo $el, $el.attributes['data-events'].value, model for $el in els
    @

  bindTo: ($view, event, model) =>
    events = event.split(/[,\s?]/)
    for event in events
      eventArr = event.split(':')
      continue if eventArr.length isnt 2
      name = eventArr[0]
      cb = eventArr[1]
      continue if not name in Wraith.UIEvents
      $view.addEventListener name, (e) => @emit 'uievent', e, cb
    @

class @Wraith.RepeatingView extends @Wraith.View
  #
  # Constructor
  #
  constructor: (@$el, @template) ->
    if Wraith.DEBUG then console.log '@Wraith.RepeatingView', 'constructor'

    super(@$el, @template)

    @$parent.innerHTML = ''

    Wraith.Templates[@template] ?= new Wraith.Template(template)
    @Template = Wraith.Templates[@template]

  render: (model) ->
    rendered = @Template.render(model)
    $el = document.createElement('div')
    $el.innerHTML = rendered
    return $el

  createView: (model) ->
    return unless model instanceof Wraith.Model
    $el = @render(model)
    return unless $node = $el.firstChild
    $node.setAttribute('data-id', Wraith.uniqueId())
    $node.setAttribute('data-model', model.get('_id'))
    $view = $el.firstChild
    @$parent.appendChild $view
    @bindEvents $view

  removeView: (model) ->
    return unless model instanceof Wraith.Model
    $el = @$parent.querySelector('[data-model=' + model.get('_id') + ']')
    @$parent.removeChild $el

  updateView: (model) ->
    return unless $oldView = @$parent.querySelector('[data-model=' + model.get('_id') + ']');
    $el = @render(model)
    return unless $node = $el.firstChild
    $node.setAttribute('data-id', Wraith.uniqueId())
    $node.setAttribute('data-model', model.get('_id'))
    @$parent.replaceChild($node, $oldView)
    @bindEvents $node

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
class @Wraith.Controller extends @Wraith.Base
  #
  # Constructor
  #
  constructor: (@$el) ->
    if Wraith.DEBUG then console.log '@Wraith.Controller', 'constructor'

    super()
    @id = Wraith.uniqueId()
    @$el.setAttribute('data-id', @id)
    @models = []
    @views = []
    @bindings = []

  #
  # Initialize our controller
  #
  init: ->
    if Wraith.DEBUG then console.log '@Wraith.Controller', 'init'
    @findViews()

  #
  # Find all the views embedded inside the controller and
  # register them with the controller
  #
  findViews: ->
    # Anything with a bind attribute is considered a view
    views = document.querySelectorAll('[data-bind]')
    @registerView $view for $view in views
    @

  #
  # Register the view to this controller
  # @param [HTMLElement] $view The view to be registered
  #
  registerView: ($view) ->
    # Unless we have a binding attribute we cant be a view!
    return unless binding = $view.attributes['data-bind']?.value

    # Split our map on a period for dotnotation
    maps = binding.split('.')

    # If no map is present, return early
    return unless targetModel = maps[0]

    # If we have a repeat tag we will need to treat this view differently
    repeating = $view.attributes['data-repeat'] isnt undefined
    templateId = $view.attributes['data-template']?.value

    # Yank our template out of the dom
    if templateId isnt undefined
      return unless template = document.getElementById(templateId)?.innerHTML
    else
      template = $view.outerHTML

    # Unescape our template via textarea hack
    textbox = document.createElement('textarea')
    textbox.innerHTML = template
    template = textbox.value

    if repeating
      view = new Wraith.RepeatingView($view, template)
    else
      view = new Wraith.View($view, template)

    # Listen for uievents from the view
    view.bind 'uievent', @handleUIEvent

    @views.push view
    @bindings[targetModel] ?= []
    @bindings[targetModel].push {binding, view}
    @

  #
  # Register the model to this controller
  # @param [String] as The name of the model to register
  # @param [Wraith.Model] model The model to register to this controller
  #
  registerModel: (as, model) ->
    throw new Error('Model name already registered') if @models[as]
    throw new Error('Model is not valid') if not model instanceof Wraith.Model
    @models[as] = model
    @bindViews(as, model)

  #
  # Binds any view that is loaded into the controller
  # to the given model.
  # @param [String] name The name of the model to bind to
  # @param [Wraith.Model] model The model to map the namespace to
  #
  bindViews: (name, model) ->
    return unless bindings = @bindings[name]
    @bindView(model, map.binding, map.view) for map in bindings
    @

  #
  # Binds a single instance of a view to a model.
  # Usings binding as the dot notation map
  # @TODO Make this work for more than 1 level
  # @param [Wraith.Model] model The model to bind to
  # @param [String] binding The dot notation binding (first item should be the model name)
  # @param [Wraith.View|Wraith.RepeatingView] view The view object to bind to.
  #
  bindView: (model, binding, view) ->
    mapping = binding.split('.')
    map = mapping[1]

    if map and view instanceof Wraith.RepeatingView
      model.bind 'add:' + map, (model_) ->
        view.createView(model_)
        model_.bind 'change', -> view.updateView(model_)
      model.bind 'remove:' + map, (model_) -> view.removeView(model_)
    else if map
      model.bind 'change:' + map, (model_) -> view.updateView(model_)

  #
  # This is a wrapper for any UI event happening on views in this
  # controller. We do this so we can do a lookup of the model and pass
  # it through with the event
  # @param [Event] e The native event object
  # @param [String] cb The name of the callback function to call
  #
  handleUIEvent: (e, cb) =>
    e.model = @getModelFromEl e.target
    @[cb]?(e)


  #
  # Traverses the dom upwards to find the first model it encounters
  # If no model is found, it will return null
  # @param [HTMLElement] $el The element from which to start the traversal
  #
  getModelFromEl: ($el) =>
    while $el
      console.log $el
      break if modelId = $el.attributes['data-model']?.value
      $el = $el.parentNode

    Wraith.models[modelId]
