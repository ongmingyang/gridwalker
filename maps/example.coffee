###
  Create an example map
###
example = ->
  vertices =
    0: new THREE.Vector3()
    1: new THREE.Vector3(10, 0, 0)
    2: new THREE.Vector3(0, 0, 10)
    3: new THREE.Vector3(-10, 0, 0)
    4: new THREE.Vector3(0, 0, -10)
    5: new THREE.Vector3(20, 0, 0)

  map = new Map vertices

  map.link 0, 1, "north"
  map.link 0, 3, "south"
  map.link 0, 2, "east"
  map.link 0, 4, "west"
  map.link 1, 5, "north"

  map.computeBoundary()

  map

