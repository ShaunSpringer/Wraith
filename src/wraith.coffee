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
    start:        '<%'
    end:          '%>'
    interpolate:  /<%=(.+?)%>/g

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
      .replace(c.interpolate, "',$1,'")
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
    $('script[type="text/template"]').forEach (item) => @loadTemplate $(item)
    $('[data-controller]').forEach (item) => @loadController $(item).data('controller'), $(item)

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


class @Wraith.Validator
  @STRING: 'string'
  @is: (obj, type) -> return if typeof obj is type or obj instanceof type
  @isString: (obj) -> @is(obj, @STRING)


class @Wraith.Collection extends Wraith.Base
  constructor: (@parent, @as, @klass) -> @members = []

  create: (attr) => @add(new @klass(attr))

  add: (item) =>
    @members.push(item)
    @parent.emit('change')
    @parent.emit('add:' + @as, item)
    item

  remove: (id) =>
    for item, i in @members when item.get('_id') is id
      @parent.emit('change')
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
class @Wraith.Template extends Wraith.Base
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
# Blah
#
class @Wraith.View extends Wraith.Base
  #
  # Constructor
  #
  constructor: (@$el) ->
    if Wraith.DEBUG then console.log '@Wraith.View', 'constructor'
    super()
    @id = Wraith.uniqueId()

  createView: (model, map) =>
    if Wraith.DEBUG then console.log '@Wraith.View', 'createView'

    return unless $view = map.$view
    return unless template = map.template
    if not Template = Wraith.Templates[template]
      Template = Wraith.Templates[template] = new Wraith.Template(template, false)
      $view.replaceWith(Template.render(model))
      replace = true
    else
      $view.append(Template.render(model))

    ((model, map) =>
      model.bind 'change', (model_) => @updateView(model, map, replace)
    )(model, map)

    @updateView(model, map, replace)

  updateView: (model, map, replace = false) =>
    if Wraith.DEBUG then console.log '@Wraith.View', 'updateView'

    return unless $view = map.$view
    return unless template = map.template
    return unless Template = Wraith.Templates[template]

    $view_ = $('[data-id=' + model.get('_id') + ']')

    $view.replaceWith(Template.render(model))

  removeView: (model, map) =>
    if Wraith.DEBUG then console.log '@Wraith.View', 'removeView'

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
    if Wraith.DEBUG then console.log '@Wraith.Controller', 'constructor'

    super()
    @id = Wraith.uniqueId()
    @$el.data 'id', @id
    @models = []
    @views = []
    @$els = []
    @maps = []

  init: ->
    if Wraith.DEBUG then console.log '@Wraith.Controller', 'init'

    @loadViews()
    @loadViewEvents()
    @loadElements()

  loadViews: ->
    if Wraith.DEBUG then console.log '@Wraith.Controller', 'loadViews'

    @$el.find('[data-map]').forEach (item) =>
      $view = $(item)
      template = $view.data('template')
      if not template
        u = document.createElement("textarea")
        u.innerHTML = $view[0].outerHTML
        template = u.value

      model_map = $view.data('map')
      return unless model_map
      map = { model_map, template, $view }
      view = new Wraith.View($view)
      @maps[view.id] = map
      @views[view.id] = view

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
    if Wraith.DEBUG then console.log '@Wraith.Controller', 'registerModel'

    throw Error('Model name is already in use') if @models[name]
    @models[name] = model

    # Use the length to know how much to slice off the model string to compare
    l = name.length
    nl = name.toLowerCase()

    # Iterate over all our views, and see if the
    for view_id, map of @maps when map.model_map[0..l-1].toLowerCase() is nl
      view = @views[view_id]
      mapping = map.model_map[l+1..]

      # Wrap in a closure to keep context for model view and map
      ((model, map, view) ->
        isCollection = (mapping != '' and model.get(mapping) instanceof Wraith.Collection)

        if mapping != '' and isCollection and map.$view[0].hasAttribute('data-repeat')
          model.bind 'add:' + mapping, (model_) -> view.createView(model_, map)
          model.bind 'remove:' + mapping, (model_) -> view.removeView(model_, map)
        else if mapping == ''
          view.createView(model, map)
          model.bind 'change', (model_) -> view.updateView(model, map)
        else
          view.createView(model.get(mapping), map)
          model.bind 'change', (model_) -> view.updateView(model_, map)
      )(model, map, view)
    @

  registerView: (view) =>
    if Wraith.DEBUG then console.log '@Wraith.Controller', 'registerView'
    @views.push view

  findViewByElement: (el) =>
    if Wraith.DEBUG then console.log '@Wraith.Controller', 'findViewByElement'
    $(el).closest('[wraith-view]')

  findIdByView: (el) =>
    if Wraith.DEBUG then console.log '@Wraith.Controller', 'findIdByView'
    $(el).data('id')

  findModelById: (id) =>
    if Wraith.DEBUG then console.log '@Wraith.Controller', 'findModelById'
    Wraith.models[id]

  bind: (ev, cb) =>
    if Wraith.DEBUG then console.log '@Wraith.Controller', 'bind'

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
