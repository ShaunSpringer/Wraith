#
# The bootloader object. This should be
# instantiated after all JS is loaded on the page.
# It will search the DOM for elements with the
# data-controller attribute and try to load their respective
# controller from the global namespace. It is acceptable
# to use dot notation to do so, e.g. App.Controller
#
# @example
#   bootloader = new Wraith.Bootloader
#
class Wraith.Bootloader
  #
  # Constructor
  #
  constructor: ->
    controllers = document.querySelectorAll('[data-controller]')
    @loadController $controller.attributes['data-controller'].value, $controller for $controller in controllers

    # Activate our controllers via .init
    controller.init() for id, controller of Wraith.controllers
    @

  #
  # Loads a given controller by id and HTML element
  #
  # @param [String] id The controllers id
  # @param [Object] $item The HTML element to bind to
  #
  loadController: (id, $item) ->
    obj = root
    id.replace /[^\.]+/g, (m) -> obj = obj[m]
    throw 'Controller does not exist' unless Controller = obj
    controller = new Controller($item)
    Wraith.controllers[controller.id] = controller
