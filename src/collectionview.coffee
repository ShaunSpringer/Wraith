
class @Wraith.CollectionView extends @Wraith.ViewModel
  #
  # Constructor
  #
  constructor: (@$el, @template) ->
    Wraith.log '@Wraith.CollectionView', 'constructor'
    super(@$el, @template)
    @$parent.innerHTML = ''

  createView: (model) ->
    return unless model instanceof Wraith.Model
    $el = @render(model)
    return unless $node = $el
    $node.setAttribute('data-id', Wraith.uniqueId())
    $node.setAttribute('data-model', model.get('_id'))
    @$parent.appendChild $el
    @bindClasses $el, model
    @bindUIEvents $el

  removeView: (model) ->
    return unless model instanceof Wraith.Model
    $el = @$parent.querySelector('[data-model=' + model.get('_id') + ']')
    @$parent.removeChild $el
    @unbindUIEvents $el

  updateView: (model) ->
    return unless $oldView = @$parent.querySelector('[data-model=' + model.get('_id') + ']');
    $el = @render(model)
    return unless $node = $el
    id = $oldView.attributes['data-id'].value or Wraith.uniqueId()
    $node.setAttribute('data-id', id)
    $node.setAttribute('data-model', model.get('_id'))
    @$parent.replaceChild($node, $oldView)
    @bindClasses $node, model
    @bindUIEvents $node
