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

  ###
    Function gives default direction player
    faces when standing on tile
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

