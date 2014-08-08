###
  The Player class is a representation of the player on
  the map. The player faces a direction, and has a set of adjacent
  tiles. The player's camera is defined and updated in this.computeCamera
###

class Player
  _playerHeight = 3

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

  constructor: (map) ->
    @map = map
    @tile = map.startTile
    @position = @tile.position
    @facing = "north" # begin facing north
    @facingTile = @tile.adjacent[@facing]
  
  # Function computes facing target of camera
  facingTarget: ->
    v = @facingTile.position.clone()
    v.y += _playerHeight
    v

  # Function computes camera position
  cameraPosition: ->
    v = @position.clone()
    v.y += _playerHeight
    v

  lookRight: ->
    @facing = turn[@facing]["right"]
    @facingTile = @tile.adjacent[@facing]
    return

  lookLeft: ->
    @facing = turn[@facing]["left"]
    @facingTile = @tile.adjacent[@facing]
    return

  moveForward: ->
    if @facingTile.walkable
      @tile = @facingTile
      @position = @tile.position
      @facingTile = @tile.adjacent[@facing]
    return

  teleport: (index) ->
    if map.tiles[index].walkable
      @tile = map.tiles[index]
      @position = @tile.position
      @facingTile = @tile.adjacent[@facing]
    return

