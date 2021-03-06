#
# The core Wraith View responsible for rendering a single
# instance of a view. It will bind to a models update event
# and re-render each time it changes
#
class Wraith.ViewModel extends Wraith.BaseView
  #
  # Constructor
  # @param [HTMLElement] $el The HTML Element to attach the view to
  # @param [String] template The template string to use when rendering
  #
  constructor: (@$el, template) ->
    Wraith.log '@Wraith.ViewModel', 'constructor'
    throw 'Element is required by View' unless @$el
    throw 'Template is required by View' unless template
    super(@$el)
    @$parent = @$el.parentNode
    @template = new Wraith.Template(template)

  #
  # Renders the view given a {Wraith.Model} object.
  # By injecting the compiled template into a div
  # and then pull it back out we are able to create a HTMLElement
  # which is the desired returned result.
  #
  # @param [Wraith.Model] model The model to render
  # @return [HTMLElement] A HTMLElement from the resulting render
  #
  render: (model) ->
    $el = document.createElement('div')
    $el.innerHTML = @template.compile(model)
    $el = $el.firstChild
    $el

  #
  # Updates the view for a given model. Calls the
  # render function and then does a replaceChild to
  # swap the current view (@$el) for the new view.
  # This also implicitly rebinds events after the view is
  # rendered and inserted into the DOM.
  #
  # @param [Wraith.Model] model The model used when rendering
  #
  updateView: (model) ->
    @unbindUIEvents @$el
    $view = @render(model)
    @bindUIEvents $view
    @applyViewUpdate(@$el, $view)
    @

  #
  # Bind ourselves (the view) to the model -- this is used in two-way binding.
  # Handles FORM submit binding if the nodeName of $el is a FORM. Also
  # will trigger an update.
  #
  # @param [Wraith.Model] model The model to bind
  #
  bindModel: (model) =>
    @$el.addEventListener 'keyup', (e) => @handleInputChange_ e, model
    @$el.addEventListener 'blur', (e) => @handleInputChange_ e, model
    if @$el.nodeName is 'FORM'
      @$el.addEventListener 'submit', (e) => @handleFormSubmit_ e, model

    @updateView model

  #
  # Unbind ourselves from the given model.
  #
  # @param [Wraith.Model] model The model to unbind from
  #
  unbindModel: (model) =>
    @$el.removeEventListener 'keyup', (e) => @handleInputChange_ e, model
    @$el.removeEventListener 'blur', (e) => @handleInputChange_ e, model
    if @$el.nodeName is 'FORM'
      @$el.removeEventListener 'submit', (e) => @handleFormSubmit_ e, model

  #
  # When an input is typed into, we want to update
  # the model (if it has a corresponding name)
  #
  # @param [Event] e The keypress event
  # @param [Wraith.Model] model The model associated with this event
  #
  handleInputChange_: (e, model) =>
    $target = e.target

    # Dont update any values that dont exist on our model!
    return unless model.attributes.hasOwnProperty($target.name)
    model.set($target.name, $target.value)

  #
  # Handle the form submit by creating a new
  # instance of the model if it belongs to a
  # collection.
  #
  # @param [Event] e The form submit event
  # @param [Wraith.Model] model The model associated with this event
  #
  handleFormSubmit_: (e, model) =>
    # For now we are requiring a parent model to
    # be bound to this model (e.g. a collection)
    return unless parent = model.parent

    # Never submit.
    e.preventDefault()

    # Only proceed if its a valid model
    return unless model.isValid()

    # Shallow copy of data to new model
    # @todo replace with a clone method
    data = model.toJSON()
    id = data['_id']
    data['_id'] = null
    delete data['_id']

    # Create the new model via the parent object
    parent.create data

    # Reset the model (but keep the same _id attribute)
    model.reset { '_id': id }
