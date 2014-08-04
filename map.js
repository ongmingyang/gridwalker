mapClass = function ( vertices ) {
  /*
    Accepts vertices as an object of THREE.Vector3()'s 
  */

  this.tiles = _.mapValues(vertices, function (vector) {
    tile = new tileClass({ position: vector });
    return tile;
  });

  this.startTile = this.tiles[0];

  // Links vertices
  this.link = function ( from, to, direction ) {
    var opposite = {
      north: "south",
      south: "north",
      east: "west",
      west: "east"
    };

    this.tiles[from].adjacent[direction] = this.tiles[to];
    this.tiles[to].adjacent[opposite[direction]] = this.tiles[from]; 
  }
}

tileClass = function ( init ) {
  if ( _.isEmpty(init) ) {
    console.log("WARNING: empty tile initialised!");
    return;
  }

  this.position = init.position || new THREE.Vector3();
  this.adjacent = {
    north: init.north || null,
    south: init.south || null,
    east: init.east || null,
    west: init.west || null
  }
}

/*
  Create an example map
*/
var vertices = {
  0: new THREE.Vector3(),
  1: new THREE.Vector3( 1, 0, 0 ),
  2: new THREE.Vector3( 0, 0, 1 ),
  3: new THREE.Vector3( -1, 0, 0 ),
  4: new THREE.Vector3( 0, 0, -1 )
}

var exampleMap = new mapClass( vertices );

exampleMap.link( 0, 1, "north" );
exampleMap.link( 0, 3, "south" );
exampleMap.link( 0, 2, "east" );
exampleMap.link( 0, 4, "west" );
