window.globalMeshes.cube1 =
  materials: [
    new THREE.MeshPhongMaterial
      id: 4
      color: 0xff0000
  ]

  init: (position) ->
    geometry = new THREE.BoxGeometry( 2, 2, 2 )

    _.forEach geometry.vertices, (vertex) ->
      vertex.y += 3
    _.forEach geometry.faces, (face) ->
      face.materialIndex = 3

    cube = new THREE.Mesh( geometry, @materials[0] )
    cube.position.copy position
    cube
