describe "Base", ->
  base = null

  beforeEach ->
    base = new Wraith.Base()


  describe "on bind", ->
    it "should throw an exception if callback is not a function", ->
      expect ->
        base.bind('testevent', null)
      .toThrow("Callback is not a function")

    it "should store callback to the listeners array", ->
      base.bind 'testevent', -> undefined
      expect(base.listeners['testevent'].length).toBe(1)


  describe "on emit", ->
    it "should handle the emitted response w/o data", ->
      # this would only work with bind calling emit directly on the stack,
      # otherwise if it was async it would fail.
      val = false

      base.bind 'testevent', -> val = true
      base.emit 'testevent'

      expect(val).toBe(true)

    it  "should handle the emitted response w/data", ->
      # this would only work with bind calling emit directly on the stack,
      # otherwise if it was async it would fail.
      val = false

      data = {a: true, b: true}

      base.bind 'testevent', (resp) -> val = resp
      base.emit 'testevent', data

      expect(val).toBe(data)


  describe "on unbind", ->
    it "should remove all corresponding listeners", ->
      cb = -> undefined
      base.bind 'testevent', cb
      base.unbind 'testevent', cb
      expect(base.listeners['testevent'].length).toBe(0)
