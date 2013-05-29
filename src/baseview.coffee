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
    @bindClass $view, model if $view.attributes['data-class']

    els = $view.querySelectorAll('[data-class]')
    @bindClass $el, model for $el in els

    @

  resolveToken: (tokens, model) =>
    count = 0
    results = false
    for token in tokens
      # @TODO This depends on a get function.. is this necessary?
      target = if count is 0 then model else results
      if target.hasOwnProperty(token)
        results = target[token]
      else
        results = target.get(token)
      results = results() if Wraith.isFunction(results)
      count++
    results

  bindClass: ($view, model) =>
    klasses = $view.attributes['data-class'].value
    for klassMap in klasses.split(' ')
      binding = klassMap.split(':')
      continue if binding.length isnt 2

      klass = binding[0]
      tokens = binding[1]

      invert = tokens[0] is '!'
      tokens = tokens.slice(1) if invert

      # @TODO: Refactor this and ViewModel.render
      results = @resolveToken(tokens.split('.'), model)

      results = !results if invert
      if results
        klasses = $view.attributes['class']?.value
        if klasses
          if klasses.split(' ').indexOf(klass) is -1
            klasses = klasses + ' ' + klass
        else
          klasses = klass

        $view.setAttribute('class', klasses)
      @

  bindUIEvents: ($view) =>
    els = $view.querySelectorAll('[data-events]')
    @bindUIEvent $view, $view.attributes['data-events'].value if $view.attributes['data-events']
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
      $view.addEventListener name, @wrapUIEvent(cb)
    @

  wrapUIEvent: (cb) =>
    return (e) => @handleUIEvent e, cb

  handleUIEvent: (e, cb) =>
    e.stopPropagation()
    @emit 'uievent', e, cb

  unbindUIEvents: ($view) =>
    els = $view.querySelectorAll('[data-events]')
    @unbindUIEvent $view, $view.attributes['data-events'].value if $view.attributes['data-events']
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

