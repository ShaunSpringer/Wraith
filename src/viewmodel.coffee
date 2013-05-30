#
# The core Wraith View responsible for rendering a single
# instance of a view. It will bind to a models update event
# and re-render each time it changes
#
class Wraith.ViewModel extends Wraith.BaseView
  #
  # The template REGEX object as a static property.
  # Used when parsing the template to bind to a model.
  #
  @TEMPLATE_REGEX = new RegExp(
    Wraith.templateSettings.start +
    '\\s*(' +
    Wraith.templateSettings.dotNotation +
    ')\\s*' +
    Wraith.templateSettings.end,
    'gi')

  #
  # Constructor
  # @param [HTMLElement] $el The HTML Element to attach the view to
  # @param [String] template The template string to use when rendering
  #
  constructor: (@$el, @template) ->
    Wraith.log '@Wraith.ViewModel', 'constructor'
    throw 'Element is required by View' unless @$el
    throw 'Template is required by View' unless @template

    super(@$el)
    @$parent = @$el.parentNode

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
    $el.innerHTML = @compileTemplate(model, @template)
    $el = $el.firstChild
    $el

  #
  # Compiles a given template using the data from the model provided.
  # It will take into account dot notation and methods used in said notation.
  # If the type of a given token is mapped to a function on the model it will
  # attempt to execute it and use the resulting value/object with the next token
  # or will return it if it is the last token.
  #
  # @todo This depends on a {Wraith.Model} and its get function.. is this necessary?
  #
  # @param [Wraith.Model] model The model to be applied to the template.
  # @param [String] template The string template to be rendered.
  #
  # @return [String] The resulting template after the model is applied to it.
  #
  compileTemplate: (model, template) ->
    template.replace Wraith.ViewModel.TEMPLATE_REGEX, (tag, results) ->
      tokens = results.split('.')
      count = 0
      for token in tokens
        target = if count is 0 then model else val
        if target.hasOwnProperty(token)
          val = target[token]
        else
          val = target.get(token)
        val = val() if Wraith.isFunction(val)
        count++
      val

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
    @applyClasses $view, model
    @bindUIEvents $view
    @applyViewUpdate(@$el, $view)

    @

  applyViewUpdate: ($old, $new) =>
    attrs = []
    if $old.attributes
      attrs = (attr.name for attr in $old.attributes)

    if $new.attributes
      for attr in $new.attributes
        if attrs.indexOf(attr.name) is -1
          attrs.push attr.name

    @updateAttribute(attr, $old, $new) for attr in attrs

    if $old.nodeValue isnt $new.nodeValue
      $old.nodeValue = $new.nodeValue

    for $child, i in $old.childNodes
      @applyViewUpdate $child, $new.childNodes[i]

    @


  updateAttribute: (name, $old, $new) ->
    oldval = $old.attributes[name]?.value
    newval = $new.attributes[name]?.value

    return if oldval is newval

    if newval
      $old.setAttribute(name, newval)
    else
      $old.removeAttribute(name)
