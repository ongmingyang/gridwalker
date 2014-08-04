mapClass = function ( vertices ) {
  //  Accepts vertices as an object of THREE.Vector3()'s 
  this.tiles = _.mapValues(vertices, function (vector) {
    tile = new tileClass({
      position: vector,
      walkable: true
      });
    return tile;
  });

  // The walls object will be populated later with this.computeBoundary
  this.walls = {};

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

  /*
    Call this function after all vertices have been linked
    Function creates "wall" tiles for each null adjacent reference
    so that the player can compute the camera view
    TODO: it should be possible to custom define wall tiles in the future
    TODO: wall class should extend tile class
  */
  this.computeBoundary = function () {

    var i = 0; // counter for number of walls
    var walls = this.walls; // reference object for walls
    var axes = {
      north: new THREE.Vector3( 10, 0, 0 ),
      south: new THREE.Vector3( -10, 0, 0 ),
      east: new THREE.Vector3( 0, 0, 10 ),
      west: new THREE.Vector3( 0, 0, -10 )
    };

    _.forOwn(this.tiles, function(tile, key) {
      _.forOwn( tile.adjacent, function(obj, direction) {
        if (_.isNull(obj)) {
          walls[i] = new tileClass({
            position: tile.position.clone(),
            walkable: false
            });
          walls[i].position.add( axes[direction] );
          tile.adjacent[direction] = walls[i];
          i++;
        }
      });
    });
  }
}

tileClass = function ( init ) {
  if ( _.isEmpty(init) ) {
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
  }
}

/*
  Create an example map
*/
var vertices = {
  0: new THREE.Vector3(),
  1: new THREE.Vector3( 10, 0, 0 ),
  2: new THREE.Vector3( 0, 0, 10 ),
  3: new THREE.Vector3( -10, 0, 0 ),
  4: new THREE.Vector3( 0, 0, -10 ),
  5: new THREE.Vector3( 20, 0, 0 )
}

var exampleMap = new mapClass( vertices );

exampleMap.link( 0, 1, "north" );
exampleMap.link( 0, 3, "south" );
exampleMap.link( 0, 2, "east" );
exampleMap.link( 0, 4, "west" );
exampleMap.link( 1, 5, "north" );

exampleMap.computeBoundary();

console.log(exampleMap.tiles);
