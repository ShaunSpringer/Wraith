{spawn, exec} = require 'child_process'
fs            = require 'fs'
{print}       = require 'util'

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

examples = [
  { base: 'examples/todo/', dest: 'lib', source: 'src' }
  { base:'examples/todomvc/architecture-examples/wraith/', dest: 'js', source: 'src' }
]

tests = [
  { base: 'tests/', dest: 'spec', source: 'spec' }
]

compile = (source, dest, watch, join) ->
  params = [
    if watch then '-cw' else '-c',
    if join then '-j' else '' ,
    if join then dest else source,
    if join then source else dest
  ]

  coffee = exec 'coffee ' + params.join(' ')

  coffee.stdout.on 'data', (data) -> console.log data.toString().trim()
  coffee.stderr.on 'data', (data) -> console.log data.toString().trim()

task 'watchwraith', 'Continuously Watch/Build', -> compile sourceFiles.join(' '), 'lib/wraith.js', true, true
task 'buildwraith', 'Builds Wraith', -> compile(sourceFiles.join(' '), 'lib/wraith.js', false, true)

task 'buildexamples', 'Builds Examples', ->
  for example in examples
    compile example.base + example.source, example.base + example.dest, false, false

task 'watchexamples', 'Watches Examples', ->
  for example in examples
    compile example.base + example.source, example.base + example.dest, true, false

task 'buildtests', 'Builds Tests', ->
  for test in tests
    compile test.base + test.source, test.base + test.dest, false, false

task 'watchtests', 'Watches Tests', ->
  for test in tests
    compile test.base + test.source, test.base + test.dest, true, false

task 'build', 'Builds Everything', ->
  invoke 'buildwraith'
  invoke 'buildexamples'
  invoke 'buildtests'

task 'watch', 'Watches Everything', ->
  invoke 'watchwraith'
  invoke 'watchexamples'
  invoke 'watchtests'

task 'minify', 'Builds and then minifies Wraith', ->
  uglify = exec 'uglifyjs lib/wraith.js > lib/wraith.min.js'
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
