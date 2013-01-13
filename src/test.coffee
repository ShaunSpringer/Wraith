root = exports ? @
@Models = {}
@Controllers = {}
@Views = {}

class @Models.Test extends Wraith.Model
  @field 'someData'

class @Controllers.Test extends Wraith.Controller
  constructor: ->
    console.log root.Models
