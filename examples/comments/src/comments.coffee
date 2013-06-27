root = exports ? @
root.App = App = {}

class App.Comment extends Wraith.Model
  @field 'author', { default: '', type: new Wraith.Validators.Text({ min: 2, max: 30 }) }
  @field 'text', { default: '', type: new Wraith.Validators.Text({ min: 2, max: 140 }) }

class App.CommentList extends Wraith.Model
  @hasMany App.Comment, 'comments'

class App.CommentController extends Wraith.Controller
  init: ->
    super()
    @list = @registerModel new App.CommentList, 'commentlist'
