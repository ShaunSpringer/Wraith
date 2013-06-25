// Generated by CoffeeScript 1.6.3
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  describe("Two Way Binding", function() {
    beforeEach(function() {
      if (window.App.CommentController) {
        return;
      }
      return $.ajax({
        async: false,
        dataType: 'html',
        url: 'fixtures/twowaybinding.html',
        success: function(data) {
          var _ref, _ref1, _ref2;
          $('#fixture').append($(data));
          window.App = {};
          App.Comment = (function(_super) {
            __extends(Comment, _super);

            function Comment() {
              _ref = Comment.__super__.constructor.apply(this, arguments);
              return _ref;
            }

            Comment.field('comment', {
              "default": ''
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
          return new Wraith.Bootloader();
        }
      });
    });
    return describe("form inputs", function() {
      it("should update model on change", function() {
        var $input;
        $input = $('input[name=comment]');
        $input.attr('value', 'Super!');
        $input.trigger('keyup');
        return waitsFor((function() {
          return $('#comment').text() === 'Comment: Super!';
        }), 1);
      });
      return it("should create a new model on submit", function() {
        var $form;
        $form = $('#comments-form');
        $form.submit();
        return waitsFor((function() {
          return $('#comment-list').first().text() === 'Comment: Super!';
        }), 1);
      });
    });
  });

}).call(this);
