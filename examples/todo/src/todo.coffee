App = {}

#
# Our list item model. Will be represetented
# as a collection in Wraith.Models.List
#
# @include Wraith.Models.ListItem
# @extend Wraith.Model
#
class App.ListItem extends Wraith.Model
  @field 'text', { default: 'New Item' }
  @field 'selected', { default: false }

#
# Represents our list of ListItems
#
# @include Wraith.Models.List
# @extend Wraith.Model
#
class App.List extends Wraith.Model
  @hasMany App.ListItem, 'items'
  completed: =>
    items = @get('items').all()
    items = items.filter (item) -> item.get('selected') is true
    items.length
#
# TodoManager handles all the interaction between the
# components of the todo list.
#
# @include Wraith.Controllers.TodoManager
# @extend Wraith.Controller
#
class App.TodoManager extends Wraith.Controller
  init: ->
    super()
    @list = @registerModel(new App.List, 'list')
    @items = @list.get('items')
    @items.create { text: 'Task 1', selected: true }
    @items.create { text: 'Task 2' }
    @items.create { text: 'Task 3' }

  inputKeypress: (e) =>
    return unless e.keyCode is 13 and (val = e.currentTarget.value) isnt ''
    @items.create { text: val, selected: false }
    e.currentTarget.value = ''

  itemDelete: (e) => @items.remove e.model.get('_id')
  itemToggle: (e) => e.model.set('selected', !e.model.get('selected'))


root = exports ? @
root.App = App
