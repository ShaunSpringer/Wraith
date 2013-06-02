describe "Template", ->
  model = null

  class TestModel extends Wraith.Model
    @field "a", { default: false }
    @field "b", { default: true }

  describe "on compile", ->
    $template = null

    beforeEach ->
      $.ajax
        async: false,
        dataType: 'html',
        url: 'fixtures/template.html',
        success: (data) ->
          $('#fixture').html(data)

    afterEach ->
      $('#fixture').html('')

    it "should generate a function as template_fn", ->
      $template = $('#templateText')[0]
      template = new Wraith.Template($template.innerHTML)
      results = template.compile(new TestModel())
      template_fn = template.template_fn
      expect(template_fn).toBeFunction()

    it "should output a compiled template with text interpolation", ->
      $template = $('#templateText')[0]
      template = new Wraith.Template($template.innerHTML)
      results = template.compile(new TestModel())
      results = results.trim()
      results = results.replace /[\t\n\r]*/g, ''
      expect(results).toEqual('<span>a is false</span>  <span>b is true</span>')

    it "should output a compiled template with class interpolation", ->
      $template = $('#templateClass')[0]
      template = new Wraith.Template($template.innerHTML)
      results = template.compile(new TestModel())
      results = results.trim()
      results = results.replace /[\t\n\r]*/g, ''
      expect(results).toBe('<span class="b">false true</span>')

    it "should output a compiled template with class interpolation and merging with existing classes", ->
      $template = $('#templateClasses')[0]
      template = new Wraith.Template($template.innerHTML)
      results = template.compile(new TestModel())
      results = results.trim()
      results = results.replace /[\t\n\r]*/g, ''
      expect(results).toBe('<span class="c b" some-attribute="test" >false true</span>')

