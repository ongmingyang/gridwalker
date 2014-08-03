/*
  The playerState class is a representation of the player on
  the map. The player faces a direction, and has a set of adjacent
  tiles.
*/

playerState = function ( map ) {

  this.map = map;
  this.tile = map.startVertex;
  this.position = this.tile.position;
  this.facing = "north" // begin facing north
  this.facingTile = this.tile.adjacent[this.facing];

  // Turn object for easy reference
  var turn = {
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
  }

  function lookRight() {
    this.facing = turn[this.facing]["right"];
    this.facingTile = this.position.adjacent[this.facing];
  }

  function lookLeft() {
    this.facing = turn[this.facing]["left"];
    this.facingTile = this.position.adjacent[this.facing];
  }

  function moveForward() {
    this.position = this.facingTile.position;
    this.facingTile = this.position.adjacent[this.facing];
  }

  function moveBackwards() {
    this.position = this.tile.adjacent[turn[this.facing]["back"]]
    this.facingTile = this.position.adjacent[this.facing];
  }

}
