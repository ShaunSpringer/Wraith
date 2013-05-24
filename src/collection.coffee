
class @Wraith.Collection extends @Wraith.Model
  constructor: (@parent, @as, @klass) ->
    super()
    @members = []

  create: (attr) => @add(new @klass(attr))

  add: (item) =>
    @members.push(item)
    @parent.emit('add:' + @as, item)
    @parent.emit('change:' + @as, @)
    @parent.emit('change', @)
    item.bind('change', item.proxy(@handleChange))
    item

  remove: (id) =>
    for item, i in @members when item.get('_id') is id
      @members.splice(i, 1)
      @parent.emit('remove:' + @as, item)
      @parent.emit('change:' + @as, @)
      @parent.emit('change', @)
      item.unbind('change', item.proxy(@handleChange))
      break
    @

  all: => @members
  length: => @members.length
  at: (index) => @members[index]
  findById: (id) => return item for item, i in @members when item.get('_id') is id
  handleChange: (key, value) => @parent.emit 'change', key, value
