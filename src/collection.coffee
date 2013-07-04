#
# The Collection object is a collection of {Wraith.Model}'s that are
# accessed through
# Credit goes out to Alex MacCaw and his Spine framework for very
# obvious inspiration.
#
class Wraith.Collection extends Wraith.Model
  #
  # Sets up the parent, namespace (@as) and {Wraith.Model} class.
  #
  # @param [Wraith.Model] parent The parent model of this collection.
  # @param [String] as The name space that this collection is stored as on the parent.
  # @param [Wraith.Model] klass The {Wraith.Model} that is used to create each item in the collection.
  #
  constructor: (@parent, @as, @klass) ->
    Wraith.log '@Wraith.Collection', 'constructor'
    super()
    @members = []

  #
  # Creates a new instance of the {Wraith.Model} belonging to this
  # collection.
  #
  # @param [Object] attr The attributes object used to initialize the model.
  #
  # @return [Wraith.Model] The model object created.
  #
  create: (attr) => @add(new @klass(attr))

  #
  # Adds the given instance of a {Wraith.Model} to the collection.
  #
  # @param [Wraith.Model] item The {Wraith.Model} instance to add to the collection.
  #
  # @return [Wraith.Model] The item that was added to the collection (same as what was passed in)
  #
  add: (item) =>
    @members.push(item)
    @parent.emit('ad:', item)
    @parent.emit('add:' + @as, item)
    @parent.emit('change:' + @as, @)
    @parent.emit('change', @)
    item.bind('change', item.proxy(@handleChange))
    item

  #
  # Removes a model from the collection, by ID (the _id attribute).
  #
  # @param [String] id The id of the {Wraith.Model} to remove.
  #
  # @return [Wraith.Model, Boolean] The item that was removed from the collection or false if not found.
  #
  remove: (id) =>
    for item, i in @members when item.get('_id') is id
      @members.splice(i, 1)
      @parent.emit('remove', item)
      @parent.emit('remove:' + @as, item)
      @parent.emit('change:' + @as, @)
      @parent.emit('change', @)
      item.unbind('change', item.proxy(@handleChange))
      return item
    return false

  #
  # Returns all members of the collection as an array.
  #
  # @return [Array<Wraith.Model>] The array of member objects
  #
  all: => @members

  #
  # Returns the length of the members array.
  #
  # @return [Number] The length of the members array (0 or greater)
  #
  length: => @members.length

  #
  # Finds a given model within the collection by id (_id property)
  #
  # @param [String] id The id to search for
  #
  # @return [Wraith.Model] The model with the given id
  #
  findById: (id) => return item for item, i in @members when item.get('_id') is id

  #
  # Acts as a wrapper for handling the change function coming from a model
  # within the collection. This emits a change event from the parent whenever
  # a change happens on a model.
  #
  # @param [String] key The key of the changed model value
  # @param [String, Object, Boolean] value The changed value itself
  #
  handleChange: (key, value) =>
    @parent.emit 'change:' + @as, key, value
    @parent.emit 'change', key, value
