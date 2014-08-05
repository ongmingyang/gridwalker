"use strict"

module.exports = (grunt) ->

  # Project configuration.
  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')

    copy:
      lodash:
        src: 'node_modules/lodash/lodash.js'
        dest: 'build/lodash.js'

    coffee:
      compile:
        options:
          bare: true
        files:
          'build/local.js': [
            'maps/*.coffee'
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
            'build/lodash.js'
            'build/local.js'
            'index.js'
          ]

  # Load npm tasks.
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-injector'

  # Default task(s).
  grunt.registerTask 'default', ['copy', 'coffee', 'injector']

