const math = @import("../math/math.zig");

pub const MovementDirection = enum {
  up,
  left,
  right
};

pub const PlayerListener = struct {
  onPositionChanged: fn(listener: *PlayerListener, position: math.Vec3)void,

  pub fn notifyPositionChanged(self: *PlayerListener, position: math.Vec3)void {
    self.onPositionChanged(self, position);
  }
};


pub const Player = struct {
  movementFlags: [4]bool,
  position: math.Vec3,
  listener: *PlayerListener,

  pub fn init(startPosition: math.Vec3, listener: *PlayerListener) Player {
    return Player {
      .movementFlags = .{false, false, false, false},
      .position = startPosition,
      .listener = listener,
    };
  }

  pub fn fixedUpdate(self: *Player) void {
  }

  pub fn update(self: *Player, dt: f32) void {
    const velocity = calculateVelocityFromFlags(self.movementFlags, dt);

    self.position = calculateNewPosition(self.position, velocity);
    self.listener.notifyPositionChanged(self.position);
  }

  pub fn onMovement(self: *Player, direction: MovementDirection) void {
    const index = indexFromMovementDirection(direction);
    self.movementFlags[index] = true;
  }

  pub fn onStopMovement(self: *Player, direction: MovementDirection) void {
    const index = indexFromMovementDirection(direction);
    self.movementFlags[index] = false;
  }


  fn indexFromMovementDirection(direction: MovementDirection) u32 {
    return switch(direction) {
      MovementDirection.up => 0,
      MovementDirection.left => 2,
      MovementDirection.right => 3
    };
  }

  fn calculateVelocityFromFlags(currentFlags: [4]bool, dt: f32) math.Vec3 {
    const movingLeft = currentFlags[indexFromMovementDirection(MovementDirection.left)];
    const movingRight = currentFlags[indexFromMovementDirection(MovementDirection.right)];

    var xMovement: f32 = 0;
    if (movingLeft) {
      xMovement -= 10;
    } if (movingRight) {
      xMovement += 10;
    }

    return math.Vec3{
      .x = xMovement * dt,
      .y = 0.,
      .z = 0.,
    };
  }

  fn calculateNewPosition(position: math.Vec3, velocity: math.Vec3) math.Vec3 {
    return math.Vec3{
      .x = position.x + velocity.x,
      .y = position.y + velocity.y,
      .z = position.z + velocity.z,
    };
  }
};
