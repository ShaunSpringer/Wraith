#
# The CollectionView provides Collection -> View binding.
# It handles repeated view instances, adding and removing views
# when models are added or removed, and updating the corresponding
# view when a model changes.
#
class Wraith.CollectionView extends Wraith.ViewModel
  #
  # Constructor
  #
  constructor: (@$el, @template) ->
    Wraith.log '@Wraith.CollectionView', 'constructor'
    super(@$el, @template)
    @$parent.innerHTML = ''

  createView: (model) ->
    return unless model instanceof Wraith.Model
    $view = @render(model)
    $view.setAttribute('data-model', model.get('_id'))
    @applyClasses $view, model
    @bindUIEvents $view
    @$parent.appendChild $view

  removeView: (model) ->
    return unless model instanceof Wraith.Model
    $view = @$parent.querySelector('[data-model=' + model.get('_id') + ']')
    @unbindUIEvents $view
    @$parent.removeChild $view

  updateView: (model) ->
    return unless $el = @$parent.querySelector('[data-model=' + model.get('_id') + ']');

    $view = @render(model)
    $view.setAttribute('data-model', model.get('_id'))
    @applyClasses $view, model
    @unbindUIEvents $el
    @bindUIEvents $view
    @applyViewUpdate $el, $view


