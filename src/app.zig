const c = @import("c.zig");

const Renderer = @import("gfx/renderer.zig").Renderer;
const Logger = @import("logger.zig").Logger;

pub const App = struct {
  running: bool,
  logger: Logger,
  renderer: Renderer,

  pub fn init() App {
    const logger = Logger.init();

    const renderer = Renderer.init(logger) catch unreachable;

    return App {
      .running = true,
      .logger = logger,
      .renderer = renderer,
    };
  }

  pub fn deinit(self: App) void {
    self.logger.debug("deinit!");
    self.renderer.deinit();
  }

  pub fn run(self: *App) void {
    while(self.running) {

      self.handleEvents();

      self.renderer.draw();
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
      c.SDLK_w, c.SDLK_a, c.SDLK_s, c.SDLK_d => {
        self.logger.debug("hello user!");
      },
      else => {}
    }
  }

  fn handleKeyUp(self: *App, keyEvent: c.SDL_KeyboardEvent) void {
    switch(keyEvent.keysym.sym) {
      c.SDLK_w, c.SDLK_a, c.SDLK_s, c.SDLK_d => {
        self.logger.debug("bye user!");
      },
      else => {}
    }
  }
};
