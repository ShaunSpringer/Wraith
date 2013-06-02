describe "Collection", ->
  model = null
  items = null

  class TestItem extends Wraith.Model
    @field 'a', { default: false }
    @field 'b', { default: true }

  class TestList extends Wraith.Model
    @field 'a', { default: false }
    @field 'b', { default: true }
    @hasMany TestItem, 'items'

  beforeEach ->
    model = new TestList()
    items = model.get('items')

  describe "on create", ->
    it "should create a new model w/defaults", ->
      item = items.create {}
      expect(items.all().length).toBe(1)
      expect(item.get('a')).toBe(false)
      expect(item.get('b')).toBe(true)

    it "should create a new model w/data", ->
      item = items.create {a: true, b: false}
      expect(items.all().length).toBe(1)
      expect(item.get('a')).toBe(true)
      expect(item.get('b')).toBe(false)

    it "should emit a generic change event", ->
      results = false
      model.bind 'change', (key, val) ->
        results = {key, val}

      items.create {}

      waitsFor (-> results isnt false ), 100

    it "should emit an explicit change event", ->
      results = false
      model.bind 'change:items', (key, val) ->
        results = {key, val}

      items.create {}

      waitsFor (-> results isnt false ), 100


    it "should emit a generic change event when an item updates", ->
      results = false
      item = items.create {}
      model.bind 'change', (key, val) ->
        results = {key, val}

      item.set('a', true)

      waitsFor (-> results isnt false ), 100


    it "should emit an explicit change event when an item updates", ->
      results = false
      item = items.create {}
      model.bind 'change:items', (key, val) ->
        results = {key, val}

      item.set('a', true)

      waitsFor (-> results isnt false ), 100

