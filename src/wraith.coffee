#
# Global Wraith Object
# Used to name space
#
# @include Wraith
#
@Wraith =
  DEBUG: true
  Controllers: []
  controllers: {}
  Collections: {}
  Models: {}
  models: {}
  Templates: {}
  UIEvents: ['click', 'dblclick', 'mousedown', 'mouseup', 'mousemove', 'scroll', 'keypress', 'keyup', 'keydown', 'change', 'blur', 'focus']
  log: (args ...) -> if Wraith.DEBUG then console.log args ...
  #
  # Checks to see if a given object
  # is a funciton.
  # @param [Object] obj The object to test
  #
  isFunction: (obj) -> Object.prototype.toString.call(obj) == '[object Function]'

  #
  # Delays the execution of a function for the
  # given time in ms
  # @param [Number] ms The time to delay in ms
  # @param [Function] func The function to execute after the given time
  #
  delay: (ms, func) -> setTimeout func, ms

  #
  # This is partly borrowed from underscores ERB-style template
  # settings.
  #
  templateSettings:
    start:        '{{'
    end:          '}}'
    checked: 'data-checked=[\'"](.+?)[\'"]'
    dotNotation: '[a-z0-9_()][\\.a-z0-9_()]*'

  #
  # Generates a UID at the desired length
  # @param [Number] length Desired length of the UID
  # @param [String] prefix A prefix to append to the UID
  # Unfortunately this is here because zepto doesn't like id's
  # in selectors to start with numbers.
  #
  uniqueId: (length = 16, prefix = "wraith-") ->
    id = ""
    id += Math.random().toString(36).substr(2) while id.length < length
    id.substr 0, length
    id = prefix + id
