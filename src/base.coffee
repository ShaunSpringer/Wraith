#
# The base class for all Wraith objects.
# Includes binding to events, and emitting events.
#
class Wraith.Base
  #
  # Constructor
  #
  constructor: ->
    @id = Wraith.uniqueId()
    @listeners = {}

  #
  # Binds the given function (cb) to the given
  # event (ev)
  #
  # @param [String] ev Event to listen for.
  # @param [Function] cb Callback to be executed on event.
  #
  bind: (ev, cb) =>
    throw 'Callback is not a function' unless Wraith.isFunction(cb)
    list = @listeners[ev] ?= []
    list.push(cb)
    @

  #
  # Unbinds the given function (cb) from the given
  # event (ev)
  #
  # @param [String] ev Event to unbind.
  # @param [Function] cb Callback to unbind.
  #
  unbind: (ev, cb) =>
    list = @listeners?[ev]
    for callback, i in list when callback is cb
      list.slice()
      list.splice(i, 1)
      debugger
      @listeners[ev] = list
      break
    @

  #
  # Emits the given event to listneers
  #
  # @param [String] event The name of the event to emit
  # @param [Object] args The data object to emit
  #
  emit: (event, args ...) =>
    if @listeners[event]?
      listener(args ...) for listener in @listeners[event]
    @

  #
  # Used to proxy a function call through this object.
  #
  # Borrowed from Spine
  # @author Paul Miller
  #
  # @param [Function] fn The function to proxy
  #
  proxy: (fn) -> => fn.apply(this, arguments)

