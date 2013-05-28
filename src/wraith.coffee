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
  # Borrowed from Underscores ERB-style templates
  # @param [String] string The string to escape
  #
  escapeRegExp: (string) -> string.replace(/([.*+?^${}()|[\]\/\\])/g, '\\$1')

  #
  # This is partly borrowed from underscores ERB-style template
  # settings.
  #
  templateSettings:
    start:        '{{'
    end:          '}}'
    interpolate:  /{{(.+?)}}/g
    checked: /data-checked=['"](.+?)['"]/g
    class: /class="(?:(\w+?):([^:]+?)\s?)+"/ #/class="(\w+?)\:(\w+?)"/

  #
  # Compiles a template with a ERB style markup.
  # Note: Override this if you want to use a different
  # template system.
  #
  # NOTE:
  # JavaScript templating a-la **ERB**, pilfered from John Resig's
  # *Secrets of the JavaScript Ninja*, page 83.
  # Single-quote fix from Rick Strahl.
  # With alterations for arbitrary delimiters, and to preserve whitespace.
  #
  # @param [String] template The template to compile
  #
  compile: (template) ->
    c = Wraith.templateSettings
    endMatch = new RegExp("'(?=[^" + c.end.substr(0, 1) + "]*" + Wraith.escapeRegExp(c.end) + ")", "g")
    fn = new Function 'obj',
      'var p=[],print=function(){p.push.apply(p,arguments);};' +
      'with(obj||{}){p.push(\'' +
      template.replace(/\r/g, '\\r')
      .replace(/\n/g, '\\n')
      .replace(/\t/g, '\\t')
      .replace(endMatch, "✄")
      .split("'").join("\\'")
      .split("✄").join("'")
      .replace(c.interpolate, "' + ((hasOwnProperty('get') && get(\'$1\')) || $1) + '")
      .replace(c.checked, "' + ((hasOwnProperty('get') && get(\'$1\') === true) ? 'checked' : \'\') + '")
      .replace(c.class, "class=\"' + ((hasOwnProperty('get') && get(\'$2\') === true) ? '$1' : \'\') + '\"")
      .split(c.start).join("');")
      .split(c.end).join("p.push('") +
      "');}return p.join('');"

    return fn

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
