// Generated by CoffeeScript 1.4.0
(function() {

  describe("Base", function() {
    var base;
    base = null;
    beforeEach(function() {
      return base = new Wraith.Base();
    });
    describe("on bind", function() {
      it("should throw an exception if callback is not a function", function() {
        return expect(function() {
          return base.bind('testevent', null);
        }).toThrow("Callback is not a function");
      });
      return it("should store callback to the listeners array", function() {
        base.bind('testevent', function() {
          return void 0;
        });
        return expect(base.listeners['testevent'].length).toBe(1);
      });
    });
    describe("on emit", function() {
      it("should handle the emitted response w/o data", function() {
        var val;
        val = false;
        base.bind('testevent', function() {
          return val = true;
        });
        base.emit('testevent');
        return expect(val).toBe(true);
      });
      return it("handle the emitted response w/data", function() {
        var data, val;
        val = false;
        data = {
          a: true,
          b: true
        };
        base.bind('testevent', function(resp) {
          return val = resp;
        });
        base.emit('testevent', data);
        return expect(val).toBe(data);
      });
    });
    return describe("on unbind", function() {
      return it("should remove all corresponding listeners", function() {
        var cb;
        cb = function() {
          return void 0;
        };
        base.bind('testevent', cb);
        base.unbind('testevent', cb);
        return expect(base.listeners['testevent'].length).toBe(0);
      });
    });
  });

}).call(this);
