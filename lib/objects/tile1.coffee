window.globalMeshes.tile1 =
  materials: [
    new THREE.MeshPhongMaterial
      id: 2
      color: 0xffeedd
  ]

  init: (position) ->
    geometry = new THREE.BoxGeometry( 10, 3, 10 )

    _.forEach geometry.vertices, (vertex) ->
      vertex.y -= 1.5
    _.forEach geometry.faces, (face) ->
      face.materialIndex = 2

    cube = new THREE.Mesh( geometry )
    cube.position.copy position
    cube
