
class @Wraith.RepeatingView extends @Wraith.View
  #
  # Constructor
  #
  constructor: (@$el, @template) ->
    if Wraith.DEBUG then console.log '@Wraith.RepeatingView', 'constructor'

    super(@$el, @template)

    @$parent.innerHTML = ''

    Wraith.Templates[@template] ?= new Wraith.Template(template)
    @Template = Wraith.Templates[@template]

  render: (model) ->
    rendered = @Template.render(model)
    $el = document.createElement('div')
    $el.innerHTML = rendered
    return $el

  createView: (model) ->
    return unless model instanceof Wraith.Model
    $el = @render(model)
    return unless $node = $el.firstChild
    $node.setAttribute('data-id', Wraith.uniqueId())
    $node.setAttribute('data-model', model.get('_id'))
    $view = $el.firstChild
    @$parent.appendChild $view
    @bindEvents $view

  removeView: (model) ->
    return unless model instanceof Wraith.Model
    $el = @$parent.querySelector('[data-model=' + model.get('_id') + ']')
    @$parent.removeChild $el

  updateView: (model) ->
    return unless $oldView = @$parent.querySelector('[data-model=' + model.get('_id') + ']');
    $el = @render(model)
    return unless $node = $el.firstChild
    $node.setAttribute('data-id', Wraith.uniqueId())
    $node.setAttribute('data-model', model.get('_id'))
    @$parent.replaceChild($node, $oldView)
    @bindEvents $node
