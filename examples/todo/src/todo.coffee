root = exports ? @

#
# Our list item model. Will be represetented
# as a collection in Wraith.Models.List
#
# @include Wraith.Models.ListItem
# @extend Wraith.Model
#
class Wraith.Models.ListItem extends Wraith.Model
  @field 'text', { default: 'New Item' }
  @field 'selected', { default: false }

#
# Represents our list of ListItems
#
# @include Wraith.Models.List
# @extend Wraith.Model
#
class Wraith.Models.List extends Wraith.Model
  @hasMany Wraith.Models.ListItem, as: 'items'

#
# TodoManager handles all the interaction between the
# components of the todo list.
#
# @include Wraith.Controllers.TodoManager
# @extend Wraith.Controller
#
class Wraith.Controllers.TodoManager extends Wraith.Controller
  view_events: [
    { type: 'keypress', selector: 'input[type=text]', cb: 'inputKeypress' }
  ]

  init: ->
    super()

    @registerModel 'list', new Wraith.Models.List

    list = @models['list']
    items = list.get('items')
    items.create { text: 'Task 1', selected: true }
    items.create { text: 'Task 2' }
    items.create { text: 'Task 3' }

  inputKeypress: (e) =>
    return unless e.keyCode is 13 and (val = e.currentTarget.value) isnt ''
    #@list.items.create { text: val, selected: false }
    #e.currentTarget.value = ''


class Wraith.Views.SelectList extends Wraith.View
  view_events: [
    { type: 'change', selector: 'input[type=checkbox]', cb: 'itemToggle' }
    { type: 'click', selector: 'div.delete', cb: 'itemDelete' }
  ]

  init: ->
    super()

  itemDelete: (e) =>
    $view = @findViewByElement e.currentTarget
    id = @findIdByView $view
    list = @models['list']
    items = list.get('items')
    items.remove id

  itemToggle: (e) =>
    $view = @findViewByElement e.currentTarget
    id = @findIdByView $view
    list = @models['list']
    items = list.get('items')
    item = items.findById id
    item.set('selected', !item.get('selected'))
