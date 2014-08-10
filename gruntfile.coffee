"use strict"

module.exports = (grunt) ->

  # Project configuration.
  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')

    copy:
      three:
        src: 'node_modules/three/three.min.js'
        dest: 'build/three.js'

    coffee:
      user:
        files:
          'build/user.js': [
             'maps/*.coffee'
             'terrains/*.coffee'
          ]
      lib:
        options:
          bare: true
        files:
          'build/lib.js': [
            'config/*.coffee'
            'lib/*.coffee'
            'lib/**/*.coffee'
          ]

    injector:
      index:
        options:
          addRootSlash: false
          template: 'index.html'
        files:
          'index.html': [
            'build/three.js'
            'build/lib.js'
            'build/user.js'
            'index.js'
          ]

  # Load npm tasks.
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-injector'

  # Default task(s).
  grunt.registerTask 'default', ['copy', 'coffee', 'injector']

