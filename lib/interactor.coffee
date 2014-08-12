###
  The Interactor class takes care of all interactions with
  surrounding objects
###
class Interactor
  constructor: (player) ->
    @player = player
    @projector = new THREE.Projector()
    @raycaster = new THREE.Raycaster window.camera.position, @player.facingTilePosition.clone()
    $( window ).mousedown bind(this, @onMouseDown)

  # Class function binds key event listeners to window
  bind = (scope, fn) ->
    return ->
      fn.apply scope, arguments
      return

  onMouseDown: (event) ->
    event.preventDefault()

    return if window.player.freeze

    vector = new THREE.Vector3 ( event.clientX / window.innerWidth ) * 2 - 1, - ( event.clientY / window.innerHeight ) * 2 + 1, 0.5
    @projector.unprojectVector vector, window.camera
    @objects = _.compact _.pluck _.filter(_.compact(_.values(@player.tile.adjacent)), {interactive: 'click'}), 'object'
    vector.sub( window.camera.position ).normalize()
    @raycaster.set window.camera.position, vector
    intersects = @raycaster.intersectObjects @objects

    unless _.isEmpty intersects
      target = intersects[0].object
      @interact target

    return

  ###
    Called when 1) player walks on tile and 2) when a player clicks on an object
  ###
  interact: (target) ->

    # Disallow interaction if the target is frozen
    return if target.freeze

    target.interactionCounter = 0 if _.isUndefined target.interactionCounter
    target.interaction target.interactionCounter++
    return

