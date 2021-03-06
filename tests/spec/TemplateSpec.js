// Generated by CoffeeScript 1.6.3
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  describe("Template", function() {
    var TestModel, model, _ref;
    model = null;
    TestModel = (function(_super) {
      __extends(TestModel, _super);

      function TestModel() {
        _ref = TestModel.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      TestModel.field("a", {
        "default": false
      });

      TestModel.field("b", {
        "default": true
      });

      return TestModel;

    })(Wraith.Model);
    return describe("on compile", function() {
      var $template;
      $template = null;
      beforeEach(function() {
        return $.ajax({
          async: false,
          dataType: 'html',
          url: 'fixtures/template.html',
          success: function(data) {
            return $('#fixture').html(data);
          }
        });
      });
      afterEach(function() {
        return $('#fixture').html('');
      });
      it("should generate a function as template_fn", function() {
        var results, template, template_fn;
        $template = $('#templateText')[0];
        template = new Wraith.Template($template.innerHTML);
        results = template.compile(new TestModel());
        template_fn = template.template_fn;
        return expect(template_fn).toBeFunction();
      });
      it("should output a compiled template with text interpolation", function() {
        var results, template;
        $template = $('#templateText')[0];
        template = new Wraith.Template($template.innerHTML);
        results = template.compile(new TestModel());
        results = results.trim();
        results = results.replace(/[\t\n\r]*/g, '');
        return expect(results).toEqual('<span>a is false</span>  <span>b is true</span>');
      });
      it("should output a compiled template with class interpolation", function() {
        var results, template;
        $template = $('#templateClass')[0];
        template = new Wraith.Template($template.innerHTML);
        results = template.compile(new TestModel());
        results = results.trim();
        results = results.replace(/[\t\n\r]*/g, '');
        return expect(results).toBe('<span class="b">false true</span>');
      });
      return it("should output a compiled template with class interpolation and merging with existing classes", function() {
        var results, template;
        $template = $('#templateClasses')[0];
        template = new Wraith.Template($template.innerHTML);
        results = template.compile(new TestModel());
        results = results.trim();
        results = results.replace(/[\t\n\r]*/g, '');
        return expect(results).toBe('<span class="c b" some-attribute="test" >false true</span>');
      });
    });
  });

}).call(this);
