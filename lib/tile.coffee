###
  Tile class that is initialised for every tile in the map
  @param position: The location of the tile on the map
  @param walkable: Can the player walk on tile?
  @param object: The mesh associated with the tile
  @param adjacent: Adjacent tile objects
  @param attachments: Objects that are attached to the tile
          e.g. clones and pickable objects
          Each clone and/or pickable object has a unique id
###
class Tile
  constructor: (init) ->
    if _.isEmpty(init)
      console.log "WARNING: empty tile initialised!"
      return

    @position = init.position or new THREE.Vector3()
    @walkable = init.walkable or false
    @object = init.object or null
    @attachments = {}
    @adjacent =
      north: init.north or null
      south: init.south or null
      east: init.east or null
      west: init.west or null


  ###
    Function gives default direction player
    faces when standing on tile
    TODO: compute default direction given different bearing
  ###
  default: (direction, bearing) ->
    bearing = bearing or 'default'
    position = @position.clone()

    if bearing is 'default'

      switch direction
        when 'north' then position.x += 10
        when 'south' then position.x -= 10
        when 'west' then position.z -= 10
        when 'east' then position.z += 10

      return position

  attach: (mesh, id) ->
    @attachments[id] = mesh.init @position
    window.scene.add @attachments[id]

  detach: (mesh, id) ->
    window.scene.remove @attachments[id]
    delete @attachments[id]

