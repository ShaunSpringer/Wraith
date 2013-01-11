{spawn, exec} = require 'child_process'

option '-p', '--prefix [DIR]', 'set the installation prefix for `cake install`'

task 'build', 'continually build with --watch', ->
    coffee = spawn 'coffee', ['-cw', '-o', 'lib', 'src']
    coffee.stdout.on 'data', (data) -> console.log data.toString().trim()
