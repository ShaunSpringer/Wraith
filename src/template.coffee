#
# The template handles rendering logic. It calles
# Wraith.compile which depends on Hogan, but if you
# wish to change that just override Wraith.compile
# and use any renderer of your choice.
#
class @Wraith.Template extends @Wraith.Base
  #
  # Constructor
  # @param [String] template The template string to register
  #
  constructor: (@template) ->
    if Wraith.DEBUG then console.log '@Wraith.Template', 'constructor'

    throw 'Template is required' unless @template
    @template_fn = Wraith.compile(@template)

  #
  # Renders the given data. Expects data to be an object
  # that has a .toJSON method.
  # @param [Object] data The data object to be rendered.
  # @return [String] The result of the execution of the template function
  #
  render: (data) -> @template_fn(data)
