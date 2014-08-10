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
      tiles[from].adjacent[key] = null if tile is tiles[to]
    _.forOwn tiles[to].adjacent, (tile, key) ->
      tiles[to].adjacent[key] = null if tile is tiles[from]
    return

  # Changes the tile mesh for a single tile
  setTile: (id, tile) ->
    @tiles[id].object = tile.init @tiles[id].object.position
  
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
    tile = tiles[args.vertex]

    # Update the animating flag in tiles object for display
    tile.animating = true

    if args.animate?
      @animations.push
        description: args.description or null
        type: 'recurring'
        animate: (t) ->
          # Move reference point in @tiles
          args.animate tile.position, t

          # Move object geometry
          args.animate tile.object.position, t
          tile.object.verticesNeedUpdate = true

    if args.trigger?
      @animations.push
        description: args.description or null
        type: 'single'
        animate: (delta, controls) ->

          # Move reference point in @tiles
          # All control actions are performed in this loop
          args.trigger tile.position, delta,
            triggered: controls.triggered()
            done: controls.done

          tile.object.position.copy tile.position

          tile.object.verticesNeedUpdate = true
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

  freezeInteraction: (index) ->
    @tiles[index].object.freeze = true

  unfreezeInteraction: (index) ->
    @tiles[index].object.freeze = false

