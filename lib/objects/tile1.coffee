tile1 = (position) ->
  geometry = new THREE.BoxGeometry( 10, 3, 10 )
  material = new THREE.MeshBasicMaterial
      color: 0x00ff00
      wireframe: true
  cube = new THREE.Mesh( geometry, material )
  cube.position.copy position
  cube.position.y -= 1.5
  cube
