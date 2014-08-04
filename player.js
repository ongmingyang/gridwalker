/*
  The playerState class is a representation of the player on
  the map. The player faces a direction, and has a set of adjacent
  tiles.
*/

playerState = function ( map ) {

  this.map = map;
  this.tile = map.startTile;
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
  };

  this.lookRight = function () {
    this.facing = turn[this.facing]["right"];
    this.facingTile = this.tile.adjacent[this.facing];
  }

  this.lookLeft = function () {
    this.facing = turn[this.facing]["left"];
    this.facingTile = this.tile.adjacent[this.facing];
  }

  this.moveForward = function () {
    if (this.facingTile.walkable) {
      this.tile = this.facingTile;
      this.position = this.tile.position;
      this.facingTile = this.facingTile.adjacent[this.facing];
    }
  }

  this.moveBackward = function () {
    destinationTile = this.tile.adjacent[turn[this.facing]["back"]];
    if (destinationTile.walkable) {
      this.facingTile = this.tile;
      this.tile = destinationTile;
      this.position = destinationTile.position;
    }
  }

}
