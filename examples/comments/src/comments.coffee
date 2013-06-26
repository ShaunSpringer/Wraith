root = exports ? @
root.App = App = {}

class App.Comment extends Wraith.Model
  @field 'author', { default: '' }
  @field 'text', { default: '' }

class App.CommentList extends Wraith.Model
  @hasMany App.Comment, 'comments'

class App.CommentController extends Wraith.Controller
  init: ->
    super()
    @list = @registerModel new App.CommentList, 'commentlist'
