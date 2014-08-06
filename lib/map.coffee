class Map
  constructor: (vertices) ->
    #  Accepts vertices as an object of THREE.Vector3()'s 
    @tiles = _.mapValues vertices, (vector) ->
      new Tile
        position: vector
        walkable: true
        object: tile1 vector
    
    # The walls object will be populated later with this.computeBoundary
    @walls = {}
    @startTile = @tiles[0]
    
  # Links vertices
  link: (from, to, direction) ->
    opposite =
      north: "south"
      south: "north"
      east: "west"
      west: "east"

    @tiles[from].adjacent[direction] = @tiles[to]
    @tiles[to].adjacent[opposite[direction]] = @tiles[from]
    return

  # Unlinks vertices
  unlink: (from, to) ->
    _.forOwn @tiles[from].adjacent, (tile, key) ->
      @tiles[to] = null if tile is @tiles[to]
    _.forOwn @tiles[to].adjacent, (tile, key) ->
      @tiles[from] = null if tile is @tiles[from]
    return
  
  ###
    Call this function after all vertices have been linked
    Function creates "wall" tiles for each null adjacent reference
    so that the player can compute the camera view
    TODO: it should be possible to custom define wall tiles in the future
    TODO: wall class should extend tile class? discuss
  ###
  computeBoundary: ->
    i = 0 # counter for number of walls
    walls = @walls # reference object for walls
    axes =
      north: new THREE.Vector3(10, 0, 0)
      south: new THREE.Vector3(-10, 0, 0)
      east: new THREE.Vector3(0, 0, 10)
      west: new THREE.Vector3(0, 0, -10)

    _.forOwn @tiles, (tile, key) ->
      _.forOwn tile.adjacent, (obj, direction) ->
        if _.isNull(obj)
          walls[i] = new Tile
            position: tile.position.clone()
            walkable: false

          walls[i].position.add axes[direction]
          tile.adjacent[direction] = walls[i]
          i++
        return
      return

  displayTiles: (scene) ->
    # TODO Make sure to merge geometries first for performance!
    _.forOwn @tiles, (tile, key) ->
      if tile.object
        scene.add tile.object

class Tile
  constructor: (init) ->
    if _.isEmpty(init)
      console.log "WARNING: empty tile initialised!"
      return

    @position = init.position or new THREE.Vector3()
    @walkable = init.walkable or false
    @object = init.object or null
    @adjacent =
      north: init.north or null
      south: init.south or null
      east: init.east or null
      west: init.west or null

