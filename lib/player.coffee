###
  The playerState class is a representation of the player on
  the map. The player faces a direction, and has a set of adjacent
  tiles. The player's camera is defined and updated in this.computeCamera
###

playerState = (map) ->

  _playerHeight = 3

  @map = map
  @tile = map.startTile
  @position = @tile.position
  @facing = "north" # begin facing north
  @facingTile = @tile.adjacent[@facing]
  
  # Define facing target and eyelevel for camera position
  @computeCamera = ->
    @facingTarget = @facingTile.position.clone()
    @facingTarget.y += _playerHeight
    @cameraPosition = @position.clone()
    @cameraPosition.y += _playerHeight
    return

  @computeCamera()
  
  # Turn object for easy reference
  turn =
    north:
      left: "west"
      right: "east"
      back: "south"

    south:
      left: "east"
      right: "west"
      back: "north"

    east:
      left: "north"
      right: "south"
      back: "west"

    west:
      left: "south"
      right: "north"
      back: "east"

  @lookRight = ->
    @facing = turn[@facing]["right"]
    @facingTile = @tile.adjacent[@facing]
    @computeCamera()
    return

  @lookLeft = ->
    @facing = turn[@facing]["left"]
    @facingTile = @tile.adjacent[@facing]
    @computeCamera()
    return

  @moveForward = ->
    if @facingTile.walkable
      @tile = @facingTile
      @position = @tile.position
      @facingTile = @facingTile.adjacent[@facing]
      @computeCamera()
    return

