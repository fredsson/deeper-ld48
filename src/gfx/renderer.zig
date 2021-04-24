const Logger = @import("../logger.zig").Logger;

const sdl = @cImport({
  @cInclude("SDL2/SDL.h");
});

const SdlError = error {
    SDLInitializationFailed,
};

pub const Renderer = struct {
  logger: *Logger,
  window: *sdl.SDL_Window,
  renderer: *sdl.SDL_Renderer,

  pub fn init(logger: *Logger) SdlError!Renderer {
    logger.debug("renderer init!");

    if (sdl.SDL_Init(sdl.SDL_INIT_VIDEO) != 0) {
      logger.debug("failed to init SDL..");
      return error.SDLInitializationFailed;
    }
    errdefer {
      sdl.SDL_Quit();
    }

    const window = sdl.SDL_CreateWindow(
      "Deeper and Deeper (LD48)",
      sdl.SDL_WINDOWPOS_UNDEFINED,
      sdl.SDL_WINDOWPOS_UNDEFINED,
      1024,
      768,
      sdl.SDL_WINDOW_OPENGL
    ) orelse {
      logger.debug("failed to create window..");
      return error.SDLInitializationFailed;
    };
    errdefer {
      sdl.SDL_DestroyWindow(window);
    }

    const renderer = sdl.SDL_CreateRenderer(window, -1, 0) orelse {
      logger.debug("failed to create renderer..");
      return error.SDLInitializationFailed;
    };

    return Renderer {
      .logger = logger,
      .window = window,
      .renderer = renderer
    };
  }

  pub fn deinit(self: Renderer) void {
    self.logger.debug("renderer deinit!");

    sdl.SDL_DestroyRenderer(self.renderer);
    sdl.SDL_DestroyWindow(self.window);
    sdl.SDL_Quit();
  }

  pub fn draw(self: Renderer) void {
    _ = sdl.SDL_RenderClear(self.renderer);

    sdl.SDL_RenderPresent(self.renderer);
  }
};
