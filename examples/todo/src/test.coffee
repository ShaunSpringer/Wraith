root = exports ? @

class Wraith.Models.ListItem extends Wraith.Model
  @field 'text', { default: 'New Item' }
  @field 'selected', { default: false }

class Wraith.Models.List extends Wraith.Model
  @hasMany Wraith.Models.ListItem, as: 'items'

class Wraith.Controllers.SelectList extends Wraith.Controller
  view: 'ListItem'

  init: ->
    @View = Wraith.Views[@view]
    @list = new Wraith.Models.List
    @list.bind 'add:items', @add

    items = @list.items
    items.create
      text: 'Test 1'
      selected: true
    items.create
      text: 'Test 2'
      selected: false

    self = @
    Wraith.delay 1000, ->
      self.list.items.at(0).set('text', 'Test 4')

  add: (model) =>
    self = @
    @append(@View.render(model))
    model.bind 'change', ( ->
      self.update(model)
    )

  update: (model) =>
    $view = $('#' + model.get('_id'))
    $view.html(@View.render(model))
