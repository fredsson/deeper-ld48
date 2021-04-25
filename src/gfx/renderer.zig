const c = @import("../c.zig");
const math = @import("../math/math.zig");
const std = @import("std");

const Logger = @import("../logger.zig").Logger;
const Scene = @import("view/scene.zig").Scene;

const SdlError = error {
    SDLInitializationFailed,
};

pub const Renderer = struct {
  allocator: *std.mem.Allocator,
  logger: *Logger,
  window: *c.SDL_Window,
  renderer: *c.SDL_Renderer,
  glContext: c.SDL_GLContext,
  scene: *Scene = undefined,

  pub fn init(allocator: *std.mem.Allocator, logger: *Logger) SdlError!*Renderer {
    if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0) {
      logger.debug("failed to init SDL..");
      return error.SDLInitializationFailed;
    }
    errdefer {
      c.SDL_Quit();
    }

    const window = c.SDL_CreateWindow(
      "Deeper and Deeper (LD48)",
      c.SDL_WINDOWPOS_UNDEFINED,
      c.SDL_WINDOWPOS_UNDEFINED,
      1024,
      768,
      c.SDL_WINDOW_OPENGL
    ) orelse {
      logger.debug("failed to create window..");
      return error.SDLInitializationFailed;
    };
    errdefer {
      c.SDL_DestroyWindow(window);
    }

    const renderer = c.SDL_CreateRenderer(window, -1, 0) orelse {
      logger.debug("failed to create renderer..");
      return error.SDLInitializationFailed;
    };

    const glContext = c.SDL_GL_CreateContext(window) orelse {
      logger.debug("failed to create gl context..");
      return error.SDLInitializationFailed;
    };

    c.glewExperimental = c.GL_TRUE;
    _ = c.glewInit();

    var result = allocator.create(Renderer) catch unreachable;
    result.allocator = allocator;
    result.logger = logger;
    result.window = window;
    result.renderer = renderer;
    result.glContext = glContext;

    return result;
  }


  pub fn deinit(self: *Renderer) void {
    c.SDL_GL_DeleteContext(self.glContext);
    c.SDL_DestroyRenderer(self.renderer);
    c.SDL_DestroyWindow(self.window);
    c.SDL_Quit();
    self.allocator.destroy(self);
  }

  pub fn addScene(self: *Renderer, scene: *Scene) void {
    self.scene = scene;
  }

  pub fn draw(self: *Renderer) void {
    c.glClearColor(0.0, 0.0, 0.0, 1.0);
    c.glClear(c.GL_COLOR_BUFFER_BIT);

    self.scene.draw();

    c.SDL_GL_SwapWindow(self.window);
  }
};


