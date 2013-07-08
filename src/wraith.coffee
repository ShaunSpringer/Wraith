###
**************************************************************************************
  The MIT License (MIT)

  Copyright (c) 2013 Shaun Springer

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE.
**************************************************************************************
###

#
# Global Wraith Object
# Contains a list of Collections, Models, and Controllers
#
# @author Shaun Springer
# @copyright Shaun Springer
# @version 0.1.2
#
#
class Wraith
  # Version number
  @version: '0.1.2'

  # Essentially allow logging or not
  @DEBUG: false

  # List of acceptable UIEVENTS
  @UIEVENTS: ['click', 'dblclick', 'mousedown', 'mouseup', 'mousemove', 'scroll', 'keypress', 'keyup', 'keydown', 'change', 'blur', 'focus', 'submit']

  # List of controllers keyed by id
  @controllers: {}

  # List of models keyed by id
  @models: {}

  # The global validators object
  @Validators: {}

  # List of storage types
  @Storage: {}

  #
  # Logs to the console if DEBUG is set to true
  #
  @log: (args ...) -> if Wraith.DEBUG then console.log args ...

  #
  # Checks to see if a given object
  # is a funciton.
  # @param [Object] obj The object to test
  #
  @isFunction: (obj) -> Object.prototype.toString.call(obj) == '[object Function]'

  #
  # Generates a UID at the desired length
  # @param [Number] length Desired length of the UID
  # @param [String] prefix A prefix to append to the UID
  #
  @uniqueId: ->
    'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) ->
      r = Math.random() * 16 | 0
      v = if c is 'x' then r else (r & 0x3|0x8)
      v.toString(16)
    )

  # From: http://coffeescriptcookbook.com/chapters/classes_and_objects/cloning
  @clone: (obj, deep = false) ->
    if not obj? or typeof obj isnt 'object'
      return obj

    if obj instanceof Date
      return new Date(obj.getTime())

    if obj instanceof RegExp
      flags = ''
      flags += 'g' if obj.global?
      flags += 'i' if obj.ignoreCase?
      flags += 'm' if obj.multiline?
      flags += 'y' if obj.sticky?
      return new RegExp(obj.source, flags)

    if not deep
      return obj

    newInstance = new obj.constructor()

    for key of obj
      newInstance[key] = Wraith.clone obj[key]

    return newInstance

# Export Wraith
root = exports ? @
root.Wraith = Wraith
