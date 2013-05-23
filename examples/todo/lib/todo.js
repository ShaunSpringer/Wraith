// Generated by CoffeeScript 1.6.2
(function() {
  var root, _ref, _ref1, _ref2,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  root = typeof exports !== "undefined" && exports !== null ? exports : this;

  Wraith.Models.ListItem = (function(_super) {
    __extends(ListItem, _super);

    function ListItem() {
      _ref = ListItem.__super__.constructor.apply(this, arguments);
      return _ref;
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
      _ref1 = List.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    List.hasMany(Wraith.Models.ListItem, {
      as: 'items'
    });

    return List;

  })(Wraith.Model);

  Wraith.Controllers.TodoManager = (function(_super) {
    __extends(TodoManager, _super);

    function TodoManager() {
      this.itemToggle = __bind(this.itemToggle, this);
      this.itemDelete = __bind(this.itemDelete, this);
      this.inputKeypress = __bind(this.inputKeypress, this);      _ref2 = TodoManager.__super__.constructor.apply(this, arguments);
      return _ref2;
    }

    TodoManager.prototype.init = function() {
      TodoManager.__super__.init.call(this);
      this.registerModel('list', new Wraith.Models.List);
      this.list = this.models['list'];
      this.items = this.list.get('items');
      this.items.create({
        text: 'Task 1',
        selected: true
      });
      this.items.create({
        text: 'Task 2'
      });
      return this.items.create({
        text: 'Task 3'
      });
    };

    TodoManager.prototype.inputKeypress = function(e) {
      var val;

      if (!(e.keyCode === 13 && (val = e.currentTarget.value) !== '')) {
        return;
      }
      this.items.create({
        text: val,
        selected: false
      });
      return e.currentTarget.value = '';
    };

    TodoManager.prototype.itemDelete = function(e) {
      return this.items.remove(e.model.get('_id'));
    };

    TodoManager.prototype.itemToggle = function(e) {
      return e.model.set('selected', !e.model.get('selected'));
    };

    return TodoManager;

  })(Wraith.Controller);

}).call(this);
