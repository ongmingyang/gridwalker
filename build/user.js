
/*
  Create an example map
 */

(function() {
  var map, vertices;

  vertices = {
    0: new THREE.Vector3(),
    1: new THREE.Vector3(10, 0, 0),
    2: new THREE.Vector3(0, 0, 10),
    3: new THREE.Vector3(-10, 0, 0),
    4: new THREE.Vector3(0, 0, -10),
    5: new THREE.Vector3(20, 1, 0),
    6: new THREE.Vector3(30, 2, 0),
    7: new THREE.Vector3(30, 1, 10),
    8: new THREE.Vector3(0, 1, 20),
    9: new THREE.Vector3(10, 2, 20),
    10: new THREE.Vector3(20, 3, 20),
    11: new THREE.Vector3(30, 2, 20),
    12: new THREE.Vector3(20, 2, 30),
    13: new THREE.Vector3(0, 0, -20),
    14: new THREE.Vector3(10, 0, -20),
    15: new THREE.Vector3(20, 0, -20),
    16: new THREE.Vector3(30, 1, -20),
    17: new THREE.Vector3(40, 2, -10),
    18: new THREE.Vector3(50, 3, -10),
    19: new THREE.Vector3(50, 4, 0),
    20: new THREE.Vector3(60, 4, 0)
  };

  map = new Map(vertices);

  map.setTile(6, window.globalMeshes.tile1);

  map.setTile(12, window.globalMeshes.cube0);

  map.setTile(19, window.globalMeshes.tile1);

  map.setTile(20, window.globalMeshes.cube0);

  map.declareAnimating([6, 14, 19]);

  map.link(0, 1, "north");

  map.link(0, 3, "south");

  map.link(0, 2, "east");

  map.link(0, 4, "west");

  map.link(1, 5, "north");

  map.link(5, 6, "north");

  map.link(6, 7, "east");

  map.link(2, 8, "east");

  map.link(8, 9, "north");

  map.link(9, 10, "north");

  map.link(10, 11, "north");

  map.link(11, 7, "west");

  map.link(10, 12, "east");

  map.link(4, 13, "west");

  map.link(13, 14, "north");

  map.link(14, 15, "north");

  map.link(15, 16, "north");

  map.link(17, 18, "north");

  map.link(18, 19, "east");

  map.link(19, 20, "north");

  map.onInteract(20, 'click', function(n) {
    return window.narrator.narrate("win!!!!");
  });

  map.onInteract(3, 'trigger', function(n) {
    return window.narrator.narrate("There's nothing back this way");
  });

  map.onInteract(12, 'click', function(n) {
    if (n === 0) {
      window.narrator.narrate("I wonder what this does!");
    }
    map.freezeInteraction(12);
    map.makeAnimation({
      description: "This slides the orange block to the left so that the player can step across to the next platform from the west path",
      vertex: 6,
      trigger: function(vertex, t, controls) {
        if (controls.triggered) {
          map.unlink(6, 7);
          map.unlink(6, 5);
          map.unlink(6, 16);
          map.unlink(6, 17);
        }
        if (n % 2 === 0) {
          vertex.z = -2 * t;
        }
        if (n % 2 === 1) {
          vertex.z = -10 + 2 * t;
        }
        if (vertex.z < -10) {
          vertex.z = -10;
          map.link(6, 16, "west");
          map.link(6, 17, "north");
          map.unfreezeInteraction(12);
          controls.done();
        }
        if (vertex.z > 0) {
          vertex.z = 0;
          map.link(6, 7, "east");
          map.link(6, 5, "south");
          map.unfreezeInteraction(12);
          return controls.done();
        }
      }
    });
    return map.makeAnimation({
      description: "This slides the northmost orange block to the right so that the player is prevented from stepping across to the next platform from the west path",
      vertex: 19,
      trigger: function(vertex, t, controls) {
        if (controls.triggered) {
          map.unlink(19, 18);
          map.unlink(19, 20);
        }
        if (n % 3 === 0) {
          vertex.z = 2 * t;
          vertex.y = 4 + t;
          if (vertex.z > 10) {
            vertex.z = 10;
            controls.done();
          }
        }
        if (n % 3 === 1) {
          vertex.z = 10;
          vertex.y = 9 - 2 * t;
          if (vertex.y < -1) {
            controls.done();
          }
        }
        if (n % 3 === 2) {
          vertex.y = -1 + t;
          vertex.z = 10 - 2 * t;
          if (vertex.z < 0) {
            vertex.z = 0;
            vertex.y = 4;
            map.link(18, 19, "east");
            map.link(19, 20, "north");
            return controls.done();
          }
        }
      }
    });
  });

  map.makeAnimation({
    description: "Tile moves up and down and disconnects player at some points",
    vertex: 14,
    animate: function(vertex, t) {
      vertex.y = 4 + 5 * Math.sin(t % 62.83);
      if (vertex.y <= 0) {
        map.link(13, 14, 'north');
        return map.link(14, 15, 'north');
      } else {
        map.unlink(13, 14, 'north');
        return map.unlink(14, 15, 'north');
      }
    }
  });

  map.setClones({
    0: {
      name: "Fooman",
      description: "Has no distinguishing properties",
      facing: "north",
      vertex: 0
    },
    1: {
      name: "Barman",
      description: "Works at a tavern",
      facing: "north",
      vertex: 8
    }
  });

  window.globalMaps.example = map;

}).call(this);

(function() {
  window.globalTerrains.example = function(scene) {
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

}).call(this);
