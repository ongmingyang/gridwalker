
/*
  Create an example map
 */
var example;

example = function() {
  var map, vertices;
  vertices = {
    0: new THREE.Vector3(),
    1: new THREE.Vector3(10, 0, 0),
    2: new THREE.Vector3(0, 0, 10),
    3: new THREE.Vector3(-10, 0, 0),
    4: new THREE.Vector3(0, 0, -10),
    5: new THREE.Vector3(20, 0, 0)
  };
  map = new mapClass(vertices);
  map.link(0, 1, "north");
  map.link(0, 3, "south");
  map.link(0, 2, "east");
  map.link(0, 4, "west");
  map.link(1, 5, "north");
  map.computeBoundary();
  return map;
};


/*
  The goal of the Controls object is to make the
  camera (object) follow the playerState (player)'s position
  in a smooth fashion, and invoke playerState actions upon
  triggering key events
 */
var Controls;

Controls = function(object, domElement, playerState) {
  var bind, currentSteps;
  this.object = object;
  this.domElement = domElement;
  this.playerState = playerState;
  this.oldTarget = this.playerState.facingTarget.clone();
  this.oldPosition = this.playerState.cameraPosition.clone();
  this.walkSteps = 20;
  this.lookSteps = 15;
  currentSteps = 0;
  this.freeze = false;
  this.onKeyDown = function(event) {
    event.preventDefault();
    if (this.freeze) {
      return;
    }
    this.freeze = true;
    this.oldTarget = this.playerState.facingTarget.clone();
    this.oldPosition = this.playerState.cameraPosition.clone();
    switch (event.keyCode) {
      case 38:
      case 87:
        this.playerState.moveForward();
        return currentSteps = this.walkSteps;
      case 37:
      case 65:
        this.playerState.lookLeft();
        return currentSteps = this.lookSteps;
      case 40:
      case 83:
        this.playerState.lookLeft();
        this.playerState.lookLeft();
        this.playerState.moveForward();
        this.playerState.lookRight();
        this.playerState.lookRight();
        return currentSteps = this.walkSteps;
      case 39:
      case 68:
        this.playerState.lookRight();
        return currentSteps = this.lookSteps;
      case 81:
        this.playerState.lookLeft();
        this.playerState.moveForward();
        this.playerState.lookRight();
        return currentSteps = this.walkSteps;
      case 69:
        this.playerState.lookRight();
        this.playerState.moveForward();
        this.playerState.lookLeft();
        return currentSteps = this.walkSteps;
    }
  };
  this.update = function() {
    var delta, v;
    if (currentSteps <= 0) {
      this.freeze = false;
      return;
    } else {
      currentSteps--;
    }
    delta = new THREE.Vector3();
    delta.subVectors(this.playerState.facingTarget, this.oldTarget);
    delta.divideScalar(currentSteps);
    v = new THREE.Vector3();
    v.subVectors(this.playerState.cameraPosition, this.oldPosition);
    v.divideScalar(currentSteps);
    this.oldPosition.add(v);
    this.object.position.copy(this.oldPosition);
    if (delta.length() <= 0.01) {
      currentSteps = 0;
    }
    this.oldTarget.add(delta);
    this.object.lookAt(this.oldTarget);
  };
  bind = function(scope, fn) {
    return function() {
      fn.apply(scope, arguments);
    };
  };
  window.addEventListener("keydown", bind(this, this.onKeyDown), false);
};

var SCREEN_HEIGHT, SCREEN_WIDTH, camera, controls, init, onWindowResize, player, render, renderer, scene;

SCREEN_WIDTH = window.innerWidth;

SCREEN_HEIGHT = window.innerHeight;

camera = void 0;

scene = void 0;

renderer = void 0;

player = void 0;

controls = void 0;

init = function(map) {
  camera = new THREE.PerspectiveCamera(45, SCREEN_WIDTH / SCREEN_HEIGHT, 1, 1000);
  scene = new THREE.Scene();
  addTerrain(scene);
  renderer = new THREE.WebGLRenderer({
    antialias: true
  });
  renderer.setClearColor(0x000000);
  renderer.setSize(SCREEN_WIDTH, SCREEN_HEIGHT);
  renderer.shadowMapEnabled = true;
  document.body.appendChild(renderer.domElement);
  player = new Player(map);
  controls = new Controls(camera, renderer, player);
  camera.position.copy(player.cameraPosition);
  window.addEventListener("resize", onWindowResize, false);
};

onWindowResize = function() {
  camera.aspect = window.innerWidth / window.innerHeight;
  camera.updateProjectionMatrix();
  renderer.setSize(window.innerWidth, window.innerHeight);
};

render = function() {
  requestAnimationFrame(render);
  renderer.render(scene, camera);
  controls.update();
};

var mapClass, tileClass;

mapClass = (function() {
  function mapClass(vertices) {
    this.tiles = _.mapValues(vertices, function(vector) {
      return new tileClass({
        position: vector,
        walkable: true
      });
    });
    this.walls = {};
    this.startTile = this.tiles[0];
  }

  mapClass.prototype.link = function(from, to, direction) {
    var opposite;
    opposite = {
      north: "south",
      south: "north",
      east: "west",
      west: "east"
    };
    this.tiles[from].adjacent[direction] = this.tiles[to];
    this.tiles[to].adjacent[opposite[direction]] = this.tiles[from];
  };


  /*
    Call this function after all vertices have been linked
    Function creates "wall" tiles for each null adjacent reference
    so that the player can compute the camera view
    TODO: it should be possible to custom define wall tiles in the future
    TODO: wall class should extend tile class
   */

  mapClass.prototype.computeBoundary = function() {
    var axes, i, walls;
    i = 0;
    walls = this.walls;
    axes = {
      north: new THREE.Vector3(10, 0, 0),
      south: new THREE.Vector3(-10, 0, 0),
      east: new THREE.Vector3(0, 0, 10),
      west: new THREE.Vector3(0, 0, -10)
    };
    return _.forOwn(this.tiles, function(tile, key) {
      _.forOwn(tile.adjacent, function(obj, direction) {
        if (_.isNull(obj)) {
          walls[i] = new tileClass({
            position: tile.position.clone(),
            walkable: false
          });
          walls[i].position.add(axes[direction]);
          tile.adjacent[direction] = walls[i];
          i++;
        }
      });
    });
  };

  return mapClass;

})();

tileClass = (function() {
  function tileClass(init) {
    if (_.isEmpty(init)) {
      console.log("WARNING: empty tile initialised!");
      return;
    }
    this.position = init.position || new THREE.Vector3();
    this.walkable = init.walkable || false;
    this.adjacent = {
      north: init.north || null,
      south: init.south || null,
      east: init.east || null,
      west: init.west || null
    };
  }

  return tileClass;

})();


/*
  The Player class is a representation of the player on
  the map. The player faces a direction, and has a set of adjacent
  tiles. The player's camera is defined and updated in this.computeCamera
 */
var Player;

Player = (function() {
  Player.prototype._playerHeight = 3;

  Player.prototype.turn = {
    north: {
      left: "west",
      right: "east",
      back: "south"
    },
    south: {
      left: "east",
      right: "west",
      back: "north"
    },
    east: {
      left: "north",
      right: "south",
      back: "west"
    },
    west: {
      left: "south",
      right: "north",
      back: "east"
    }
  };

  function Player(map) {
    this.map = map;
    this.tile = map.startTile;
    this.position = this.tile.position;
    this.facing = "north";
    this.facingTile = this.tile.adjacent[this.facing];
    this.computeCamera();
  }

  Player.prototype.computeCamera = function() {
    this.facingTarget = this.facingTile.position.clone();
    this.facingTarget.y += this._playerHeight;
    this.cameraPosition = this.position.clone();
    this.cameraPosition.y += this._playerHeight;
  };

  Player.prototype.lookRight = function() {
    this.facing = this.turn[this.facing]["right"];
    this.facingTile = this.tile.adjacent[this.facing];
    this.computeCamera();
  };

  Player.prototype.lookLeft = function() {
    this.facing = this.turn[this.facing]["left"];
    this.facingTile = this.tile.adjacent[this.facing];
    this.computeCamera();
  };

  Player.prototype.moveForward = function() {
    if (this.facingTile.walkable) {
      this.tile = this.facingTile;
      this.position = this.tile.position;
      this.facingTile = this.facingTile.adjacent[this.facing];
      this.computeCamera();
    }
  };

  return Player;

})();

var addTerrain;

addTerrain = function(scene) {
  var d, fragmentShader, geometry, gridHelper, groundMaterial, groundTexture, light, material, plane, planeMesh, skyBox, uniforms, vertexShader;
  scene.fog = new THREE.Fog(0x605570, 10, 200);
  gridHelper = new THREE.GridHelper(100, 10);
  scene.add(gridHelper);
  light = new THREE.DirectionalLight(0xffdd66, 1.5);
  light.position.set(-150, 150, 0);
  light.castShadow = true;
  d = 200;
  light.shadowCameraLeft = -d;
  light.shadowCameraRight = d;
  light.shadowCameraTop = d;
  light.shadowCameraBottom = -d;
  light.shadowCameraFar = 500;
  scene.add(light);
  scene.add(new THREE.AmbientLight(0x404040));
  plane = new THREE.PlaneGeometry(500, 500);
  groundTexture = THREE.ImageUtils.loadTexture("textures/grass.jpg");
  groundTexture.wrapS = groundTexture.wrapT = THREE.RepeatWrapping;
  groundTexture.repeat.set(25, 25);
  groundTexture.anisotropy = 16;
  groundMaterial = new THREE.MeshPhongMaterial({
    color: 0x663399,
    specular: 0x111111,
    map: groundTexture
  });
  planeMesh = new THREE.Mesh(plane, groundMaterial);
  planeMesh.rotation.x = -Math.PI / 2;
  planeMesh.receiveShadow = true;
  scene.add(planeMesh);
  geometry = new THREE.SphereGeometry(500, 32, 12);
  vertexShader = document.getElementById("vertexShader").textContent;
  fragmentShader = document.getElementById("fragmentShader").textContent;
  uniforms = {
    topColor: {
      type: "c",
      value: new THREE.Color(0x0077ff)
    },
    bottomColor: {
      type: "c",
      value: scene.fog.color
    },
    offset: {
      type: "f",
      value: 0
    },
    exponent: {
      type: "f",
      value: 0.4
    }
  };
  uniforms.topColor.value = new THREE.Color(0x000000);
  material = new THREE.ShaderMaterial({
    vertexShader: vertexShader,
    fragmentShader: fragmentShader,
    uniforms: uniforms,
    side: THREE.BackSide,
    depthWrite: false
  });
  skyBox = new THREE.Mesh(geometry, material);
  return scene.add(skyBox);
};
