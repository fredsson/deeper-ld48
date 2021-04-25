const c = @import("c.zig");
const std = @import("std");

const Renderer = @import("gfx/renderer.zig").Renderer;
const Logger = @import("logger.zig").Logger;

const Game = @import("game/game.zig").Game;
const MovementDirection = @import("game/player.zig").MovementDirection;
const Scene = @import("gfx/view/scene.zig").Scene;

const ns_per_s = comptime std.time.ns_per_ms * std.time.ms_per_s;

var allocator = comptime std.heap.page_allocator;

pub const App = struct {
  running: bool,
  logger: Logger,
  renderer: *Renderer,
  game: *Game,
  scene: *Scene,
  frameTimer: std.time.Timer,

  pub fn init() App {

    var logger = Logger.init();

    var renderer: *Renderer = Renderer.init(allocator, logger) catch unreachable;

    var scene: *Scene = Scene.init(allocator);

    var app = .{
      .running = true,
      .logger = logger,
      .renderer = renderer,
      .game = Game.init(allocator, scene),
      .scene = scene,
      .frameTimer = std.time.Timer.start() catch unreachable,
    };

    renderer.addScene(app.scene);

    return app;
  }

  pub fn deinit(self: *App) void {
    self.scene.deinit();
    self.renderer.deinit();
  }

  pub fn run(self: *App) void {
    while(self.running) {
      const dt: f32 = @intToFloat(f32, self.frameTimer.lap()) / @intToFloat(f32, ns_per_s);

      self.handleEvents();

      self.game.update(dt);

      self.renderer.draw();

      c.SDL_Delay(17);
    }
  }

  fn handleEvents(self: *App) void {
    var event: c.SDL_Event = undefined;
    while(c.SDL_PollEvent(&event) != 0) {
      switch(event.@"type") {
        c.SDL_QUIT => {
          self.running = false;
        },
        c.SDL_KEYDOWN => {
          self.handleKeyDown(event.@"key");
        },
        c.SDL_KEYUP => {
          self.handleKeyUp(event.@"key");
        },
        else => {},
      }
    }
  }

  fn handleKeyDown(self: *App, keyEvent: c.SDL_KeyboardEvent) void {
    switch(keyEvent.keysym.sym) {
      c.SDLK_w => self.game.player.onMovement(MovementDirection.up),
      c.SDLK_a => self.game.player.onMovement(MovementDirection.left),
      c.SDLK_d => self.game.player.onMovement(MovementDirection.right),
      else => {}
    }
  }

  fn handleKeyUp(self: *App, keyEvent: c.SDL_KeyboardEvent) void {
    switch(keyEvent.keysym.sym) {
      c.SDLK_w => self.game.player.onStopMovement(MovementDirection.up),
      c.SDLK_a => self.game.player.onStopMovement(MovementDirection.left),
      c.SDLK_d => self.game.player.onStopMovement(MovementDirection.right),
      else => {}
    }
  }
};
