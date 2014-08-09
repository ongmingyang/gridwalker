
/* CORE */
window.camera = void 0;

window.scene = void 0;

window.renderer = void 0;

window.player = void 0;

window.controls = void 0;

window.interactor = void 0;


/* VISUAL */

window.animator = void 0;


/* MAP */

window.globalMeshes = {};

window.globalMaps = {};


/*
  This class handles all global animations.
 */
var Animator;

Animator = (function() {
  function Animator(map) {
    this.animations = map.animations;
    this.globalClock = new THREE.Clock(true);
  }

  Animator.prototype.started = function(animation) {
    return function() {
      var started;
      started = animation.started;
      animation.started = true;
      return started;
    };
  };

  Animator.prototype.done = function(animation) {
    return function() {
      return animation.type = 'completed';
    };
  };

  Animator.prototype.update = function() {
    var a, prune, _i, _len, _ref;
    prune = false;
    _ref = this.animations;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      a = _ref[_i];
      if (_.isNull(a)) {
        prune = true;
      }
      switch (a.type) {
        case 'recurring':
          a.animate(this.globalClock.getElapsedTime());
          break;
        case 'single':
          a.localClock = new THREE.Clock(true);
          a.type = 'single-triggered';
          break;
        case 'single-triggered':
          a.animate(a.localClock.getElapsedTime(), this.started(a), this.done(a));
          break;
        case 'completed':
          a = null;
      }
    }
    if (prune) {
      this.animations = _.compact(this.animations);
    }
  };

  return Animator;

})();


/*
  The goal of the Controls object is to make the
  camera (object) follow the player's position in
  a smooth fashion, and invoke player actions upon
  triggering key events
 */
var Controls;

Controls = (function() {
  var bind, _lookSteps, _walkSteps;

  _walkSteps = 20;

  _lookSteps = 15;

  function Controls(object, domElement, player) {
    this.object = object;
    this.domElement = domElement;
    this.player = player;
    this.oldTarget = this.player.facingTarget();
    this.oldPosition = this.player.cameraPosition();
    this.mouseX = this.mouseY = 0;
    this.object.position.copy(this.oldPosition);
    this.object.lookAt(this.oldTarget);
    this.currentSteps = 0;
    this.freeze = false;
    this.dragging = false;
    $(window).keydown(bind(this, this.onKeyDown));
    $(window).keyup(bind(this, this.onKeyUp));
    $(window).mousemove(bind(this, this.onMouseMove));
  }

  bind = function(scope, fn) {
    return function() {
      fn.apply(scope, arguments);
    };
  };

  Controls.prototype.onKeyDown = function(event) {
    event.preventDefault();
    if (this.freeze) {
      return;
    }
    this.freeze = true;
    this.dragging = false;
    switch (event.keyCode) {
      case 38:
      case 87:
        this.player.moveForward();
        return this.currentSteps = _walkSteps;
      case 37:
      case 65:
        this.player.lookLeft();
        return this.currentSteps = _lookSteps;
      case 40:
      case 83:
        this.player.lookLeft();
        this.player.lookLeft();
        this.player.moveForward();
        this.player.lookRight();
        this.player.lookRight();
        return this.currentSteps = _walkSteps;
      case 39:
      case 68:
        this.player.lookRight();
        return this.currentSteps = _lookSteps;
      case 81:
        this.player.lookLeft();
        this.player.moveForward();
        this.player.lookRight();
        return this.currentSteps = _walkSteps;
      case 69:
        this.player.lookRight();
        this.player.moveForward();
        this.player.lookLeft();
        return this.currentSteps = _walkSteps;
      case 16:
        return this.dragging = true;
    }
  };

  Controls.prototype.onKeyUp = function(event) {
    event.preventDefault();
    switch (event.keyCode) {
      case 16:
        return this.dragging = false;
    }
  };

  Controls.prototype.onMouseMove = function(event) {
    if (!this.dragging) {
      return;
    }
    event.preventDefault();
    event.stopPropagation();
    this.mouseX = (window.innerWidth / 2 - event.pageX) / window.innerWidth / 10;
    return this.mouseY = (window.innerHeight / 2 - event.pageY) / window.innerHeight / 10;
  };

  Controls.prototype.update = function() {
    var delta, u, v;
    if (this.dragging) {
      u = new THREE.Vector3();
      u.subVectors(this.oldTarget, this.oldPosition);
      u.applyAxisAngle(this.object.up, -Math.PI / 2);
      this.oldTarget.applyAxisAngle(this.object.up, this.mouseX);
      this.oldTarget.applyAxisAngle(u.normalize(), this.mouseY);
    }
    if (this.currentSteps <= 0) {
      this.oldPosition.copy(this.player.cameraPosition());
      this.object.position.copy(this.oldPosition);
      this.freeze = false;
    } else {
      this.currentSteps--;
      delta = new THREE.Vector3();
      delta.subVectors(this.player.facingTarget(), this.oldTarget);
      delta.divideScalar(this.currentSteps);
      v = new THREE.Vector3();
      v.subVectors(this.player.cameraPosition(), this.oldPosition);
      v.divideScalar(this.currentSteps);
      this.oldPosition.add(v);
      this.object.position.copy(this.oldPosition);
      if (delta.length() <= 0.01) {
        this.currentSteps = 0;
      }
      this.oldTarget.add(delta);
    }
    this.object.lookAt(this.oldTarget);
  };

  return Controls;

})();


/*
  The Interactor class takes care of all interactions with
  surrounding objects
 */
var Interactor;

Interactor = (function() {
  var bind;

  function Interactor(player) {
    this.player = player;
    this.projector = new THREE.Projector();
    this.raycaster = new THREE.Raycaster(window.camera.position, this.player.facingTile.position.clone());
    $(window).mousedown(bind(this, this.onMouseDown));
  }

  bind = function(scope, fn) {
    return function() {
      fn.apply(scope, arguments);
    };
  };

  Interactor.prototype.onMouseDown = function(event) {
    var intersects, vector;
    event.preventDefault();
    vector = new THREE.Vector3((event.clientX / window.innerWidth) * 2 - 1, -(event.clientY / window.innerHeight) * 2 + 1, 0.5);
    this.projector.unprojectVector(vector, window.camera);
    this.objects = _.compact(_.pluck(_.filter(_.values(this.player.tile.adjacent), 'interactive'), 'object'));
    vector.sub(window.camera.position).normalize();
    this.raycaster.set(window.camera.position, vector);
    intersects = this.raycaster.intersectObjects(this.objects);
    if (!_.isEmpty(intersects)) {
      return intersects[0].object.interaction();
    }
  };

  return Interactor;

})();

var init, onWindowResize, render;

init = function(map) {
  var SCREEN_HEIGHT, SCREEN_WIDTH;
  SCREEN_WIDTH = window.innerWidth;
  SCREEN_HEIGHT = window.innerHeight;
  window.camera = new THREE.PerspectiveCamera(45, SCREEN_WIDTH / SCREEN_HEIGHT, 1, 10000);
  window.scene = new THREE.Scene();
  addTerrain(window.scene);
  map.displayTiles(window.scene);
  window.renderer = new THREE.WebGLRenderer({
    antialias: true
  });
  window.renderer.setClearColor(0x000000);
  window.renderer.setSize(SCREEN_WIDTH, SCREEN_HEIGHT);
  window.renderer.shadowMapEnabled = true;
  window.renderer.shadowMapType = THREE.PCFSoftShadowMap;
  document.body.appendChild(renderer.domElement);
  window.player = new Player(map);
  window.animator = new Animator(map);
  window.controls = new Controls(window.camera, window.renderer, window.player);
  window.addEventListener('resize', onWindowResize, false);
  window.interactor = new Interactor(window.player);
};

onWindowResize = function() {
  window.camera.aspect = window.innerWidth / window.innerHeight;
  window.camera.updateProjectionMatrix();
  window.renderer.setSize(window.innerWidth, window.innerHeight);
};

render = function() {
  requestAnimationFrame(render);
  window.renderer.render(window.scene, window.camera);
  window.animator.update();
  window.controls.update();
};

var Map, Tile;

Map = (function() {
  var _opposite;

  _opposite = {
    north: "south",
    south: "north",
    east: "west",
    west: "east"
  };

  function Map(vertices, defaultTile) {
    this.tiles = _.mapValues(vertices, function(vector) {
      return new Tile({
        position: vector,
        walkable: true,
        animating: false,
        interactive: false,
        object: defaultTile || window.globalMeshes.tile0.init(vector)
      });
    });
    this.walls = {};
    this.animations = [];
    this.startTile = this.tiles[0];
  }

  Map.prototype.link = function(from, to, direction) {
    this.tiles[from].adjacent[direction] = this.tiles[to];
    this.tiles[to].adjacent[_opposite[direction]] = this.tiles[from];
  };

  Map.prototype.unlink = function(from, to) {
    var tiles;
    tiles = this.tiles;
    _.forOwn(tiles[from].adjacent, function(tile, key) {
      if (tile === tiles[to]) {
        return tile.adjacent[_opposite[key]] = null;
      }
    });
    _.forOwn(tiles[to].adjacent, function(tile, key) {
      if (tile === tiles[from]) {
        return tile.adjacent[_opposite[key]] = null;
      }
    });
  };

  Map.prototype.setTile = function(id, tile) {
    return this.tiles[id].object = tile.init(this.tiles[id].object.position);
  };


  /*
    Call this function after all vertices have been linked
    Function creates "wall" tiles for each null adjacent reference
    so that the player can compute the camera view
    TODO: it should be possible to custom define wall tiles in the future
    TODO: wall class should extend tile class? discuss
   */

  Map.prototype.computeBoundary = function() {
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
      if (!tile.walkable) {
        return;
      }
      _.forOwn(tile.adjacent, function(obj, direction) {
        if (_.isNull(obj)) {
          walls[i] = new Tile({
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


  /*
    Merges all non-animating tile geometries and places them onto the scene
    ONLY MERGE NON-ANIMATING TILE GEOMETRIES KK THX
    Geometries are merged for performance purposes!
   */

  Map.prototype.displayTiles = function(scene) {
    var material, tileMap, tileMapMesh;
    tileMap = null;
    material = new THREE.MeshFaceMaterial(_.flatten(_.pluck(window.globalMeshes, "materials")));
    _.forOwn(this.tiles, function(tile, key) {
      if (tile.object) {
        if (tile.animating || tile.interactive) {
          return scene.add(tile.object);
        } else {
          _.forEach(tile.object.geometry.faces, function(face) {
            return face.materialIndex = _.findIndex(material.materials, {
              id: face.materialIndex
            });
          });
          if (tileMap == null) {
            return tileMap = tile.object.geometry;
          } else {
            tile.object.updateMatrix();
            return tileMap.merge(tile.object.geometry, tile.object.matrix);
          }
        }
      }
    });
    tileMapMesh = new THREE.Mesh(tileMap, material);
    tileMapMesh.receiveShadow = tileMapMesh.castShadow = true;
    return scene.add(tileMapMesh);
  };


  /*
    Set animating flag on vertices
   */

  Map.prototype.declareAnimating = function(indices) {
    var tiles;
    tiles = this.tiles;
    return _.forEach(indices, function(index) {
      return tiles[index].animating = true;
    });
  };


  /*
    Helper function that passes animations into an instance array
    that will later be iterated through by the animator object
   */

  Map.prototype.makeAnimation = function(args) {
    var tiles;
    tiles = this.tiles;
    tiles[args.vertex].animating = true;
    if (args.animate != null) {
      this.animations.push({
        description: args.description || null,
        type: 'recurring',
        animate: function(t) {
          args.animate(tiles[args.vertex].position, t);
          args.animate(tiles[args.vertex].object.position, t);
          return tiles[args.vertex].object.verticesNeedUpdate = true;
        }
      });
    }
    if (args.trigger != null) {
      this.animations.push({
        description: args.description || null,
        type: 'single',
        animate: function(delta, started, done) {
          var hasBegun;
          hasBegun = started();
          args.trigger(tiles[args.vertex].position, delta, hasBegun, done);
          args.trigger(tiles[args.vertex].object.position, delta, hasBegun, done);
          return tiles[args.vertex].object.verticesNeedUpdate = true;
        }
      });
      return;
    }
  };


  /*
    Helper function for interactives
   */

  Map.prototype.makeInteractive = function(index, fn, walkable) {
    this.tiles[index].interactive = true;
    this.tiles[index].object.interaction = fn || null;
    this.tiles[index].walkable = true || false;
  };

  return Map;

})();

Tile = (function() {
  function Tile(init) {
    if (_.isEmpty(init)) {
      console.log("WARNING: empty tile initialised!");
      return;
    }
    this.position = init.position || new THREE.Vector3();
    this.walkable = init.walkable || false;
    this.object = init.object || null;
    this.adjacent = {
      north: init.north || null,
      south: init.south || null,
      east: init.east || null,
      west: init.west || null
    };
  }

  return Tile;

})();


/*
  The Player class is a representation of the player on
  the map. The player faces a direction, and has a set of adjacent
  tiles. The player's camera is defined and updated in this.computeCamera
 */
var Player;

Player = (function() {
  var turn, _playerHeight;

  _playerHeight = 3;

  turn = {
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
  }

  Player.prototype.facingTarget = function() {
    var v;
    v = this.facingTile.position.clone();
    v.y += _playerHeight;
    return v;
  };

  Player.prototype.cameraPosition = function() {
    var v;
    v = this.position.clone();
    v.y += _playerHeight;
    return v;
  };

  Player.prototype.lookRight = function() {
    this.facing = turn[this.facing]["right"];
    this.facingTile = this.tile.adjacent[this.facing];
  };

  Player.prototype.lookLeft = function() {
    this.facing = turn[this.facing]["left"];
    this.facingTile = this.tile.adjacent[this.facing];
  };

  Player.prototype.moveForward = function() {
    if (this.facingTile.walkable) {
      this.tile = this.facingTile;
      this.position = this.tile.position;
      this.facingTile = this.tile.adjacent[this.facing];
    }
  };

  Player.prototype.teleport = function(index) {
    if (map.tiles[index].walkable) {
      this.tile = map.tiles[index];
      this.position = this.tile.position;
      this.facingTile = this.tile.adjacent[this.facing];
    }
  };

  return Player;

})();

var addTerrain;

addTerrain = function(scene) {
  var d, fragmentShader, geometry, light, material, skyBox, uniforms, vertexShader;
  scene.fog = new THREE.Fog(0x605570, 10, 200);
  light = new THREE.DirectionalLight(0xffdd66, 1.5);
  light.position.set(-150, 150, 0);
  light.castShadow = true;
  d = 100;
  light.shadowCameraLeft = -d;
  light.shadowCameraRight = d;
  light.shadowCameraTop = d;
  light.shadowCameraBottom = -d;
  light.shadowCameraFar = 500;
  light.shadowMapWidth = 2048;
  light.shadowMapHeight = 2048;
  scene.add(light);
  scene.add(new THREE.AmbientLight(0x404040));

  /*
  plane = new THREE.PlaneGeometry(500, 500)
  groundTexture = THREE.ImageUtils.loadTexture("textures/grass.jpg")
  groundTexture.wrapS = groundTexture.wrapT = THREE.RepeatWrapping
  groundTexture.repeat.set 25, 25
  groundTexture.anisotropy = 16
  groundMaterial = new THREE.MeshPhongMaterial
    color: 0x663399
    opacity: 0
    specular: 0x111111
     *map: groundTexture
  planeMesh = new THREE.Mesh(plane, groundMaterial)
  planeMesh.rotation.x = -Math.PI / 2
  planeMesh.receiveShadow = true
  scene.add planeMesh
   */
  geometry = new THREE.SphereGeometry(4000, 32, 12);
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

window.globalMeshes.cube0 = {
  materials: [
    new THREE.MeshPhongMaterial({
      id: 3,
      color: 0xcceeff
    })
  ],
  init: function(position) {
    var cube, geometry;
    geometry = new THREE.BoxGeometry(2, 2, 2);
    _.forEach(geometry.vertices, function(vertex) {
      return vertex.y += 3;
    });
    _.forEach(geometry.faces, function(face) {
      return face.materialIndex = 3;
    });
    cube = new THREE.Mesh(geometry, this.materials[0]);
    cube.position.copy(position);
    return cube;
  }
};

window.globalMeshes.tile0 = {
  materials: [
    new THREE.MeshBasicMaterial({
      id: 1,
      color: 0x00ff00,
      wireframe: true
    })
  ],
  init: function(position) {
    var cube, geometry;
    geometry = new THREE.BoxGeometry(10, 3, 10);
    _.forEach(geometry.vertices, function(vertex) {
      return vertex.y -= 1.5;
    });
    _.forEach(geometry.faces, function(face) {
      return face.materialIndex = 1;
    });
    cube = new THREE.Mesh(geometry, this.materials[0]);
    cube.position.copy(position);
    return cube;
  }
};

window.globalMeshes.tile1 = {
  materials: [
    new THREE.MeshPhongMaterial({
      id: 2,
      color: 0xffeedd
    })
  ],
  init: function(position) {
    var cube, geometry;
    geometry = new THREE.BoxGeometry(10, 3, 10);
    _.forEach(geometry.vertices, function(vertex) {
      return vertex.y -= 1.5;
    });
    _.forEach(geometry.faces, function(face) {
      return face.materialIndex = 2;
    });
    cube = new THREE.Mesh(geometry, this.materials[0]);
    cube.position.copy(position);
    return cube;
  }
};
