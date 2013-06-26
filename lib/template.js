// Generated by CoffeeScript 1.4.0
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  this.Wraith.Template = (function(_super) {

    __extends(Template, _super);

    function Template(template) {
      this.template = template;
      if (Wraith.DEBUG) {
        console.log('@Wraith.Template', 'constructor');
      }
      if (!this.template) {
        throw 'Template is required';
      }
      this.template_fn = Wraith.compile(this.template);
    }

    Template.prototype.render = function(data) {
      return this.template_fn(data);
    };

    return Template;

  })(this.Wraith.Base);

}).call(this);