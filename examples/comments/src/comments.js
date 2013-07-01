// Generated by CoffeeScript 1.6.3
(function() {
  var App, root, _ref, _ref1, _ref2,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  root = typeof exports !== "undefined" && exports !== null ? exports : this;

  root.App = App = {};

  App.Comment = (function(_super) {
    __extends(Comment, _super);

    function Comment() {
      _ref = Comment.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    Comment.field('author', {
      "default": '',
      type: new Wraith.Validators.Text({
        min: 1,
        max: 30
      })
    });

    Comment.field('text', {
      "default": '',
      type: new Wraith.Validators.Text({
        min: 1,
        max: 140
      })
    });

    Comment.field('rating', {
      "default": '',
      type: new Wraith.Validators.Num({
        min: 0,
        max: 5
      })
    });

    return Comment;

  })(Wraith.Model);

  App.CommentList = (function(_super) {
    __extends(CommentList, _super);

    function CommentList() {
      _ref1 = CommentList.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    CommentList.hasMany(App.Comment, 'comments');

    return CommentList;

  })(Wraith.Model);

  App.CommentController = (function(_super) {
    __extends(CommentController, _super);

    function CommentController() {
      _ref2 = CommentController.__super__.constructor.apply(this, arguments);
      return _ref2;
    }

    CommentController.prototype.init = function() {
      CommentController.__super__.init.call(this);
      return this.list = this.registerModel(new App.CommentList, 'commentlist');
    };

    return CommentController;

  })(Wraith.Controller);

}).call(this);
