class @Wraith.Model extends @Wraith.Base
  @field: (name, opt) ->
    @fields ?= {}
    @fields[name] = opt ? {}

  @hasMany: (klass, opt) ->
    opt ?= {}
    opt.klass ?= klass
    @collections ?= {}
    @collections[opt.as] = opt

  constructor: (attributes) ->
    super()

    # Create unique ID if one doesnt exist
    # Could use a refactor
    @constructor.fields ?= {}
    @constructor.fields['_id'] = { default: Wraith.uniqueId } unless attributes?['_id']

    @listeners = {}
    @attributes = {}
    for name, options of @constructor.fields
      if attributes?[name]?
        d = attributes?[name]
      else
        d = if (Wraith.isFunction(options.default)) then options.default() else options.default
      @set name, d

    for name, options of @constructor.collections
      @attributes[name] = new Wraith.Collection(@, options.as, options.klass)

    Wraith.models[@attributes['_id']] = @

    @

  get: (key) => @attributes?[key]

  set: (key, val) =>
    throw 'Trying to set an non-existent property!' unless field = @constructor.fields[key]
    # Ignore a re-setting of the same value
    return if val == @get(key)
    @attributes[key] = val
    # Emit change events!
    @emit('change', key, val)
    @emit("change:#{key}", val)

  toJSON: => @attributes
