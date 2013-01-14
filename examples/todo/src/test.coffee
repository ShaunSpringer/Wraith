root = exports ? @

class Wraith.Models.ListItem extends Wraith.Model
  @field 'text', { default: 'New Item' }
  @field 'selected', { default: false }

class Wraith.Models.List extends Wraith.Model
  @hasMany Wraith.Models.ListItem, as: 'items'

class Wraith.Controllers.SelectList extends Wraith.Controller
  view: 'ListItem'

  init: ->
    super()
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
    Wraith.delay 2000, ->
      self.list.items.at(1).set('text', 'Test 5')

