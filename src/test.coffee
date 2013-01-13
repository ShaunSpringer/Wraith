root = exports ? @

class Wraith.Models.ListItem extends Wraith.Model
  @field 'text', { default: 'New Item' }
  @field 'selected', { default: false }

class Wraith.Models.List extends Wraith.Model
  @hasMany Wraith.Models.ListItem, as: 'items'

class Wraith.Controllers.SelectList extends Wraith.Controller
  init: ->
    @list = new Wraith.Models.List
    @list.bind 'change', ->
      console.log @

    items = @list.items
    items.create
      text: 'Test 1'
      selected: true
    items.create
      text: 'Test 2'
      selected: false


