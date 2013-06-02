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

  describe "on item create", ->
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

  describe "on item change", ->
    item = null
    beforeEach ->
      item = items.create {}

    it "should emit a generic change event", ->
      results = false
      model.bind 'change', (key, val) ->
        results = {key, val}

      item.set('a', true)
      waitsFor (-> results isnt false ), 100

    it "should emit an explicit change event w/key and value of change", ->
      results = false
      model.bind 'change:items', (key, val) ->
        results = {key, val}

      item.set('a', true)
      waitsFor (-> results.key is 'a' and results.val is true ), 100


  describe "on item remove", ->
    item = null
    beforeEach ->
      item = items.create {}

    it "should emit a generic change event", ->
      results = false
      model.bind 'change', ->
        results = true

      items.remove item.get('_id')

      waitsFor (-> results isnt false), 100

    it "should emit a generic remove event", ->
      results = false
      model.bind 'remove', (item_) ->
        results = item_

      items.remove item.get('_id')
      waitsFor (-> results is item), 100


    it "should emit an explicit remove event", ->
      results = false
      model.bind 'remove:items', (item_) ->
        results = item_

      items.remove item.get('_id')
      waitsFor (-> results is item), 100

