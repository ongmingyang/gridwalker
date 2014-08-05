SCREEN_WIDTH = window.innerWidth
SCREEN_HEIGHT = window.innerHeight
camera = undefined
scene = undefined
renderer = undefined
player = undefined
controls = undefined

init = (map) ->
  
  # Camera
  camera = new THREE.PerspectiveCamera(45, SCREEN_WIDTH / SCREEN_HEIGHT, 1, 1000)
  
  # Scene
  scene = new THREE.Scene()
  
  # Add terrain features
  addTerrain scene
  
  # Renderer
  renderer = new THREE.WebGLRenderer(antialias: true)
  renderer.setClearColor 0x000000
  renderer.setSize SCREEN_WIDTH, SCREEN_HEIGHT
  renderer.shadowMapEnabled = true
  document.body.appendChild renderer.domElement
  
  # Browser controls
  #controls = new THREE.FirstPersonControls( camera, renderer.domElement );
  player = new playerState(map)
  controls = new playerControls(camera, renderer, player)
  camera.position.copy player.cameraPosition
  window.addEventListener "resize", onWindowResize, false
  return

onWindowResize = ->
  camera.aspect = window.innerWidth / window.innerHeight
  camera.updateProjectionMatrix()
  renderer.setSize window.innerWidth, window.innerHeight
  return

render = ->
  requestAnimationFrame render
  renderer.render scene, camera
  controls.update()
  return
