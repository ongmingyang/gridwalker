###
  This class handles all global animations.
###
class Animator
  constructor: (map) ->
    @animations = map.animations
    @clock = new THREE.Clock(true)

  update: ->
    for animation in @animations
      animation.animate @clock.getElapsedTime()
