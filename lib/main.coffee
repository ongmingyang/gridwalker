init = (map) ->
  SCREEN_WIDTH = window.innerWidth
  SCREEN_HEIGHT = window.innerHeight
  
  # Camera
  window.camera = new THREE.PerspectiveCamera(45, SCREEN_WIDTH / SCREEN_HEIGHT, 1, 10000)
  
  # Scene
  window.scene = new THREE.Scene()
  
  # Add terrain and map features
  addTerrain window.scene
  map.displayTiles window.scene
  
  # Renderer
  window.renderer = new THREE.WebGLRenderer
    antialias: true
  window.renderer.setClearColor 0x000000
  window.renderer.setSize SCREEN_WIDTH, SCREEN_HEIGHT
  window.renderer.shadowMapEnabled = true
  window.renderer.shadowMapType = THREE.PCFSoftShadowMap
  document.body.appendChild renderer.domElement
  
  # Browser controls
  window.player = new Player map
  window.animator = new Animator map
  window.controls = new Controls window.camera, window.renderer, window.player
  window.addEventListener 'resize', onWindowResize, false

  # Interact with objects
  window.interactor = new Interactor window.player
  return

onWindowResize = ->
  window.camera.aspect = window.innerWidth / window.innerHeight
  window.camera.updateProjectionMatrix()
  window.renderer.setSize window.innerWidth, window.innerHeight
  return

render = ->
  requestAnimationFrame render
  window.renderer.render window.scene, window.camera
  window.animator.update()
  window.controls.update()
  return
