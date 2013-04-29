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
  init: ->
    super()
    #@bind 'ui:keypress:input[type=text]', @inputKeypress

  inputKeypress: (e) =>
    return unless e.keyCode is 13 and (val = e.currentTarget.value) isnt ''
    #@list.items.create { text: val, selected: false }
    #e.currentTarget.value = ''


class Wraith.Controllers.SelectList extends Wraith.Controller
  view_events: [
    { type: 'change', selector: 'input[type=checkbox]', cb: 'itemToggle' }
    { type: 'click', selector: 'div.delete', cb: 'itemDelete' }
  ]

  init: ->
    super()
    @list = new Wraith.Models.List

    items = @list.get('items')
    items.create { text: 'Task 1', selected: true }
    items.create { text: 'Task 2' }
    items.create { text: 'Task 3' }

  itemDelete: (e) =>
    return unless id = @findViewOfElement e.currentTarget
    items = @list.get('items')
    item = items.findById id
    items.remove id

  itemToggle: (e) =>
    return unless id = @findViewOfElement e.currentTarget
    items = @list.get('items')
    item = items.findById id
    item.set('selected', !item.get('selected'))
