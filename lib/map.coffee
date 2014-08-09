class Map
  _opposite =
    north: "south"
    south: "north"
    east: "west"
    west: "east"

  constructor: (vertices, defaultTile) ->
    #  Accepts vertices as an object of THREE.Vector3()'s 
    @tiles = _.mapValues vertices, (vector) ->
      new Tile
        position: vector
        walkable: true
        animating: false
        interactive: false
        object: defaultTile or window.globalMeshes.tile0.init vector
    
    @walls = {} # Will be populated later with @computeBoundary
    @animations = []
    @startTile = @tiles[0]
    
  # Links vertices
  link: (from, to, direction) ->
    @tiles[from].adjacent[direction] = @tiles[to]
    @tiles[to].adjacent[_opposite[direction]] = @tiles[from]
    return

  # Unlinks vertices
  unlink: (from, to) ->
    tiles = @tiles
    _.forOwn tiles[from].adjacent, (tile, key) ->
      tile.adjacent[_opposite[key]] = null if tile is tiles[to]
    _.forOwn tiles[to].adjacent, (tile, key) ->
      tile.adjacent[_opposite[key]] = null if tile is tiles[from]
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

      # Only compute walls for walkable tiles
      return unless tile.walkable

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

        # Add animating or interactive tile as individual geometry for performance
        if tile.animating or tile.interactive
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
    Set animating flag on vertices
  ###
  declareAnimating: (indices) ->
    tiles = @tiles
    _.forEach indices, (index) ->
      tiles[index].animating = true

  ###
    Helper function that passes animations into an instance array
    that will later be iterated through by the animator object
  ###
  makeAnimation: (args) ->
    tiles = @tiles

    # Update the animating flag in tiles object for display
    tiles[args.vertex].animating = true

    if args.animate?
      @animations.push
        description: args.description or null
        type: 'recurring'
        animate: (t) ->
          # Move reference point in @tiles
          args.animate tiles[args.vertex].position, t

          # Move object geometry
          args.animate tiles[args.vertex].object.position, t
          tiles[args.vertex].object.verticesNeedUpdate = true

    if args.trigger?
      @animations.push
        description: args.description or null
        type: 'single'
        animate: (delta, started, done) ->
          hasBegun = started()
          # Move reference point in @tiles
          args.trigger tiles[args.vertex].position, delta, hasBegun, done

          # Move object geometry
          args.trigger tiles[args.vertex].object.position, delta, hasBegun, done
          tiles[args.vertex].object.verticesNeedUpdate = true
      return
    return

  ###
    Helper function for interactives
  ###
  onInteract: (index, fn, walkable) ->
    @tiles[index].interactive = true

    # Execute this function upon interaction
    @tiles[index].object.interaction = fn or null

    # By default, make interactive objects not walkable
    @tiles[index].walkable = true or false
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

