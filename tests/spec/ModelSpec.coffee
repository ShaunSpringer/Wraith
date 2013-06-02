describe "Model", ->
  model = null

  class TestModel extends Wraith.Model
    @field "a", { default: false }
    @field "b", { default: true }

  beforeEach ->
    model = new TestModel()

  it "should have get and set functions", ->
    expect(model.get).toBeFunction()
    expect(model.set).toBeFunction()

  describe "on creation", ->
    it "should have getters for each field", ->
      expect(model.get('a')).toExist()
      expect(model.get('b')).toExist()

    it "should have defaults for each field", ->
      expect(model.get('a')).toBe(false)
      expect(model.get('b')).toBe(true)

    it "should be initialized with custom data", ->
      model_ = new TestModel({ a: true, b: false })
      expect(model_.get('a')).toBe(true)
      expect(model_.get('b')).toBe(false)

  describe "on set", ->
    it "should update the field to the desired value", ->
      expect(model.get('a')).toBe(false)
      model.set('a', true)
      expect(model.get('a')).toBe(true)

    it "should emit a generic change event", ->
      val = false
      model.bind 'change', -> val = true
      model.set('a', true)
      waitsFor (-> val is true), 100

    it "should emit an explicit event", ->
      val = false
      model.bind 'change:a', -> val = true
      model.set('a', true)
      waitsFor (-> val is true), 100

