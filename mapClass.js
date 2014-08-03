mapClass = function ( vertices ) {
  /*
    Accepts vertices as an object of THREE.Vector3()'s 
  */

  this.vertices = _.mapValues({ vertices, function (vector) {
    tile = new tileClass({ position: vector });
    return tile;
  }

  this.startVertex = this.vertices[1];
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

  // TODO: abstract player height
  function lookAt ( _playerHeight ) {
    view = this.position.clone();
    view.y += _playerHeight;
    return view;
  }

}
