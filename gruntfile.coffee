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
          'build/index.js': [
            'maps/*.coffee'
            'lib/*.coffee'
            'lib/**/*.coffee'
          ]

    injector:
        local_dependencies:
          files:
            'index.html': [
              'build/lodash.js'
              'build/index.js'
            ]

  # Load npm tasks.
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-injector'

  # Default task(s).
  grunt.registerTask 'default', ['copy', 'coffee', 'injector']

