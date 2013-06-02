{spawn, exec} = require 'child_process'
fs            = require 'fs'
{print}       = require 'util'

task 'build', 'Continually build', ->

  sourceFiles = [
    'src/wraith.coffee'
    'src/bootloader.coffee'
    'src/base.coffee'
    'src/model.coffee'
    'src/collection.coffee'
    'src/template.coffee'
    'src/baseview.coffee'
    'src/viewmodel.coffee'
    'src/collectionview.coffee'
    'src/controller.coffee'
  ]

  coffee = exec 'coffee -j lib/wraith.js -cw ' + sourceFiles.join(' ')
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

task 'minify', 'Builds and then minifies Wraith', ->
  uglify = exec 'uglifyjs -nc lib/wraith.js -o lib/wraith.min.js'
  uglify.stdout.on 'data', (data) -> console.log data.toString().trim()
  uglify.stderr.on 'data', (data) -> console.log data.toString().trim()

task 'docs', 'Generate annotated source code with Codo', ->
  fs.readdir 'src', (err, contents) ->
    files = ("src/#{file}" for file in contents when /\.coffee$/.test file)
    docco = spawn 'codo', files, '-d'
    docco.stdout.on 'data', (data) -> print data.toString().trim()
    docco.stderr.on 'data', (data) -> print data.toString().trim()
    docco.on 'exit', (status) -> callback?() if status is 0

task 'server', 'run a python simple server', ->
  server = spawn 'python', ['-m', 'SimpleHTTPServer']
  server.stdout.on 'data', (data) -> console.log data.toString().trim()
