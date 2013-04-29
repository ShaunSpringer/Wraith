root = exports ? @


class Wraith.Models.ListItem extends Wraith.Model
  @field 'text', { default: 'New Item' }
  @field 'selected', { default: false }


class Wraith.Models.List extends Wraith.Model
  @hasMany Wraith.Models.ListItem, as: 'items'


class Wraith.Controllers.SelectList extends Wraith.Controller
  view: 'ListItem'
  events: [
    { type: 'click', selector: 'div.delete', cb: 'itemDeleteClick' }
  ]

  init: ->
    super()
    @list = new Wraith.Models.List
    @list.bind 'add:items', @add
    @list.bind 'remove:items', @remove

    items = @list.get('items')
    items.create { text: 'Task 1', selected: true }
    items.create { text: 'Task 2' }
    items.create { text: 'Task 3' }

  itemDeleteClick: (e) =>
    return unless id = @findByEl e.currentTarget
    items = @list.get('items')
    item = items.findById id
    items.remove item


class Wraith.Controllers.TaskManager extends Wraith.Controller
  init: ->
    super()
    #@bind 'ui:keypress:input[type=text]', @inputKeypress

  inputKeypress: (e) =>
    return unless e.keyCode is 13 and (val = e.currentTarget.value) isnt ''
    #@list.items.create { text: val, selected: false }
    #e.currentTarget.value = ''

