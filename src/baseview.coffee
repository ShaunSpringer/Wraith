#
# The core Wraith View responsible for rendering a single
# instance of a view. It will bind to a models update event
# and re-render each time it changes
#
class @Wraith.BaseView extends @Wraith.Base
  #
  # Constructor
  # @param [HTMLElement] $el The HTML Element to attach the view to
  # @param [String] template The template string to use when rendering
  #
  constructor: (@$el) ->
    Wraith.log '@Wraith.View', 'constructor'
    throw 'Element is required by View' unless @$el
    super()

  bindClasses: ($view, model) =>
    els = $view.parentNode.querySelectorAll('[data-class]')

    for $el in els
      klasses = $el.attributes['data-class'].value
      $el.removeAttribute('data-class') # Clean up the DOM
      for klassMap in klasses.split(' ')
        breakdown = klassMap.split(':')
        continue if breakdown.length isnt 2
        @bindClass $view, model, breakdown[0], breakdown[1]
    @

  bindClass: ($view, model, klass, binding) =>
    results = false
    invert = binding[0] is '!'
    binding = binding.slice(1) if invert

    # See if this is a method
    if binding.slice(-2) is '()'
      binding = binding.slice(0, -2)
      if Wraith.isFunction(model[binding])
        results = !!model[binding]()
    else
      results = !!model.get(binding)

    results = !results if invert
    if results
      klasses = $view.attributes['class']?.value
      $view.setAttribute('class', klasses + ' ' + klass)

  bindUIEvents: ($view) =>
    els = $view.parentNode.querySelectorAll('[data-events]')
    @bindUIEvent $el, $el.attributes['data-events'].value for $el in els
    @

  bindUIEvent: ($view, event) =>
    events = event.split(/[,?\s?]/)
    for event in events
      eventArr = event.split(':')
      continue if eventArr.length isnt 2
      name = eventArr[0]
      cb = eventArr[1]
      continue if not name in Wraith.UIEvents
      $view.addEventListener name, (e) => @handleUIEvent e, cb
    @

  handleUIEvent: (e, cb) -> @emit 'uievent', e, cb

  unbindUIEvents: ($view) =>
    els = $view.parentNode.querySelectorAll('[data-events]')
    @unbindUIEvent $el, $el.attributes['data-events'].value for $el in els
    @

  unbindUIEvent: ($view, event) =>
    events = event.split(/[,?\s?]/)
    for event in events
      eventArr = event.split(':')
      continue if eventArr.length isnt 2
      name = eventArr[0]
      cb = eventArr[1]
      continue if not name in Wraith.UIEvents
      $view.removeEventListener name, (e) => @handleUIEvent e, cb
    @

