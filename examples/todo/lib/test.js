// Generated by CoffeeScript 1.4.0
(function() {
  var root,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  root = typeof exports !== "undefined" && exports !== null ? exports : this;

  Wraith.Models.ListItem = (function(_super) {

    __extends(ListItem, _super);

    function ListItem() {
      return ListItem.__super__.constructor.apply(this, arguments);
    }

    ListItem.field('text', {
      "default": 'New Item'
    });

    ListItem.field('selected', {
      "default": false
    });

    return ListItem;

  })(Wraith.Model);

  Wraith.Models.List = (function(_super) {

    __extends(List, _super);

    function List() {
      return List.__super__.constructor.apply(this, arguments);
    }

    List.hasMany(Wraith.Models.ListItem, {
      as: 'items'
    });

    return List;

  })(Wraith.Model);

  Wraith.Controllers.SelectList = (function(_super) {

    __extends(SelectList, _super);

    function SelectList() {
      this.update = __bind(this.update, this);

      this.add = __bind(this.add, this);
      return SelectList.__super__.constructor.apply(this, arguments);
    }

    SelectList.prototype.view = 'ListItem';

    SelectList.prototype.init = function() {
      var items, self;
      this.View = Wraith.Views[this.view];
      this.list = new Wraith.Models.List;
      this.list.bind('add:items', this.add);
      items = this.list.items;
      items.create({
        text: 'Test 1',
        selected: true
      });
      items.create({
        text: 'Test 2',
        selected: false
      });
      self = this;
      Wraith.delay(1000, function() {
        return self.list.items.at(0).set('text', 'Test 4');
      });
      return Wraith.delay(2000, function() {
        return self.list.items.at(1).set('text', 'Test 5');
      });
    };

    SelectList.prototype.add = function(model) {
      var self;
      self = this;
      this.append(this.View.render(model));
      return model.bind('change', function() {
        return self.update(model);
      });
    };

    SelectList.prototype.update = function(model) {
      var $view;
      $view = $('#' + model.get('_id'));
      return $view.html(this.View.render(model));
    };

    return SelectList;

  })(Wraith.Controller);

}).call(this);