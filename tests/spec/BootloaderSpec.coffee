describe "Bootloader", ->

  beforeEach ->
    $.ajax
      async: false,
      dataType: 'html',
      url: 'fixtures/bootloader.html',
      success: (data) -> $('#fixture').append($(data));

  afterEach ->
    $('#fixture').innerHTML = ''

  describe "on initialization", ->

    beforeEach ->
      window.App = {}
      class App.TestController extends Wraith.Controller
      new Wraith.Bootloader()

    it "should load all controllers on the page", ->
      len = 0
      len++ for k of Wraith.controllers
      expect(len).toBe(1)
