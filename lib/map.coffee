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
        object: defaultTile or window.globalMeshes.tile0.init vector
    
    @animations = []
    @startTile = @tiles[0] # May be overwritten by first clone location
    
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
        if tile.animating or tile.interactive?
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
    PLAYER STUFF:
  ###
  setClones: (clones) ->
    tiles = @tiles
    @cloneHandler =
      current: 0
    @cloneHandler.clones = _.mapValues clones, (clone) ->
      name: clone.name
      description: clone.description
      facing: clone.facing
      tile: tiles[clone.vertex]
      alive: true
    @startTile = @cloneHandler.clones[@cloneHandler.current].tile
    return

  ###
    ANIMATION STUFF: Set animating flag on vertices
  ###
  declareAnimating: (indices) ->
    tiles = @tiles
    _.forEach indices, (index) ->
      tiles[index].animating = true

  ###
    Helper function that passes animations into an instance array
    that will later be iterated through by the animator object
    @param index: The vertex that the animation is applied to
    @params args
      @param description: A short description of the animation
      @param animate: The recurring animation that is invoked
      @param trigger: The transient animation that is invoked
  ###
  makeAnimation: (index, args) ->
    tiles = @tiles
    tile = tiles[index]

    # Update the animating flag in tiles object for display
    tile.animating = true

    # Invoked as a recurring animation
    if args.animate?
      @animations.push
        description: args.description or null
        type: 'recurring'
        animate: (t) ->
          # Move reference point in @tiles
          args.animate tile.position, t

          # Move object geometry
          tile.object.position.copy tile.position

          # Move all objects attached to tile
          _.forOwn tile.attachments, (attachment, key) ->
            attachment.position.copy tile.position

    # Invoked as a transient animation
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

          # Move object geometry
          tile.object.position.copy tile.position

          # Move all objects attached to tile
          _.forOwn tile.attachments, (attachment, key) ->
            attachment.position.copy tile.position

    return

  ###
    INTERACTION STUFF: Helper function for interactives
    @param index: the index of the tile that the user
                  interacts with
    @params args
      @param fn: the callback function that is called 
                 upon the interaction
      @param type:
          'click': triggers callback on click
          'trigger': triggers callback on stepping on tile
  ###
  onInteract: (index, args) ->

    # Set default arguments
    fn = args.callback or null
    @tiles[index].interactive = type = args.type or 'click'

    # Execute this function upon interaction
    @tiles[index].object.interaction = fn or null

    if type is 'click'
      # By default, make clickable types not walkable
      @tiles[index].walkable = false

    return

  freezeInteraction: (index) ->
    @tiles[index].object.freeze = true

  unfreezeInteraction: (index) ->
    @tiles[index].object.freeze = false
