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

  bindUIEvents: ($view) =>
    @bindUIEvent $view, $view.attributes['data-events'].value if $view.attributes['data-events']
    els = $view.querySelectorAll('[data-events]')
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
    @unbindUIEvent $view, $view.attributes['data-events'].value if $view.attributes['data-events']
    els = $view.querySelectorAll('[data-events]')
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

