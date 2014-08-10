###
  This class handles all global animations.
###
class Animator
  constructor: (map) ->
    @animations = map.animations
    @globalClock = new THREE.Clock(true)

  ###
    Returns the triggered state of the animation:
      @return true
        The animation was just triggered (happens only once)
      @return false
        The animation was triggered some time ago (happens the rest of the time)
  ###
  triggered: (animation) ->
    ->
      if _.isUndefined animation.triggered
        animation.triggered = true
      else
        animation.triggered = false
      animation.triggered

  pause: (animation) ->
    ->
      animation.pause = true

  unpause: (animation) ->
    ->
      animation.pause = false

  togglePause: (animation) ->
    ->
      animation.pause = not animation.pause

  done: (animation) ->
    ->
      window.player.updateFacing()
      animation.type = 'completed'

  update: ->
    prune = false

    for a in @animations
      # Prune all completed animations
      prune = true if _.isNull a

      # Skip paused animations
      continue if a.paused?

      switch a.type
        when 'recurring'
          a.animate @globalClock.getElapsedTime()
        when 'single'
          a.localClock = new THREE.Clock(true)
          a.type = 'single-triggered'
        when 'single-triggered'
          a.animate a.localClock.getElapsedTime(),
            triggered: @triggered a
            pause: @pause a
            unpause: @unpause a
            done: @done a
        when 'completed'
          a = null

    @animations = _.compact @animations if prune
    return

