###
  Create an example map
###
vertices =
  0: new THREE.Vector3()
  1: new THREE.Vector3(10, 0, 0)
  2: new THREE.Vector3(0, 0, 10)
  3: new THREE.Vector3(-10, 0, 0)
  4: new THREE.Vector3(0, 0, -10)
  5: new THREE.Vector3(20, 1, 0)
  6: new THREE.Vector3(30, 2, 0)
  7: new THREE.Vector3(30, 1, 10)
  8: new THREE.Vector3(0, 1, 20)
  9: new THREE.Vector3(10, 2, 20)
  10: new THREE.Vector3(20, 3, 20)
  11: new THREE.Vector3(30, 2, 20)

map = new Map vertices

map.setTile 6, window.globalMeshes.tile1

map.link 0, 1, "north"
map.link 0, 3, "south"
map.link 0, 2, "east"
map.link 0, 4, "west"
map.link 1, 5, "north"
map.link 5, 6, "north"
map.link 6, 7, "east"
map.link 2, 8, "east"
map.link 8, 9, "north"
map.link 9, 10, "north"
map.link 10, 11, "north"
map.link 11, 7, "west"

map.computeBoundary()

# Bind map to global object
window.globalMaps.example = map

