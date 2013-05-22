root = exports ? @


#
# Global Wraith Object
# Used to name space
#
# @include Wraith
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

  # Helper function to escape **RegExp** contents, because JS doesn't have one.
  escapeRegExp: (string) -> string.replace(/([.*+?^${}()|[\]\/\\])/g, '\\$1')

  # By default, Underscore uses **ERB**-style template delimiters, change the
  # following template settings to use alternative delimiters.
  templateSettings:
    start:        '{{'
    end:          '}}'
    interpolate:  /{{(.+?)}}/g
    checked:  /data-checked=['"](.+?)['"]/g

  #
  # Compiles a template with a coffee-script compiler.
  # Note: Override this if you want to use a different
  # template system.
  # @param [String] template The template to compile
  #
  compile: (template) ->
  # JavaScript templating a-la **ERB**, pilfered from John Resig's
  # *Secrets of the JavaScript Ninja*, page 83.
  # Single-quote fix from Rick Strahl.
  # With alterations for arbitrary delimiters, and to preserve whitespace.
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

  emit: (event, args ...) =>
    if @listeners[event]?
      listener(args ...) for listener in @listeners[event]
    @


class @Wraith.Validator
  @STRING: 'string'
  @is: (obj, type) -> return if typeof obj is type or obj instanceof type
  @isString: (obj) -> @is(obj, @STRING)


class @Wraith.Collection extends @Wraith.Base
  constructor: (@parent, @as, @klass) -> @members = []

  create: (attr) => @add(new @klass(attr))

  add: (item) =>
    @members.push(item)
    @parent.emit('change:' + @as, @)
    @parent.emit('add:' + @as, item)
    item

  remove: (id) =>
    for item, i in @members when item.get('_id') is id
      @parent.emit('change:' + @as, @)
      @parent.emit('remove:' + @as, item)
      @members.splice(i, 1)
      break
    @

  all: => @members
  length: => @members.length
  at: (index) => @members[index]
  findById: (id) => return item for item, i in @members when item.get('_id') is id


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
  constructor: (@template, wrap = false) ->
    if Wraith.DEBUG then console.log '@Wraith.Template', 'constructor'

    throw Error('Template is required') unless @template
    if wrap then @template = '<div wraith-view data-id="<%=get("_id")%>">' + @template + '</div>'
    @template_fn = Wraith.compile(@template)

  #
  # Renders the given data. Expects data to be an object
  # that has a .toJSON method.
  # @param [Object] data The data object to be rendered.
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

  render: (model) ->
    rendered = @Template.render(model)
    $el = document.createElement('div')
    $el.innerHTML = rendered
    return $el.firstChild

  updateView: (model) ->
    $el = @render(model)
    @$parent.replaceChild($el, @$el)
    @$el = $el


class @Wraith.RepeatingView extends @Wraith.Base
  #
  # Constructor
  #
  constructor: (@$parent, @template) ->
    if Wraith.DEBUG then console.log '@Wraith.RepeatingView', 'constructor'
    throw new Error('Parent is required by RepeatingView') unless @$parent
    throw new Error('Template is required by RepeatingView') unless @template

    @id = Wraith.uniqueId()
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
    if $node = $el.firstChild
      $node.setAttribute('data-id', Wraith.uniqueId())
      $node.setAttribute('data-model', model.get('_id'))
      @$parent.appendChild $el.firstChild

  updateView: (model) ->
    return unless $view = @$parent.querySelector('[data-id=' + model.get('_id') + ']');
    $el = @render(model)
    @$parent.replaceChild($el, $view)
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
    @$el.setAttribute('id', @id)
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
      view = new Wraith.RepeatingView($view.parentNode, template, binding)
    else
      view = new Wraith.View($view, template)

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
  #
  bindViews: (name, model) ->
    return unless bindings = @bindings[name]

    @bindView(model, map) for map in bindings
    @

  bindView: (model, map) ->
    binding = map.binding
    view = map.view
    mapping = binding.split('.')

    if view instanceof Wraith.RepeatingView
      if mapping[1]
        model.bind 'add:' + mapping[1], (model_) -> view.createView(model_)
        model.bind 'remove:' + mapping[1], (model_) -> view.removeView(model_)
        #model.bind 'change:' + mapping[1], (model_) -> view.updateView(model_)
    else
      if mapping[1]
          model.bind 'change:' + mapping[1], (model_) -> view.updateView(model_)
