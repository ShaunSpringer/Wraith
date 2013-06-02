#
# Global Wraith Object
# Contains a list of Collections, Models, and Controllers
#
class Wraith
  # Essentially allow logging or not
  @DEBUG: true
  # List of controllers keyed by id
  @controllers: {}
  # List of models keyed by id
  @models: {}
  # List of acceptable UIEvents
  @UIEvents: ['click', 'dblclick', 'mousedown', 'mouseup', 'mousemove', 'scroll', 'keypress', 'keyup', 'keydown', 'change', 'blur', 'focus', 'submit']

  #
  # Logs to the console if DEBUG is set to true
  #
  @log: (args ...) -> if Wraith.DEBUG then console.log args ...

  #
  # Checks to see if a given object
  # is a funciton.
  # @param [Object] obj The object to test
  #
  @isFunction: (obj) -> Object.prototype.toString.call(obj) == '[object Function]'

  #
  # Generates a UID at the desired length
  # @param [Number] length Desired length of the UID
  # @param [String] prefix A prefix to append to the UID
  #
  @uniqueId: (length = 16, prefix = "wraith-") ->
    id = ""
    id += Math.random().toString(36).substr(2) while id.length < length
    id.substr 0, length
    id = prefix + id

# Export Wraith
root = exports ? @
root.Wraith = Wraith
