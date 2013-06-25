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
  # Crawls the old nodes and new nodes, compares
  # their contents and attributes, and updates the old
  # node accordingly. This prevents the entire view from
  # re-rendering each time data changes.
  #
  # @todo make this more efficient!
  #
  # @param [HTMLElement] $old The old DOM element that we are updating
  # @param [HTMLElement] $new The new DOM element we are updating based on
  #
  applyViewUpdate: ($old, $new) =>
    attrs = []

    if $old.attributes
      attrs = (attr.name for attr in $old.attributes)

    if $new.attributes
      for attr in $new.attributes
        if attrs.indexOf(attr.name) is -1
          attrs.push attr.name

    if attrs.length > 0
      @updateAttribute(attr, $old, $new) for attr in attrs

    if $old.nodeValue isnt $new.nodeValue
      $old.nodeValue = $new.nodeValue

    for $child, i in $old.childNodes
      @applyViewUpdate $child, $new.childNodes[i]

    @

  #
  # Updates a given attribute on $old to the current value on $new.
  # Used to update values on a DOM element without having to rewrite the
  # entire DOM structure (children etc).
  #
  # @param [String] name The attribute name to update
  # @param [HTMLElement] $old The old DOM element that we are updating
  # @param [HTMLElement] $new The new DOM element we are updating based on
  #
  updateAttribute: (name, $old, $new) ->
    oldval = $old.attributes[name]?.value
    newval = $new.attributes[name]?.value

    # Handle checked attribute as properties
    $old.checked = newval? if name is 'checked'
    $old.value = newval if name is 'value'

    return if oldval is newval

    if newval
      $old.setAttribute(name, newval)
    else
      $old.removeAttribute(name)


  # Bind our view to the model for two-way binding
  bindModel: (model) =>
    @$el.addEventListener 'keyup', (e) => @handleInputKeypress_ e, model
    if @$el.nodeName is 'FORM'
      @$el.addEventListener 'submit', (e) => @handleFormSubmit_ e, model

    @updateView model

  unbindModel: (model) =>
    @$el.removeEventListener 'keyup', (e) => @handleInputKeypress_ e, model
    if @$el.nodeName is 'FORM'
      @$el.removeEventListener 'submit', (e) => @handleFormSubmit_ e, model

  handleInputKeypress_: (e, model) =>
    $target = e.target
    model.set($target.name, $target.value or $target.attributes['value']?.value)

  handleFormSubmit_: (e, model) =>
    return unless parent = model.parent

    # Never submit.
    e.preventDefault()

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
