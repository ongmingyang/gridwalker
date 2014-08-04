/*
  The goal of the playerControls object is to make the
  camera (object) follow the playerState (player)'s position
  in a smooth fashion, and invoke playerState actions upon
  triggering key events
*/

playerControls = function ( object, domElement, playerState ) {

  // The camera, the dom element, and the player state
  this.object = object;
  this.domElement = domElement;
  this.playerState = playerState;

  // The tile the user will walk to if moving forward
  this.target = this.playerState.facingTile.position; // THREE.Vector3 object
  this.oldTarget = this.target.clone(); // THREE.Vector3 object
  this.object.position = this.playerState.position; // THREE.Vector3 object
  this.object.oldPosition = this.playerState.position; // THREE.Vector3 object

  // Some parameters
  this.walkSteps = 20; // Frames taken till move to next tile
  this.lookSteps = 20; // Frames taken till facing correct direction
  var currentSteps = 0; // Number of steps till completion of move action

  this.moveForward = false;
  this.moveBackward = false;
  this.lookLeft = false;
  this.lookRight = false;
  this.strafeLeft = false;
  this.strafeRight = false;

  // A player's controls are frozen once he starts moving
  this.freeze = false;

  this.onKeyDown = function ( event ) {

    //event.preventDefault();

    if ( this.freeze ) return;

    // Toggle freeze to lock keypress
    this.freeze = true;

    // Recompute player's view
    this.oldTarget = this.target.clone();

    switch ( event.keyCode ) {

      case 38: /*up*/
      case 87: /*W*/ 
        this.moveForward = true; 
        this.keyIsDown = true;
        this.playerState.moveForward();
        currentSteps = this.walkSteps;
        break;

      case 37: /*left*/
      case 65: /*A*/ 
        this.lookLeft = true; 
        this.keyIsDown = true;
        this.playerState.lookLeft();
        currentSteps = this.lookSteps;
        break;

      case 40: /*down*/
      case 83: /*S*/ 
        this.moveBackward = true; 
        this.keyIsDown = true;
        this.playerState.moveBackward();
        currentSteps = this.walkSteps;
        break;

      case 39: /*right*/
      case 68: /*D*/ 
        this.lookRight = true; 
        this.keyIsDown = true;
        this.playerState.lookRight();
        currentSteps = this.lookSteps;
        break;

      case 81: /*Q*/ 
        this.strafeLeft = true;
        this.keyIsDown = true;
        this.playerState.lookLeft();
        this.playerState.moveForward();
        this.playerState.lookRight();
        currentSteps = this.walkSteps;
        break;

      case 69: /*E*/ 
        this.strafeRight = true;
        this.keyIsDown = true;
        this.playerState.lookRight();
        this.playerState.moveForward();
        this.playerState.lookLeft();
        currentSteps = this.walkSteps;
        break;

    }

    this.target = this.playerState.facingTile.position; // Recompute new target

  }

  this.update = function () {

    if (currentSteps <= 0) {
      // Reset flags
      this.freeze = false;
      this.moveForward = false;
      this.moveBackward = false;
      this.lookLeft = false;
      this.lookRight = false;
      this.strafeLeft = false;
      this.strafeRight = false;
      return;
    } else {
      currentSteps--;
    }

    // View rotation
    // This block updates the target
    var delta = new THREE.Vector3();
    delta.subVectors(this.target, this.oldTarget);
    delta.divideScalar(currentSteps);

    // Forward and backward movement
    // TODO: This block updates the object position using oldPosition
    if ( this.moveForward || this.moveBackward ) {
      this.object.translateX( delta.x );
      this.object.translateY( delta.y );
      this.object.translateZ( delta.z );
    }

    this.oldTarget.add( delta );
    this.object.lookAt( this.oldTarget );
  }

  /* 
    Binds key event listeners to scope
  */
  window.addEventListener( 'keydown', bind( this, this.onKeyDown ), false );

  function bind( scope, fn ) {
    return function () {
      fn.apply( scope, arguments );
    };
  };

}
