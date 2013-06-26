describe "Two Way Binding", ->

  beforeEach ->
    return if window.TwoWayBindingTest

    $.ajax
      async: false,
      dataType: 'html',
      url: 'fixtures/twowaybinding.html',
      success: (data) ->
        $('#fixture').append($(data))

        window.TwoWayBindingTest = {}

        class TwoWayBindingTest.Comment extends Wraith.Model
          @field 'comment', { default: '' }

        class TwoWayBindingTest.CommentList extends Wraith.Model
          @hasMany TwoWayBindingTest.Comment, 'comments'

        class TwoWayBindingTest.CommentController extends Wraith.Controller
          init: ->
            super()
            @list = @registerModel new TwoWayBindingTest.CommentList, 'commentlist'

        new Wraith.Bootloader()

  describe "form inputs", ->

    it "should update model and view on change", ->
      $input = $('input[name=comment]')
      $input.attr('value', 'Super!')
      $input.trigger('keyup')
      waitsFor (-> $('#comment').text() is 'Comment: Super!') , 1

    it "should create a new model on submit", ->
      $input = $('input[name=comment]')
      $input.attr('value', 'Super!')
      $input.trigger('keyup')

      $form = $('#comments-form')
      $form.submit()
      waitsFor (-> $('#comment-list').first().text() is 'Super!') , 1

