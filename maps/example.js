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

