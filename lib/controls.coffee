###
  The goal of the Controls object is to make the
  camera (object) follow the playerState (player)'s position
  in a smooth fashion, and invoke playerState actions upon
  triggering key events
###

Controls = (object, domElement, playerState) ->
  # The camera, the dom element, and the player state
  @object = object
  @domElement = domElement
  @playerState = playerState

  # The tile the user will walk to if moving forward
  @oldTarget = @playerState.facingTarget.clone()
  @oldPosition = @playerState.cameraPosition.clone()

  # Some parameters
  @walkSteps = 20 # Frames taken till move to next tile
  @lookSteps = 15 # Frames taken till facing correct direction
  currentSteps = 0 # Number of steps till completion of move action
  @freeze = false

  @onKeyDown = (event) ->

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
        currentSteps = @walkSteps

      when 37, 65 # left, A
        @playerState.lookLeft()
        currentSteps = @lookSteps

      when 40, 83 # down, S
        @playerState.lookLeft()
        @playerState.lookLeft()
        @playerState.moveForward()
        @playerState.lookRight()
        @playerState.lookRight()
        currentSteps = @walkSteps

      when 39, 68 # right, D
        @playerState.lookRight()
        currentSteps = @lookSteps

      when 81 # Q
        @playerState.lookLeft()
        @playerState.moveForward()
        @playerState.lookRight()
        currentSteps = @walkSteps

      when 69 # E
        @playerState.lookRight()
        @playerState.moveForward()
        @playerState.lookLeft()
        currentSteps = @walkSteps

  @update = ->

    if currentSteps <= 0
      # Reset flags
      @freeze = false
      return
    else
      currentSteps--

    # View rotation
    # This block updates the target
    delta = new THREE.Vector3()
    delta.subVectors @playerState.facingTarget, @oldTarget
    delta.divideScalar currentSteps

    # Forward and backward movement
    # This block updates the camera position
    v = new THREE.Vector3()
    v.subVectors @playerState.cameraPosition, @oldPosition
    v.divideScalar currentSteps

    @oldPosition.add v
    @object.position.copy @oldPosition

    # Capture edge cases based on some tolerance (0.01)
    # Happens when player walks into a wall; need to end freeze loop
    currentSteps = 0  if delta.length() <= 0.01

    @oldTarget.add delta
    @object.lookAt @oldTarget
    return

  # Binds key event listeners to window
  bind = (scope, fn) ->
    return ->
      fn.apply scope, arguments
      return
  $( window ).keydown bind(this, @onKeyDown)

  return

