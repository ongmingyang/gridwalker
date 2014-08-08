class Map
  constructor: (vertices, defaultTile) ->
    #  Accepts vertices as an object of THREE.Vector3()'s 
    @tiles = _.mapValues vertices, (vector) ->
      new Tile
        position: vector
        walkable: true
        animating: false
        object: defaultTile or window.globalMeshes.tile0.init vector
    
    @walls = {} # Will be populated later with @computeBoundary
    @animations = []
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

  # Changes the tile mesh for a single tile
  setTile: (id, tile) ->
    @tiles[id].object = tile.init @tiles[id].object.position
  
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

  ###
    Merges all non-animating tile geometries and places them onto the scene
    ONLY MERGE NON-ANIMATING TILE GEOMETRIES KK THX
    Geometries are merged for performance purposes!
  ###
  displayTiles: (scene) ->
    tileMap = null
    material = new THREE.MeshFaceMaterial _.flatten _.pluck window.globalMeshes, "materials"

    _.forOwn @tiles, (tile, key) ->
      if tile.object

        # Add animating tile as individual geometry for performance
        if tile.animating
          scene.add tile.object

        else
          # Assign correct material index based on collapsed array and material id
          _.forEach tile.object.geometry.faces, (face) ->
            face.materialIndex = _.findIndex material.materials,
              id: face.materialIndex

          # Create tileMap merged geometry object
          unless tileMap?
            # note first geometry must be centered at origin!
            tileMap = tile.object.geometry
          else
            tile.object.updateMatrix()
            tileMap.merge tile.object.geometry, tile.object.matrix

    tileMapMesh = new THREE.Mesh tileMap, material
    tileMapMesh.receiveShadow = tileMapMesh.castShadow = true
    scene.add tileMapMesh

  ###
    Helper function that passes animations into an instance array
    that will later be iterated through by the animator object
  ###
  makeAnimation: (args) ->
    tiles = @tiles
    hooks = args.hooks or null # link and unlink hooks

    # Update the animating flag in tiles object for display
    tiles[args.vertex].animating = true

    @animations.push
      description: args.description or null
      animate: (t) ->
        # Move reference point in @tiles
        args.animate tiles[args.vertex].position, t

        # Move object geometry
        args.animate tiles[args.vertex].object.position, t
        tiles[args.vertex].object.verticesNeedUpdate = true

    return

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

