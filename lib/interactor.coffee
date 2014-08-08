###
  The Interactor class takes care of all interactions with
  surrounding objects
###
class Interactor
  constructor: (player) ->
    @player = player
    @projector = new THREE.Projector()
    @raycaster = new THREE.Raycaster window.camera.position, @player.facingTile.position.clone()
    @vector = new THREE.Vector3()
    $( window ).mousedown bind(this, @onMouseDown)

  # Class function binds key event listeners to window
  bind = (scope, fn) ->
    return ->
      fn.apply scope, arguments
      return

  onMouseDown: (event) ->
    event.preventDefault()

    @vector = @vector.set ( event.clientX / window.innerWidth ) * 2 - 1, - ( event.clientY / window.innerHeight ) * 2 + 1, 0.5
    @projector.unprojectVector @vector, window.camera
    @objects = _.compact _.pluck _.filter(_.values(@player.tile.adjacent), 'interactive'), 'object'
    console.log @objects
    @vector.sub( window.camera.position ).normalize()
    @raycaster.set window.camera.position, @vector
    intersects = @raycaster.intersectObjects @objects

    console.log intersects
