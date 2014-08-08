window.globalMeshes.tile0 =
  materials: [
    new THREE.MeshBasicMaterial
      id: 1
      color: 0x00ff00
      wireframe: true
  ]

  init: (position) ->
    geometry = new THREE.BoxGeometry( 10, 3, 10 )

    _.forEach geometry.vertices, (vertex) ->
      vertex.y -= 1.5
    _.forEach geometry.faces, (face) ->
      face.materialIndex = 1

    cube = new THREE.Mesh( geometry, @materials[0] )
    cube.position.copy position
    cube
