#
# The proverbial 'controller' in the MVC pattern.
# The Controller handles the logic your applications or
# components may have. This controller handles automatical registration
# and mapping of models to views.
#
# @example Example markup in HTML.
#   This will create a SelectList controller
#   and then create a view using the template with id "ListItem"
#   mapping to the model list.items (belonging to SelectList)
#
#   <ul data-view="SelectList">
#     <div data-template="ListItem" data-map="list.items"></div>
#   </ul>
#
class Wraith.Controller extends Wraith.BaseView
  #
  # Initializes a few private variables and sets the data-id
  # attribute to a uniquely generated id.
  #
  # @param [HTMLElement] $el The main element to bind the controller to.
  #
  constructor: (@$el) ->
    Wraith.log '@Wraith.Controller', 'constructor'

    super(@$el)

    @$el.setAttribute('data-id', @id)
    @models = []
    @views = []
    @bindings = []
    @$els = {}

  #
  # Initialize the controller by loading the
  #
  init: ->
    Wraith.log '@Wraith.Controller', 'init'
    @findViews()
    @bindUIEvents(@$el)
    @loadElements()

  #
  # Load our elements with id attributes into
  # an object that is accesible at the controller level.
  # This makes it easier to access discrete DOM objects
  # within the controller via @els['el-id']
  #
  loadElements: ->
    els = @$el.querySelectorAll('[id]')
    @$els[$el.id] = $el for $el in els
    @

  #
  # Find all the views embedded inside the controller and
  # register them with the controller
  #
  findViews: ->
    # Anything with a bind attribute is considered a view
    views = document.querySelectorAll('[data-bind]')
    @registerView($view) for $view in views
    @

  #
  # Register the view to this controller
  #
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
      view = new Wraith.CollectionView($view, template)
    else
      view = new Wraith.ViewModel($view, template)

    # Listen for uievents from the view
    view.bind 'uievent', @handleViewUIEvent

    @views.push view
    @bindings[targetModel] ?= []
    @bindings[targetModel].push {binding, view}
    @

  #
  # Register the model to this controller
  #
  # @param [Wraith.Model] model The model to register to this controller
  # @param [String] as The name of the model to register
  #
  # @return [Wraith.Model] The model that was registered
  #
  registerModel: (model, as) ->
    throw 'Model name already registered' if @models[as]
    throw 'Model is not valid' if not model instanceof Wraith.Model
    @models[as] = model
    @bindViews(as, model)
    model

  #
  # Binds any view that is loaded into the controller
  # to the given model.
  #
  # @param [String] name The name of the model to bind to
  # @param [Wraith.Model] model The model to map the namespace to
  #
  bindViews: (name, model) ->
    return unless bindings = @bindings[name]
    @bindView(model, map.binding, map.view) for map in bindings
    @

  #
  # Binds a single instance of a view to a model.
  # Usings binding as the dot notation map.
  #
  # @param [Wraith.Model] model The model to bind to
  # @param [String] binding The dot notation binding (first item should be the model name)
  # @param [Wraith.View|Wraith.CollectionView] view The view object to bind to.
  #
  bindView: (model, binding, view) ->
    mapping = binding.split('.')
    map = mapping[1]

    if map and view instanceof Wraith.CollectionView
      model.bind 'add:' + map, (model_) ->
        view.createView(model_)
        model_.bind 'change', -> view.updateView(model_)
      model.bind 'remove:' + map, (model_) -> view.removeView(model_)
    else if map
      model.bind 'change:' + map, (model_) -> view.updateView(model_)
    else
      model.bind 'change', -> view.updateView(model)

  #
  # Handles the UI event which is mapped from the DOM to the controller.
  #
  # @param [Event] e The event data object from the UI Event
  # @param [String] cb The name of the callback function to call on the controller
  #
  handleUIEvent: (e, cb) =>
    throw "Callback #{cb} not found on controller" unless @[cb]
    @[cb](e)

  #
  # This is a wrapper for any UI event happening on views in this
  # controller. We do this so we can do a lookup of the model and pass
  # it through with the event
  #
  # @param [Event] e The native event object
  # @param [String] cb The name of the callback function to call
  #
  handleViewUIEvent: (e, cb) =>
    throw "Callback #{cb} not found on controller" unless @[cb]
    e.model = @getModelFromEl e.target
    @[cb](e)

  #
  # Traverses the dom upwards to find the first model it encounters
  # If no model is found, it will return null
  #
  # @param [HTMLElement] $el The element from which to start the traversal
  #
  # @return [Wraith.Model] The model that belongs to the respective view
  #
  getModelFromEl: ($el) =>
    while $el
      break if not $el.attributes
      break if modelId = $el.attributes['data-model']?.value
      $el = $el.parentNode

    return if not modelId
    Wraith.models[modelId]
