{spawn, exec} = require 'child_process'
fs            = require 'fs'
{print}       = require 'util'

task 'build', 'continually build with --watch', ->
  coffee = spawn 'coffee', ['-cw', '-o', 'lib', 'src']
  coffee.stdout.on 'data', (data) -> console.log data.toString().trim()

  examples = ['todo']
  for example in examples
    coffee = spawn 'coffee', ['-cw', '-o', 'examples/' + example + '/lib', 'examples/' + example + '/src']
    coffee.stdout.on 'data', (data) -> console.log data.toString().trim()

task 'docs', 'Generate annotated source code with Docco', ->
  fs.readdir 'src', (err, contents) ->
    files = ("src/#{file}" for file in contents when /\.coffee$/.test file)
    docco = spawn 'docco', files
    docco.stdout.on 'data', (data) -> print data.toString()
    docco.stderr.on 'data', (data) -> print data.toString()
    docco.on 'exit', (status) -> callback?() if status is 0
