###
  This class handles all global animations.
###
class Animator
  constructor: (map) ->
    @animations = map.animations
    @globalClock = new THREE.Clock(true)

  started: (animation) ->
    ->
      started = animation.started
      animation.started = true
      return started

  done: (animation) ->
    ->
      animation.type = 'completed'

  update: ->

    prune = false

    for a in @animations
      # Prune all completed animations
      prune = true if _.isNull a

      switch a.type
        when 'recurring'
          a.animate @globalClock.getElapsedTime()
        when 'single'
          a.localClock = new THREE.Clock(true)
          a.type = 'single-triggered'
        when 'single-triggered'
          a.animate a.localClock.getElapsedTime(), @started(a), @done(a)
        when 'completed'
          a = null

    @animations = _.compact @animations if prune
    return

