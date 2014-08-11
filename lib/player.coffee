###
  The Player class is a representation of the player on
  the map. The player faces a direction, and has a set of adjacent
  tiles. The player's camera is defined and updated in this.computeCamera

  Player
    @param position: The position of the tile the player is standing on

    @param facing: The direction (NSEW) the player is facing

    @param tile: The tile object the player is standing on

    @param facingTile: The tile object the player is facing
        null if player is not facing any tile

    @param facingTilePosition: The position of the tile object that
        the player is facing. If the facingTile is null, gives the
        vector that the player ought to be facing
###

class Player
  _beginFacing = 'north'
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
    @tile = @map.startTile
    @position = @tile.position
    @facing = _beginFacing
    @freeze = false
    @updateFacing()
    $( window ).keydown bind(this, @onKeyDown)

  # Class function binds key event listeners to window
  bind = (scope, fn) ->
    return ->
      fn.apply scope, arguments
      return
  
  onKeyDown: (event) ->
    switch event.keyCode
      when 9, 70 # TAB, F (for friend)
        @toggleClone()

  # Function computes facing target of camera
  facingTarget: ->
    v = @facingTilePosition.clone()
    v.y += _playerHeight
    v

  # Function computes camera position
  cameraPosition: ->
    v = @position.clone()
    v.y += _playerHeight
    v

  lookRight: ->
    @facing = turn[@facing]["right"]
    @updateFacing()
    return

  lookLeft: ->
    @facing = turn[@facing]["left"]
    @updateFacing()
    return

  moveForward: ->
    return if _.isNull @facingTile
    if @facingTile.walkable
      @tile = @facingTile
      @position = @tile.position
      @updateFacing()
    return

  # Accepts either a tile object or a tile id
  teleport: (tile) ->
    unless tile instanceof Tile
      tile = @map.tiles[tile]
    if tile.walkable
      @tile = tile
      @position = @tile.position
      @updateFacing()
    return

  ###
    Used to update the player object upon completion
    of an event, usually terrain changing
  ###
  updateFacing: ->
    @facingTile = @tile.adjacent[@facing]
    @facingTilePosition = if _.isNull @facingTile then @tile.default @facing else @facingTile.position
    
  ###
    Function swaps player's view with next clone
    specified by the cloneHandler in the map object
  ###
  toggleClone: ->
    id = @map.cloneHandler.current

    # Save the state of current clone
    clone = @map.cloneHandler.clones[id]
    clone.tile = @tile
    clone.facing = @facing

    # Swap to next clone
    id = (id+1) % @map.cloneHandler.total
    clone = @map.cloneHandler.clones[id]
    @facing = clone.facing
    @teleport clone.tile

    # Update current clone id and inform player
    @map.cloneHandler.current = id
    window.globalUI.update id
    window.narrator.narrate "You've switched to clone #{clone.name}."

