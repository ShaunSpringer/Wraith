#
# The Wraith Template object is responsible for storing a template string,
# generating a template function and interpolating the data to generate
# a view off a given set of data.
#
# Note: Based on John Resig's microtemplating function(s).
#
class Wraith.Template
  #
  # Borrowed from Underscores templates
  #
  # @param [String] string The string to escape
  #
  @escapeRegExp: (string) -> string.replace(/([.*+?^${}()|[\]\/\\])/g, '\\$1')

  #
  # A set of template settings used by {Wraith.Template}
  #
  @settings:
    start:        '{{'
    end:          '}}'
    interpolate:  /{{(.+?)}}/g
    checked: /data-checked=[\'\"](.+?)[\'\"]/gi
    classes: /data-class=[\'\"](.+?)[\'\"]/gi
    classesMerge: /class="([^"]+?)"([^<^>]*)class="([^"]+?)"/gi
    dotNotation: '[a-z0-9_()][\\.a-z0-9_()]*'

  #
  # Constructor
  #
  # @param [String] template The template string to apply the data to on render.
  #
  constructor: (@template) -> @

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
  compile: (data) ->
    return @template_fn(data) if @template_fn

    c = Wraith.Template.settings
    template = @template

    endMatch = new RegExp("'(?=[^" + c.end.substr(0, 1) + "]*" + Wraith.Template.escapeRegExp(c.end) + ")", "g")
    str = 'var p=[],print=function(){p.push.apply(p,arguments);};' +
      'p[p.length] = \'' +
      template.replace(/\r/g, '\\r')
      .replace(/\n/g, '\\n')
      .replace(/\t/g, '\\t')
      .replace(endMatch, "✄")
      .split("'").join("\\'")
      .split("✄").join("'")
      .replace(c.interpolate, "' + Wraith.Template.interpolate(obj, \'$1\') + '")
      .replace(c.checked, "' + ((Wraith.Template.interpolate(obj, \'$1\') === true) ? 'checked=\"checked\"' : \'\') + '")
      .replace(c.classes, "class=\"' + Wraith.Template.interpolateClass(obj, \'$1\') + '\"")
      .replace(c.classesMerge, "class=\"$1 $3\"' + ((\'$2\').length > 0 ? \'$2\' : '') + '")
      .split(c.start).join("');")
      .split(c.end).join("p.push('") +
      "'; return p.join('');"
    @template_fn = new Function 'obj', str
    @template_fn(data)


  #
  # Takes a given token array
  # and seeks out its value in the given model. It currently
  # assumes that a model is a Wraith.Model object.
  #
  # @param [Wraith.Model] model The model to search for the given token array
  # @param [String] tokens The string of tokens to be used when searching the model (dot notation)
  # @returns [Object|String|Boolean] The results of the token search
  #
  @interpolate: (model, tokens) =>
    count = 0
    results = false
    tokens = tokens.split('.')
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
  # Takes a given token array
  # and seeks out its value in the given model. It currently
  # assumes that a model is a Wraith.Model object.
  #
  # @param [Wraith.Model] model The model to search for the given token array
  # @param [String] tokens The string of tokens to be used when searching the model (dot notation)
  # @returns [Object|String|Boolean] The results of the token search
  #
  @interpolateClass: (model, tokens) =>
    klasses = []
    for klassMap in tokens.split(' ')
      binding = klassMap.split(':')
      continue if binding.length isnt 2

      klass = binding[0]
      tokens = binding[1]

      invert = tokens[0] is '!'
      tokens = tokens.slice(1) if invert

      # @TODO: Refactor this and ViewModel.render
      results = Wraith.Template.interpolate(model, tokens)

      results = !results if invert
      continue if not results

      klasses.push klass

    return klasses.join(' ')

