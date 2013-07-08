#
# Our data model used throughout the application. Currently it is requred
# to do any data-binding or data-mapping in the views.
# Credit goes out to Alex MacCaw and his Spine framework for very
# obvious inspiration.
#
class Wraith.Model extends Wraith.Base
  #
  # Sets up a field with the given name and options.
  #
  # @param [String] name The name of the field to setup
  # @param [Object] opt The options object (optional). Used to setup defaults.
  #
  @field: (name, opt) ->
    @fields ?= {}
    @fields[name] = opt ? {}

  #
  # Sets up a collection given the {Wraith.Collection} object
  # and options object.
  #
  # @param [Wraith.Collection] klass The collection object to use.
  # @param [String] as The name of the collection within this model.
  # @param [Object] opt The options to apply to this collection.
  #
  @hasMany: (klass, as, opt) ->
    opt ?= {}
    opt.klass ?= klass
    opt.as ?= as
    @collections ?= {}
    @collections[as] = opt

  @storage: (@StorageType) -> @

  #
  # Constructor
  #
  # @param [Object] attributes An attributes object to apply to the model upon intialization.
  #
  constructor: (attributes, @as) ->
    Wraith.log '@Wraith.Model', 'constructor'
    super()

    # Create unique ID if one doesnt exist
    # @todo Could use a refactor
    @constructor.fields ?= {}
    @constructor.fields['_id'] = { default: Wraith.uniqueId } unless attributes?['_id']

    @storage_ = undefined
    if Wraith.isFunction(@constructor.StorageType)
      @storage_ = new @constructor.StorageType @

    @errorCache_ = {}

    @reset attributes

    Wraith.models[@attributes['_id']] = @

    @

  #
  # Perform a reset of the models attributes. Will trigger
  # "change" events on each property that is reset.
  #
  # @param [Object] attributes Contains all default data to be
  #   applied to the object when being reset.
  #
  reset: (attributes) ->
    @attributes = {}

    if options = @constructor.fields['_id']
      @attributes['_id'] = if (Wraith.isFunction(options['default'])) then options['default']() else options['default']

    for name, options of @constructor.fields
      if attributes?[name]?
        d = attributes[name]
      else
        d = if (Wraith.isFunction(options['default'])) then options['default']() else options['default']
      @set name, d

    for name, options of @constructor.collections
      @attributes[name] = new Wraith.Collection(@, options.as, options.klass)

    @
  #
  # Returns the value for the given key. Will return undefined if
  # not found on the attributes list.
  #
  # @param [String] key The key to look up.
  #
  # @return [Object, String, Boolean, Number] The value stored at attributes.key
  #
  get: (key) => @attributes?[key]

  #
  # Sets the given attributes.key value to val. Warning: if the key is not found
  # on attributes, it will throw an error.
  #
  # @params [String] key The key of the attributes object to set.
  # @params [Object, String, Boolean, Number] val The value to update the given key to.
  #
  set: (key, val) =>
    throw 'Trying to set an non-existent property!' unless field = @constructor.fields[key]
    # Ignore a re-setting of the same value
    return if val == @get(key)

    isValid = false
    validator = @constructor.fields[key]['type']
    if validator and validator instanceof Wraith.Validator
      isValid = validator.isValid(val)
      if isValid isnt true
        @errorCache_[key] = isValid
        @emit('change', 'errors', isValid)
        @emit('change:' + 'errors', isValid)

    if isValid is true and cached = @errorCache_[key]
      @emit('change', 'errors', isValid)
      @emit('change:' + 'errors', isValid)
      delete @errorCache_[key]

    @attributes[key] = val

    # Emit change events!
    @emit('change', key, val)
    @emit('change:' + key, val)

  #
  # Checks to see if there are any errors on the models.
  # An error cache is stored privately so its as easy as checking
  # if there is anything in that object.
  #
  # @return [Boolean] If the model is valid or not
  #
  isValid: =>
    return false for key, msg of @errorCache_
    return true

  #
  # Returns an object with errors stored on it.
  # Errors are stored with key as the attribute name
  # and the value as the error.
  #
  # @return [Object] The associative array of errors
  #
  errors: => @errorCache_

  #
  # "Serializes" the model's attributes as JSON.
  # (Really just returns the attributes object)
  #
  # @return [Object] The attributes object belonging to this {Wraith.Model} instance.
  #
  toJSON: => Wraith.clone(@attributes)

