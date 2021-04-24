const print = @import("std").debug.print;

const Renderer = @import("gfx/renderer.zig").Renderer;
const Logger = @import("logger.zig").Logger;

const sdl = @cImport({
  @cInclude("SDL2/SDL.h");
});

pub const App = struct {
  running: bool,
  renderer: Renderer,
  logger: Logger,

  pub fn init() App {
    const logger = Logger.init();

    const renderer = Renderer.init(logger) catch unreachable;

    return App {
      .running = true,
      .logger = logger,
      .renderer = renderer
    };
  }

  pub fn deinit(self: App) void {
    self.logger.debug("deinit!");
    self.renderer.deinit();
  }

  pub fn run(self: *App) void {
    while(self.running) {
      var event: sdl.SDL_Event = undefined;
      while(sdl.SDL_PollEvent(&event) != 0) {
        switch(event.@"type") {
          sdl.SDL_QUIT => {
            self.running = false;
          },
          else => {},
        }
      }

      self.renderer.draw();
    }
  }
};
