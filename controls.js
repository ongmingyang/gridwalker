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
  this.oldTarget = this.playerState.facingTarget.clone(); // THREE.Vector3
  this.oldPosition = this.playerState.cameraPosition.clone(); // THREE.Vector3

  // Some parameters
  this.walkSteps = 20; // Frames taken till move to next tile
  this.lookSteps = 15; // Frames taken till facing correct direction
  var currentSteps = 0; // Number of steps till completion of move action

  // A player's controls are frozen once he starts moving
  this.freeze = false;

  this.onKeyDown = function ( event ) {

    event.preventDefault();

    if ( this.freeze ) return;

    // Toggle freeze to lock keypress
    this.freeze = true;

    // Recompute target and camera
    this.oldTarget = this.playerState.facingTarget.clone();
    this.oldPosition = this.playerState.cameraPosition.clone();

    switch ( event.keyCode ) {

      case 38: /*up*/
      case 87: /*W*/ 
        this.playerState.moveForward();
        currentSteps = this.walkSteps;
        break;

      case 37: /*left*/
      case 65: /*A*/ 
        this.playerState.lookLeft();
        currentSteps = this.lookSteps;
        break;

      case 40: /*down*/
      case 83: /*S*/ 
        this.playerState.lookLeft();
        this.playerState.lookLeft();
        this.playerState.moveForward();
        this.playerState.lookRight();
        this.playerState.lookRight();
        currentSteps = this.walkSteps;
        break;

      case 39: /*right*/
      case 68: /*D*/ 
        this.playerState.lookRight();
        currentSteps = this.lookSteps;
        break;

      case 81: /*Q*/ 
        this.playerState.lookLeft();
        this.playerState.moveForward();
        this.playerState.lookRight();
        currentSteps = this.walkSteps;
        break;

      case 69: /*E*/ 
        this.playerState.lookRight();
        this.playerState.moveForward();
        this.playerState.lookLeft();
        currentSteps = this.walkSteps;
        break;

    }
  }

  this.update = function () {

    if (currentSteps <= 0) {
      // Reset flags
      this.freeze = false;
      return;
    } else {
      currentSteps--;
    }

    // View rotation
    // This block updates the target
    var delta = new THREE.Vector3();
    delta.subVectors(this.playerState.facingTarget, this.oldTarget);
    delta.divideScalar(currentSteps);

    // Forward and backward movement
    // This block updates the camera position
    var v = new THREE.Vector3();
    v.subVectors(this.playerState.cameraPosition, this.oldPosition);
    v.divideScalar(currentSteps);

    this.oldPosition.add( v );
    this.object.position.copy( this.oldPosition );

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
