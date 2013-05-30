#
# The core Wraith View responsible for rendering a single
# instance of a view. It will bind to a models update event
# and re-render each time it changes. Additionally it will handle
# setting classes up based on the data-class directive, and other
# bindings that might be required in the future.
#
class Wraith.BaseView extends Wraith.Base
  #
  # Constructor
  # @param [HTMLElement] $el The HTML Element to attach the view to
  # @param [String] template The template string to use when rendering
  #
  constructor: (@$el) ->
    throw 'Element is required by View' unless @$el
    super()

  #
  # Takes a given token array
  # and seeks out its value in the given model. It currently
  # assumes that a model is a Wraith.Model object.
  #
  # @param [Array] tokens The array of tokens to be used when searching the model
  # @param [Wraith.Model] model The model to search for the given token array
  # @returns [Object|String|Boolean] The results of the token search
  #
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

  #
  # Iterates over each of $view's children as well as $view itself and calls
  # {Wraith.BaseView#bindClasses} to apply the class(es) accordingly. This requires
  # the $view and its children to be marked up with data-class attributes.
  #
  # @param [HTMLElement] $view The view to be binding the classes to/from
  # @param [Wraith.Model] model The model to use when applying the classes
  #
  applyClasses: ($view, model) =>
    els = $view.querySelectorAll('[data-class]')
    @applyClass $view, model if $view.attributes['data-class']
    @applyClass $el, model for $el in els
    @

  #
  # Binds a views data-class attribute -- which is represented
  # as a set of colon delimited key-value pairs which are in turn separated
  # by spaces, e.g. class1:value1 class2:value2
  # It takes the current value of the model given by dot notation (e.g. value1, value2 above)
  # and casts the value as a boolean. If it is true the class (e.g. class1, class2) are applied
  # during the rendering process.
  #
  # @param [HTMLElement] $view The view to be binding the classes to/from
  # @param [Wraith.Model] model The model to use when applying the classes
  #
  applyClass: ($view, model) =>
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

  wrapUIEvent: (cb) => (e) => @handleUIEvent e, cb

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

