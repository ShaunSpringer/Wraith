{spawn, exec} = require 'child_process'
fs            = require 'fs'
{print}       = require 'util'

task 'build', 'Continually build', ->
  coffee = spawn 'coffee', ['-cw', '-o', 'lib', 'src']
  coffee.stdout.on 'data', (data) -> console.log data.toString().trim()
  coffee.stderr.on 'data', (data) -> console.log data.toString().trim()

  examples = [
    { base: 'todo', dest: 'lib', source: 'src' }
    { base:'todomvc/architecture-examples/wraith', dest: 'js', source: 'src' }
  ]
  for example in examples
    coffee = spawn 'coffee', [
      '-cw'
      '-o'
      'examples/' + example.base + '/' + example.dest
      'examples/' + example.base + '/' + example.source
    ]
    coffee.stdout.on 'data', (data) -> console.log data.toString().trim()
    coffee.stderr.on 'data', (data) -> console.log data.toString().trim()

task 'docs', 'Generate annotated source code with Codo', ->
  fs.readdir 'src', (err, contents) ->
    files = ("src/#{file}" for file in contents when /\.coffee$/.test file)
    docco = spawn 'codo', files
    docco.stdout.on 'data', (data) -> print data.toString()
    docco.stderr.on 'data', (data) -> print data.toString()
    docco.on 'exit', (status) -> callback?() if status is 0

task 'server', 'run a python simple server', ->
  server = spawn 'python', ['-m', 'SimpleHTTPServer']
  server.stdout.on 'data', (data) -> console.log data.toString().trim()
