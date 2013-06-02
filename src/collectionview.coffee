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
  # @param [HTMLElement] $el The HTMLElement to bind our collection to
  # @param [String] template The template to use when rendering views.
  #
  constructor: (@$el, @template) ->
    Wraith.log '@Wraith.CollectionView', 'constructor'
    super(@$el, @template)
    @$parent.innerHTML = ''

  #
  # Creates a view as a child of $el using the append method.
  #
  # @param [Wraith.Model] model The model that this view it to use when rendering.
  #
  createView: (model) ->
    return unless model instanceof Wraith.Model
    $view = @render(model)
    $view.setAttribute('data-model', model.get('_id'))
    @bindUIEvents $view
    @$parent.appendChild $view

  #
  # Removes a view that was bound to a given model. Performs a lookup
  # within the parent $el for the data-model=[model_id] attribute.
  #
  # @param [Wraith.Model] model The model to do the view lookup with and remove.
  #
  removeView: (model) ->
    return unless model instanceof Wraith.Model
    $view = @$parent.querySelector('[data-model=' + model.get('_id') + ']')
    @unbindUIEvents $view
    @$parent.removeChild $view

  #
  # Updates a view that is bound to the given model.
  #
  # @todo Break the dependency on the view bound data-model (which really isnt necessary)
  #
  # @param [Wraith.Model] model The model to do the view lookup with and update.
  #
  updateView: (model) ->
    return unless $el = @$parent.querySelector('[data-model=' + model.get('_id') + ']');

    $view = @render(model)
    $view.setAttribute('data-model', model.get('_id'))
    @unbindUIEvents $el
    @bindUIEvents $view
    @applyViewUpdate $el, $view


