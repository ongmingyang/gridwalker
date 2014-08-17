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
  12: new THREE.Vector3(20, 2, 30)
  13: new THREE.Vector3(0, 0, -20)
  14: new THREE.Vector3(10, 0, -20)
  15: new THREE.Vector3(20, 0, -20)
  16: new THREE.Vector3(30, 1, -20)
  17: new THREE.Vector3(40, 2, -10)
  18: new THREE.Vector3(50, 3, -10)
  19: new THREE.Vector3(50, 4, 0)
  20: new THREE.Vector3(60, 4, 0)

map = new Map vertices

map.setTile 6, window.globalMeshes.tile1
map.setTile 12, window.globalMeshes.cube0
map.setTile 19, window.globalMeshes.tile1
map.setTile 20, window.globalMeshes.cube0

# Need to declare animating tiles first
map.declareAnimating [6, 14, 19]

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
map.link 10, 12, "east"
map.link 4, 13, "west"
map.link 13, 14, "north"
map.link 14, 15, "north"
map.link 15, 16, "north"
map.link 17, 18, "north"
map.link 18, 19, "east"
map.link 19, 20, "north"

map.onInteract 20,
  type: 'click'
  callback: (n) ->
    window.narrator.narrate "win!!!!"

map.onInteract 3,
  type: 'trigger'
  callback: (n) ->
    window.narrator.narrate "There's nothing back this way"

map.onInteract 12,
  type: 'click'
  callback: (n) ->
    if n is 0
      window.narrator.narrate "I wonder what this does!"

    # Prevents player from clicking target again until
    # animation is done
    map.freezeInteraction 12

    map.makeAnimation 6,
      description: "This slides the orange block to the left so that the player can
                    step across to the next platform from the west path"
      trigger: (vertex, t, controls) ->
        if controls.triggered
          map.unlink 6, 7
          map.unlink 6, 5
          map.unlink 6, 16
          map.unlink 6, 17
        if n % 2 is 0
          vertex.z = -2 * t
        if n % 2 is 1
          vertex.z = -10 + 2 * t
        if vertex.z < -10
          vertex.z = -10
          map.link 6, 16, "west"
          map.link 6, 17, "north"
          map.unfreezeInteraction 12
          controls.done()
        if vertex.z > 0
          vertex.z = 0
          map.link 6, 7, "east"
          map.link 6, 5, "south"
          map.unfreezeInteraction 12
          controls.done()

    map.makeAnimation 19,
      description: "This slides the northmost orange block to the right so that the player is prevented
                    from stepping across to the next platform from the west path"
      trigger: (vertex, t, controls) ->
        if controls.triggered
          map.unlink 19, 18
          map.unlink 19, 20
        if n % 3 is 0
          vertex.z = 2 * t
          vertex.y = 4 + t
          if vertex.z > 10
            vertex.z = 10
            controls.done()
        if n % 3 is 1
          vertex.z = 10
          vertex.y = 9 - 2 * t
          if vertex.y < -1
            controls.done()
        if n % 3 is 2
          vertex.y = -1 + t
          vertex.z = 10 - 2 * t
          if vertex.z < 0
            vertex.z = 0
            vertex.y = 4
            map.link 18, 19, "east"
            map.link 19, 20, "north"
            controls.done()

map.makeAnimation 14,
  description: "Tile moves up and down and disconnects player at some points"
  animate: (vertex, t) ->
    vertex.y = 4 + 5 * Math.sin(t % 62.83)
    if vertex.y <= 0
      map.link 13, 14, 'north'
      map.link 14, 15, 'north'
    else
      map.unlink 13, 14, 'north'
      map.unlink 14, 15, 'north'

map.setClones
  0:
    name: "Fooman"
    description: "Has no distinguishing properties"
    facing: "north"
    vertex: 0
  1:
    name: "Barman"
    description: "Works at a tavern"
    facing: "north"
    vertex: 8

# Bind map and players to global object
window.globalMaps.example = map
