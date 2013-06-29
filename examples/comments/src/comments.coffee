root = exports ? @
root.App = App = {}

class App.Comment extends Wraith.Model
  @field 'author', { default: '', type: new Wraith.Validators.Text({ min: 1, max: 30 }) }
  @field 'text', { default: '', type: new Wraith.Validators.Text({ min: 1, max: 140 }) }
  @field 'rating', { default: '', type: new Wraith.Validators.Num({ min: 0, max: 5 }) }

class App.CommentList extends Wraith.Model
  @hasMany App.Comment, 'comments'

class App.CommentController extends Wraith.Controller
  init: ->
    super()
    @list = @registerModel new App.CommentList, 'commentlist'
