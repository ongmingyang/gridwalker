camera = undefined
scene = undefined
renderer = undefined
player = undefined
controls = undefined

init = (map) ->
  SCREEN_WIDTH = window.innerWidth
  SCREEN_HEIGHT = window.innerHeight
  
  # Camera
  camera = new THREE.PerspectiveCamera(45, SCREEN_WIDTH / SCREEN_HEIGHT, 1, 10000)
  
  # Scene
  scene = new THREE.Scene()
  
  # Add terrain and map features
  addTerrain scene
  map.displayTiles scene
  
  # Renderer
  renderer = new THREE.WebGLRenderer
    antialias: true
  renderer.setClearColor 0x000000
  renderer.setSize SCREEN_WIDTH, SCREEN_HEIGHT
  renderer.shadowMapEnabled = true
  document.body.appendChild renderer.domElement
  
  # Browser controls
  player = new Player map
  controls = new Controls camera, renderer, player
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
