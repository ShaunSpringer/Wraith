
#
# Our bootloader object. This should be
# instantiated after all JS is loaded on the page
#
# @example
#   bootloader = new Wraith.Bootloader
#
# @include Wraith.Bootloader
#
class @Wraith.Bootloader
  #
  # Constructor
  #
  constructor: ->
    controllers = document.querySelectorAll('[data-controller]')
    for $controller in controllers
      @loadController $controller.attributes['data-controller'].value, $controller

    # Activate our controllers via .init
    for id, controller of Wraith.controllers
      controller.init()
    @

  #
  # Loads a given controller by id and HTML element
  # @param [String] id The controllers id
  # @param [Object] $item The HTML element to bind to
  #
  loadController: (id, $item) ->
    throw 'Controller does not exist' unless Controller = Wraith.Controllers[id]
    controller = new Controller($item)
    Wraith.controllers[controller.id] = controller
