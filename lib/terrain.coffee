addTerrain = (scene) ->
  
  # Fog
  scene.fog = new THREE.Fog(0x605570, 10, 200)
  gridHelper = new THREE.GridHelper(100, 10)
  scene.add gridHelper
  
  # Light
  light = new THREE.DirectionalLight(0xffdd66, 1.5)
  light.position.set -150, 150, 0
  light.castShadow = true
  
  #light.shadowCameraVisible = true;
  d = 200
  light.shadowCameraLeft = -d
  light.shadowCameraRight = d
  light.shadowCameraTop = d
  light.shadowCameraBottom = -d
  light.shadowCameraFar = 500
  scene.add light
  scene.add new THREE.AmbientLight(0x404040)
  
  # Ground texture
  plane = new THREE.PlaneGeometry(500, 500)
  groundTexture = THREE.ImageUtils.loadTexture("textures/grass.jpg")
  groundTexture.wrapS = groundTexture.wrapT = THREE.RepeatWrapping
  groundTexture.repeat.set 25, 25
  groundTexture.anisotropy = 16
  groundMaterial = new THREE.MeshPhongMaterial
    color: 0x663399
    specular: 0x111111
    map: groundTexture
  planeMesh = new THREE.Mesh(plane, groundMaterial)
  planeMesh.rotation.x = -Math.PI / 2
  planeMesh.receiveShadow = true
  scene.add planeMesh
  
  # Add skybox
  geometry = new THREE.SphereGeometry(4000, 32, 12)
  vertexShader = document.getElementById("vertexShader").textContent
  fragmentShader = document.getElementById("fragmentShader").textContent
  uniforms =
    topColor:
      type: "c"
      value: new THREE.Color(0x0077ff)

    bottomColor:
      type: "c"
      value: scene.fog.color

    offset:
      type: "f"
      value: 0

    exponent:
      type: "f"
      value: 0.4

  uniforms.topColor.value = new THREE.Color(0x000000)
  material = new THREE.ShaderMaterial
    vertexShader: vertexShader
    fragmentShader: fragmentShader
    uniforms: uniforms
    side: THREE.BackSide
    depthWrite: false
  skyBox = new THREE.Mesh(geometry, material)
  scene.add skyBox
