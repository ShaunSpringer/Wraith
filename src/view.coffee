
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
    throw 'Element is required by View' unless @$el
    throw 'Template is required by View' unless @template

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
    events = event.split(/[,?\s?]/)
    for event in events
      eventArr = event.split(':')
      continue if eventArr.length isnt 2
      name = eventArr[0]
      cb = eventArr[1]
      continue if not name in Wraith.UIEvents
      $view.addEventListener name, (e) => @emit 'uievent', e, cb
    @
