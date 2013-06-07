root = @ ? exports
root.App = App = {}

class App.Comment extends Wraith.Model
  @field 'author', { default: 'Author' }
  @field 'text', { default: 'Comment' }

class App.CommentList extends Wraith.Model
  @hasMany App.Comment, 'comments'

class App.CommentController extends Wraith.Controller
  init: ->
    super()
    @list = @registerModel new App.CommentList, 'commentlist'
    @comments = @list.get('comments')
    @comments.create { author: 'ShaunSpringer', text: 'This is a comment' }

  formSubmit: (e) ->
    e.preventDefault()
    @comments.create { author: @$els['author'].value, text: @$els['comment'].value }
    @$els['author'].value = @$els['comment'].value = ''
