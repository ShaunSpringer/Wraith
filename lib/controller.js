// Generated by CoffeeScript 1.4.0
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  this.Wraith.Controller = (function(_super) {

    __extends(Controller, _super);

    function Controller($el) {
      this.$el = $el;
      this.getModelFromEl = __bind(this.getModelFromEl, this);

      this.handleViewUIEvent = __bind(this.handleViewUIEvent, this);

      this.handleUIEvent = __bind(this.handleUIEvent, this);

      if (Wraith.DEBUG) {
        console.log('@Wraith.Controller', 'constructor');
      }
      Controller.__super__.constructor.call(this, this.$el);
      this.$el.setAttribute('data-id', this.id);
      this.models = [];
      this.views = [];
      this.bindings = [];
    }

    Controller.prototype.init = function() {
      if (Wraith.DEBUG) {
        console.log('@Wraith.Controller', 'init');
      }
      this.findViews();
      return this.bindEvents(this.$el);
    };

    Controller.prototype.findViews = function() {
      var $view, views, _i, _len;
      views = document.querySelectorAll('[data-bind]');
      for (_i = 0, _len = views.length; _i < _len; _i++) {
        $view = views[_i];
        this.registerView($view);
      }
      return this;
    };

    Controller.prototype.registerView = function($view) {
      var binding, maps, repeating, targetModel, template, templateId, textbox, view, _base, _ref, _ref1, _ref2, _ref3;
      if (!(binding = (_ref = $view.attributes['data-bind']) != null ? _ref.value : void 0)) {
        return;
      }
      maps = binding.split('.');
      if (!(targetModel = maps[0])) {
        return;
      }
      repeating = $view.attributes['data-repeat'] !== void 0;
      templateId = (_ref1 = $view.attributes['data-template']) != null ? _ref1.value : void 0;
      if (templateId !== void 0) {
        if (!(template = (_ref2 = document.getElementById(templateId)) != null ? _ref2.innerHTML : void 0)) {
          return;
        }
      } else {
        template = $view.outerHTML;
      }
      textbox = document.createElement('textarea');
      textbox.innerHTML = template;
      template = textbox.value;
      if (repeating) {
        view = new Wraith.CollectionView($view, template);
      } else {
        view = new Wraith.ViewModel($view, template);
      }
      view.bind('uievent', this.handleViewUIEvent);
      this.views.push(view);
      if ((_ref3 = (_base = this.bindings)[targetModel]) == null) {
        _base[targetModel] = [];
      }
      this.bindings[targetModel].push({
        binding: binding,
        view: view
      });
      return this;
    };

    Controller.prototype.registerModel = function(model, as) {
      if (this.models[as]) {
        throw 'Model name already registered';
      }
      if (!model instanceof Wraith.Model) {
        throw 'Model is not valid';
      }
      this.models[as] = model;
      this.bindViews(as, model);
      return model;
    };

    Controller.prototype.bindViews = function(name, model) {
      var bindings, map, _i, _len;
      if (!(bindings = this.bindings[name])) {
        return;
      }
      for (_i = 0, _len = bindings.length; _i < _len; _i++) {
        map = bindings[_i];
        this.bindView(model, map.binding, map.view);
      }
      return this;
    };

    Controller.prototype.bindView = function(model, binding, view) {
      var map, mapping;
      mapping = binding.split('.');
      map = mapping[1];
      if (map && view instanceof Wraith.CollectionView) {
        model.bind('add:' + map, function(model_) {
          view.createView(model_);
          return model_.bind('change', function() {
            return view.updateView(model_);
          });
        });
        return model.bind('remove:' + map, function(model_) {
          return view.removeView(model_);
        });
      } else if (map) {
        return model.bind('change:' + map, function(model_) {
          return view.updateView(model_);
        });
      } else {
        return model.bind('change', function() {
          return view.updateView(model);
        });
      }
    };

    Controller.prototype.handleUIEvent = function(e, cb) {
      return typeof this[cb] === "function" ? this[cb](e) : void 0;
    };

    Controller.prototype.handleViewUIEvent = function(e, cb) {
      e.model = this.getModelFromEl(e.target);
      return typeof this[cb] === "function" ? this[cb](e) : void 0;
    };

    Controller.prototype.getModelFromEl = function($el) {
      var modelId, _ref;
      while ($el) {
        if (modelId = (_ref = $el.attributes['data-model']) != null ? _ref.value : void 0) {
          break;
        }
        $el = $el.parentNode;
      }
      return Wraith.models[modelId];
    };

    return Controller;

  })(this.Wraith.View);

}).call(this);