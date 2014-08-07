###
  The goal of the Controls object is to make the
  camera (object) follow the playerState (player)'s position
  in a smooth fashion, and invoke playerState actions upon
  triggering key events
###

class Controls
  _walkSteps = 20 # Frames taken till move to next tile
  _lookSteps = 15 # Frames taken till facing correct direction

  constructor: (object, domElement, playerState) ->
    # The camera, the dom element, and the player state
    @object = object
    @domElement = domElement
    @playerState = playerState

    # The tile the user will walk to if moving forward
    @oldTarget = @playerState.facingTarget.clone()
    @oldPosition = @playerState.cameraPosition.clone()

    # Initialise camera position and view
    @object.position.copy @oldPosition
    @object.lookAt @oldTarget

    @currentSteps = 0 # Number of steps till completion of move action
    @freeze = false # Can the player activate controls?

    $( window ).keydown bind(this, @onKeyDown)

  # Class function binds key event listeners to window
  bind = (scope, fn) ->
    return ->
      fn.apply scope, arguments
      return

  # Instance function captures key down event
  onKeyDown: (event) ->

    event.preventDefault()

    # A player's controls are frozen once he starts moving
    return if @freeze

    # Toggle freeze to lock keypress
    @freeze = true

    # Recompute target and camera
    @oldTarget = @playerState.facingTarget.clone()
    @oldPosition = @playerState.cameraPosition.clone()

    switch event.keyCode

      when 38, 87 # up, W
        @playerState.moveForward()
        @currentSteps = _walkSteps

      when 37, 65 # left, A
        @playerState.lookLeft()
        @currentSteps = _lookSteps

      when 40, 83 # down, S
        @playerState.lookLeft()
        @playerState.lookLeft()
        @playerState.moveForward()
        @playerState.lookRight()
        @playerState.lookRight()
        @currentSteps = _walkSteps

      when 39, 68 # right, D
        @playerState.lookRight()
        @currentSteps = _lookSteps

      when 81 # Q
        @playerState.lookLeft()
        @playerState.moveForward()
        @playerState.lookRight()
        @currentSteps = _walkSteps

      when 69 # E
        @playerState.lookRight()
        @playerState.moveForward()
        @playerState.lookLeft()
        @currentSteps = _walkSteps

  update: ->

    if @currentSteps <= 0
      # Reset flags
      @freeze = false
      return
    else
      @currentSteps--

    # View rotation
    # This block updates the target
    delta = new THREE.Vector3()
    delta.subVectors @playerState.facingTarget, @oldTarget
    delta.divideScalar @currentSteps

    # Forward and backward movement
    # This block updates the camera position
    v = new THREE.Vector3()
    v.subVectors @playerState.cameraPosition, @oldPosition
    v.divideScalar @currentSteps

    @oldPosition.add v
    @object.position.copy @oldPosition

    # Capture edge cases based on some tolerance (0.01)
    # Happens when player walks into a wall; need to end freeze loop
    @currentSteps = 0 if delta.length() <= 0.01

    @oldTarget.add delta
    @object.lookAt @oldTarget
    return

