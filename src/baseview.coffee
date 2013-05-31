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
    return
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
      continue if not results

      klasses = $view.attributes['class']?.value
      if klasses
        if klasses.split(' ').indexOf(klass) is -1
          klasses = klasses + ' ' + klass
      else
        klasses = klass

      $view.setAttribute('class', klasses)
    @

  #
  # Iterates over a view and its children looking for the
  # data-events attribute which should be a comma separated list
  # of events. The scheme is defined by {Wraith.BaseView#bindUIEvent}
  #
  # @param [HTMLElement] $view The view element to bind to
  #
  bindUIEvents: ($view) =>
    els = $view.querySelectorAll('[data-events]')
    @bindUIEvent $view, $view.attributes['data-events'].value if $view.attributes['data-events']
    @bindUIEvent $el, $el.attributes['data-events'].value for $el in els
    @

  #
  # Binds to a UI event on a given view. Relies on the data-events
  # attribute to be a space or comma delimited list of events.
  # A valid event is given in the schema event:callback
  # The event must be part of {Wraith.UIEvents}
  #
  # @param [HTMLElement] $view The view element to bind to
  # @param [HTMLElement] event The event as defined in the description above
  #
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

  #
  # Used as a wrapper for handling UI events and maintaining
  # the proper context.
  #
  # @param [String] cb The name of the callback function on the controller
  #
  wrapUIEvent: (cb) => (e) => @handleUIEvent e, cb

  #
  # Handles a UI event on the view level.
  # Calls stopPropagation by default to prevent bubbling.
  # Also will emit a uievent for the parent controller to listen to
  # so it can invoke the proper method in the controller.
  #
  # @param [Event] e The UI Event from the browser
  # @param [String] cb The name of the callback function on the controller
  #
  handleUIEvent: (e, cb) =>
    e.stopPropagation()
    @emit 'uievent', e, cb

  #
  # Unbinds a given view and its childrens UI events.
  #
  # @param [HTMLElement] $view The view to unbind events from
  #
  unbindUIEvents: ($view) =>
    els = $view.querySelectorAll('[data-events]')
    @unbindUIEvent $view, $view.attributes['data-events'].value if $view.attributes['data-events']
    @unbindUIEvent $el, $el.attributes['data-events'].value for $el in els
    @

  #
  # Unbinds a given view from the given set of events. Follows the same
  # schema as {Wraith.BaseView#bindUIEvent} does for binding.
  #
  # @param [HTMLElement] $view The view to unbind events from
  # @param [HTMLElement] event The event as defined in the description above
  #
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

