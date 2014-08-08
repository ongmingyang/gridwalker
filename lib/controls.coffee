###
  The goal of the Controls object is to make the
  camera (object) follow the player's position in
  a smooth fashion, and invoke player actions upon
  triggering key events
###

class Controls
  _walkSteps = 20 # Frames taken till move to next tile
  _lookSteps = 15 # Frames taken till facing correct direction

  constructor: (object, domElement, player) ->
    # The camera, the dom element, and the player state
    @object = object
    @domElement = domElement
    @player = player

    # The tile the user will walk to if moving forward
    @oldTarget = @player.facingTarget()
    @oldPosition = @player.cameraPosition()

    # Mouse dragging is set to 0
    @mouseX = @mouseY = 0

    # Initialise camera position and view
    @object.position.copy @oldPosition
    @object.lookAt @oldTarget

    @currentSteps = 0 # Number of steps till completion of move action
    @freeze = false # Can the player activate controls?
    @dragging = false # Is the player in view mode?

    $( window ).keydown bind(this, @onKeyDown)
    $( window ).keyup bind(this, @onKeyUp)
    $( window ).mousemove bind(this, @onMouseMove)

  # Class function binds key event listeners to window
  bind = (scope, fn) ->
    return ->
      fn.apply scope, arguments
      return

  # Capture key down event
  onKeyDown: (event) ->

    event.preventDefault()

    # A player's controls are frozen once he starts moving
    return if @freeze

    # Toggle freeze to lock keypress
    @freeze = true
    @dragging = false

    switch event.keyCode
      when 38, 87 # up, W
        @player.moveForward()
        @currentSteps = _walkSteps

      when 37, 65 # left, A
        @player.lookLeft()
        @currentSteps = _lookSteps

      when 40, 83 # down, S
        @player.lookLeft()
        @player.lookLeft()
        @player.moveForward()
        @player.lookRight()
        @player.lookRight()
        @currentSteps = _walkSteps

      when 39, 68 # right, D
        @player.lookRight()
        @currentSteps = _lookSteps

      when 81 # Q
        @player.lookLeft()
        @player.moveForward()
        @player.lookRight()
        @currentSteps = _walkSteps

      when 69 # E
        @player.lookRight()
        @player.moveForward()
        @player.lookLeft()
        @currentSteps = _walkSteps

      when 16 # SHIFT
        @dragging = true

  # Capture key up event
  onKeyUp: (event) ->
    event.preventDefault()
    switch event.keyCode
      when 16 # SHIFT
        @dragging = false

  # Capture dragging event
  onMouseMove: (event) ->
    return unless @dragging
    event.preventDefault()
    event.stopPropagation()

    @mouseX = (window.innerWidth/2 - event.pageX) / window.innerWidth / 10
    @mouseY = (window.innerHeight/2 - event.pageY) / window.innerHeight / 10

  # Loop called at render time
  update: ->

    # Shift+mouse view rotation
    if @dragging
      u = new THREE.Vector3()
      u.subVectors @oldTarget, @oldPosition
      u.applyAxisAngle @object.up, -Math.PI/2 # Left pointing vector

      # Alta-azimuth rotation
      @oldTarget.applyAxisAngle @object.up, @mouseX
      @oldTarget.applyAxisAngle u.normalize(), @mouseY

    if @currentSteps <= 0
      # For animating tiles TODO: make efficient?
      @oldPosition.copy @player.cameraPosition()
      @object.position.copy @oldPosition

      @freeze = false # Reset flags
    else
      @currentSteps--

      # Look left and right
      # This block updates the target
      delta = new THREE.Vector3()
      delta.subVectors @player.facingTarget(), @oldTarget
      delta.divideScalar @currentSteps

      # Forward and backward movement
      # This block updates the camera position
      v = new THREE.Vector3()
      v.subVectors @player.cameraPosition(), @oldPosition
      v.divideScalar @currentSteps

      @oldPosition.add v
      @object.position.copy @oldPosition

      # Capture edge cases based on some tolerance (0.01)
      # Happens when player walks into a wall; need to end freeze loop
      @currentSteps = 0 if delta.length() <= 0.01
      @oldTarget.add delta

    @object.lookAt @oldTarget
    return

