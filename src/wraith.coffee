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
# @version 0.1.0
#
#
class Wraith
  # Essentially allow logging or not
  @DEBUG: false
  # List of controllers keyed by id
  @controllers: {}
  # List of models keyed by id
  @models: {}
  # List of acceptable UIEvents
  @UIEvents: ['click', 'dblclick', 'mousedown', 'mouseup', 'mousemove', 'scroll', 'keypress', 'keyup', 'keydown', 'change', 'blur', 'focus', 'submit']

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
  @uniqueId: (length = 16, prefix = "wraith-") ->
    id = ""
    id += Math.random().toString(36).substr(2) while id.length < length
    id.substr 0, length
    id = prefix + id

# Export Wraith
root = exports ? @
root.Wraith = Wraith
