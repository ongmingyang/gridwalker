/*
  The playerState class is a representation of the player on
  the map. The player faces a direction, and has a set of adjacent
  tiles. The player's camera is defined and updated in this.computeCamera
*/

playerState = function ( map ) {

  var _playerHeight = 3;

  this.map = map;
  this.tile = map.startTile;
  this.position = this.tile.position;
  this.facing = "north" // begin facing north
  this.facingTile = this.tile.adjacent[this.facing];

  // Define facing target and eyelevel for camera position
  this.computeCamera = function () {
    this.facingTarget = this.facingTile.position.clone();
    this.facingTarget.y += _playerHeight;
    this.cameraPosition = this.position.clone();
    this.cameraPosition.y += _playerHeight;
  }
  this.computeCamera();

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
    this.computeCamera();
  }

  this.lookLeft = function () {
    this.facing = turn[this.facing]["left"];
    this.facingTile = this.tile.adjacent[this.facing];
    this.computeCamera();
  }

  this.moveForward = function () {
    if (this.facingTile.walkable) {
      this.tile = this.facingTile;
      this.position = this.tile.position;
      this.facingTile = this.facingTile.adjacent[this.facing];
      this.computeCamera();
    }
  }
}
