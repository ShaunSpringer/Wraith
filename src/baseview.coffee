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
  #
  # @param [HTMLElement] $el The HTML Element to attach the view to
  # @param [String] template The template string to use when rendering
  #
  constructor: (@$el) ->
    throw 'Element is required by View' unless @$el
    super()

  #
  # Iterates over a view and its children looking for the
  # data-events attribute which should be a comma separated list
  # of events. The scheme is defined by {#bindUIEvent}
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
  # The event must be part of Wraith.UIEvents
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
  wrapUIEvent: (cb) => (e) =>
    e.stopPropagation()
    @handleUIEvent e, cb

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

