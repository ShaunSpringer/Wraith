describe "Model", ->
  model = null

  class TestModel extends Wraith.Model
    @field "a", { default: false }
    @field "b", { default: true }
    @field "t", { default: '', type: new Wraith.Validators.Text({ min: 0, max: 5 }) }
    @field "n", { default: 0, type: new Wraith.Validators.Num({ min: 0, max: 5 }) }

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
      waitsFor (-> val is true), 1

    it "should emit an explicit change event", ->
      val = false
      model.bind 'change:a', -> val = true
      model.set('a', true)
      waitsFor (-> val is true), 1

    it "should validate Wraith.Validators.Num typed fields and enforce min, max, and numbers", ->
      # Reset to make sure no other errors are there
      model.reset()

      model.set('n', -1)
      expect(model.isValid()).toBe(false)

      model.set('n', 0)
      expect(model.isValid()).toBe(true)

      model.set('n', 5)
      expect(model.isValid()).toBe(true)

      model.set('n', 6)
      expect(model.isValid()).toBe(false)

      model.set('n', 'gooby')
      expect(model.isValid()).toBe(false)

      model.set('n', 3)
      expect(model.isValid()).toBe(true)

    it "should validate Wraith.Validators.Text typed fields and enforce min, and max character lengths", ->
      # Reset to make sure no other errors are there
      model.reset()

      model.set('t', 'go')
      expect(model.isValid()).toEqual(true)

      model.set('t', 'gooby!')
      expect(model.isValid()).toEqual(false)

      model.set('t', 'gooby')
      expect(model.isValid()).toEqual(true)

  describe "on reset", ->
    it "should reset all properties", ->
      model.reset()
      expect(model.get('a')).toBe(false)
      expect(model.get('b')).toBe(true)
      expect(model.get('n')).toBe(0)
      expect(model.get('t')).toBe('')


