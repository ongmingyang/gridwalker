
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
    12: new THREE.Vector3(20, 2, 30)
  };

  map = new Map(vertices);

  map.setTile(6, window.globalMeshes.tile1);

  map.setTile(12, window.globalMeshes.cube0);

  map.declareAnimating([2, 6, 12]);

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

  map.makeInteractive(12, function() {
    map.makeAnimation({
      vertex: 2,
      animate: function(vertex, t) {
        return vertex.y = Math.cos(t % 62.83);
      }
    });
    return map.makeAnimation({
      vertex: 6,
      trigger: function(vertex, t, started, done) {
        if (!started) {
          map.unlink(6, 7);
          map.unlink(6, 5);
          map.computeBoundary();
        }
        vertex.z = -2 * t;
        if (vertex.z <= -10) {
          return done();
        }
      }
    });
  });

  map.makeAnimation({
    description: "Tile moves up and down",
    vertex: 11,
    animate: function(vertex, t) {
      return vertex.y = 2 + Math.sin(t % 62.83);
    }
  });

  map.computeBoundary();

  window.globalMaps.example = map;

}).call(this);
