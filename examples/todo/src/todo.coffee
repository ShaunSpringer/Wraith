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
    @list.bind 'remove:items', @remove

    items = @list.items
    items.create { text: 'Task 1', selected: true }
    items.create { text: 'Task 2', selected: false }
    items.create { text: 'Task 3', selected: false }

    @bind 'ui:keypress:input[type=text]', @keypress

  keypress: (e) =>
    return unless e.keyCode is 13
    return unless (val = e.currentTarget.value) isnt ''

    @list.items.create { text: val, selected: false }
    e.currentTarget.value = ''
