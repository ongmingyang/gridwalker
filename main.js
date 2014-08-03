var SCREEN_WIDTH = window.innerWidth,
SCREEN_HEIGHT = window.innerHeight;

var camera, scene, renderer, light, plane;

var controls, gridHelper;

var _playerHeight = 5;

init();
render();

function init() {
  // Camera
  camera = new THREE.PerspectiveCamera( 45, SCREEN_WIDTH / SCREEN_HEIGHT, 1, 1000 );
  camera.position.set( 0, _playerHeight, 0 );
  //camera.lookAt( 0, _playerHeight, 0 );

  // Scene
  scene = new THREE.Scene();

  // Add terrain features
  addTerrain( scene );

  // Renderer
  renderer = new THREE.WebGLRenderer({
      antialias: true
      });
  renderer.setClearColor( 0x000000 );
  renderer.setSize( SCREEN_WIDTH, SCREEN_HEIGHT );
  renderer.shadowMapEnabled = true;
  document.body.appendChild( renderer.domElement );

  // Browser controls
  controls = new THREE.FirstPersonControls( camera, renderer.domElement );
  window.addEventListener( 'resize', onWindowResize, false );

}

function onWindowResize() {
  camera.aspect = window.innerWidth / window.innerHeight;
  camera.updateProjectionMatrix();
  renderer.setSize( window.innerWidth, window.innerHeight );
}

function render() {
  requestAnimationFrame(render);
  renderer.render(scene, camera);
  controls.update( 1 );
}
