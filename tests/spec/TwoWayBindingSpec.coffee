describe "Two Way Binding", ->

  beforeEach ->
    return if window.App.CommentController

    $.ajax
      async: false,
      dataType: 'html',
      url: 'fixtures/twowaybinding.html',
      success: (data) ->
        $('#fixture').append($(data))

        window.App = {}

        class App.Comment extends Wraith.Model
          @field 'comment', { default: '' }

        class App.CommentList extends Wraith.Model
          @hasMany App.Comment, 'comments'

        class App.CommentController extends Wraith.Controller
          init: ->
            super()
            @list = @registerModel new App.CommentList, 'commentlist'

        new Wraith.Bootloader()

  describe "form inputs", ->

    it "should update model on change", ->
      $input = $('input[name=comment]')
      $input.attr('value', 'Super!')
      $input.trigger('keyup')
      waitsFor (-> $('#comment').text() is 'Comment: Super!') , 1

    it "should create a new model on submit", ->
      $form = $('#comments-form')
      $form.submit()
      waitsFor (-> $('#comment-list').first().text() is 'Comment: Super!') , 1
