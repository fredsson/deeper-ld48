const sdl = @cImport({
  @cInclude("SDL2/SDL.h");
});

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
    var event: sdl.SDL_Event = undefined;
    while(sdl.SDL_PollEvent(&event) != 0) {
      switch(event.@"type") {
        sdl.SDL_QUIT => {
          self.running = false;
        },
        sdl.SDL_KEYDOWN => {
          self.handleKeyDown(event.@"key");
        },
        sdl.SDL_KEYUP => {
          self.handleKeyUp(event.@"key");
        },
        else => {},
      }
    }
  }

  fn handleKeyDown(self: *App, keyEvent: sdl.SDL_KeyboardEvent) void {
    switch(keyEvent.keysym.sym) {
      sdl.SDLK_w, sdl.SDLK_a, sdl.SDLK_s, sdl.SDLK_d => {
        self.logger.debug("hello user!");
      },
      else => {}
    }
  }

  fn handleKeyUp(self: *App, keyEvent: sdl.SDL_KeyboardEvent) void {
        switch(keyEvent.keysym.sym) {
      sdl.SDLK_w, sdl.SDLK_a, sdl.SDLK_s, sdl.SDLK_d => {
        self.logger.debug("bye user!");
      },
      else => {}
    }
  }
};
