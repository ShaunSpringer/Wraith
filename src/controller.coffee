# #Controller Overview
# The controller handles the business logic of each
# module / application. It is initialized via the DOM
# using the ```data-controller``` attribute. For example
# ```
# <div data-controller="App.Controller">
# ...
# </div>
# ```
# Where ```App.Controller``` is an object that extends Wraith.Controller
# ```
# class App.Controller extends Wraith.Controller
# ```
class Wraith.Controller extends Wraith.BaseView
  # **Constructor**
  constructor: (@$el) ->
    Wraith.log '@Wraith.Controller', 'constructor'

    super(@$el)

    # Set the data-id attribute to our uniquely
    # generated uid from [Wraith.BaseView](baseview.html)
    @$el.setAttribute('data-id', @id)

    # Initialize object variables
    @models = []
    @views = []
    @bindings = []
    @$els = {}

  # Initialize the controller by loading the
  # views and elements with id tags.
  # Also binds UI events to the controllers'
  # respective callbacks
  init: ->
    Wraith.log '@Wraith.Controller', 'init'
    @loadViews()
    @loadForms()
    @bindUIEvents(@$el)
    @loadElements()

  # Load our elements with id attributes into
  # an object that is accesible at the controller level.
  # This makes it easier to access discrete DOM objects
  # within the controller via @els['el-id']
  loadElements: ->
    els = @$el.querySelectorAll('[id]')
    @$els[$el.id] = $el for $el in els
    @

  # Find all the views embedded inside the controller and
  # registers them with the controller
  loadViews: ->
    # Anything with a bind attribute is considered a view
    # so we seek out elements with data-bind and register the
    # view
    views = document.querySelectorAll('[data-bind]')
    @registerView($view) for $view in views
    @

  # Find all the form embedded inside the controller and
  # registers them with the controller
  loadForms: ->
    # Any form with a data-model attribute is loaded
    forms = document.querySelectorAll('form[data-model]')
    @registerForm($forms) for $forms in forms
    @

  # Register the view to this controller
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

  # Register the model to this controller
  registerModel: (model, as) ->
    throw 'Model name already registered' if @models[as]
    throw 'Model is not valid' if not model instanceof Wraith.Model
    @models[as] = model
    @bindViews(as, model)
    model

  # Binds any view that is loaded into the controller
  # to the given model.
  bindViews: (name, model) ->
    return unless bindings = @bindings[name]
    @bindView(model, map.binding, map.view) for map in bindings
    @

  # Binds a single instance of a view to a model.
  # Usings binding as the dot notation map.
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

  # Handles the UI event which is mapped from the DOM to the controller.
  handleUIEvent: (e, cb) =>
    throw "Callback #{cb} not found on controller" unless @[cb]
    e.data = @getInputDataFromEl e.currentTarget
    @[cb](e)

  # This is a wrapper for any UI event happening on views in this
  # controller. We do this so we can do a lookup of the model and pass
  # it through with the event
  handleViewUIEvent: (e, cb) =>
    throw "Callback #{cb} not found on controller" unless @[cb]
    e.model = @getModelFromEl e.target
    @[cb](e)

  # Traverses the dom upwards to find the first model it encounters
  # If no model is found, it will return null
  getModelFromEl: ($el) =>
    while $el
      break if not $el.attributes
      break if modelId = $el.attributes['data-model-id']?.value
      $el = $el.parentNode

    return if not modelId
    Wraith.models[modelId]

  getInputDataFromEl: ($el) ->
    data = {}
    els = $el.querySelectorAll('input[name]')
    data[$el.attributes['name'].value] = $el.value for $el in els
    data
