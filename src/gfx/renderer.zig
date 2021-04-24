const std = @import("std");
const debug = std.debug;

const Logger = @import("../logger.zig").Logger;
const Shader = @import("shader.zig").Shader;

const c = @import("../c.zig");
const opengl = @import("opengl.zig");

const SdlError = error {
    SDLInitializationFailed,
};

const noPointerOffset: ?*const c_void = @intToPtr(?*c_void, 0);

var vao: c.GLuint = 0;
var vbo: c.GLuint = 0;

pub const Renderer = struct {
  logger: *Logger,
  window: *c.SDL_Window,
  renderer: *c.SDL_Renderer,
  glContext: c.SDL_GLContext,
  defaultShader: Shader,

  pub fn init(logger: *Logger) SdlError!Renderer {
    logger.debug("renderer init!");

    if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0) {
      logger.debug("failed to init c..");
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

    return Renderer {
      .logger = logger,
      .window = window,
      .renderer = renderer,
      .glContext = glContext,
      .defaultShader = Shader.init("default"),
    };
  }

  pub fn deinit(self: Renderer) void {
    self.logger.debug("renderer deinit!");

    self.defaultShader.deinit();

    c.SDL_GL_DeleteContext(self.glContext);
    c.SDL_DestroyRenderer(self.renderer);
    c.SDL_DestroyWindow(self.window);
    c.SDL_Quit();
  }

  pub fn draw(self: Renderer) void {
    c.glClearColor(0.0, 0.0, 0.0, 1.0);
    c.glClear(c.GL_COLOR_BUFFER_BIT);

    if (vao == 0 and vbo == 0) {
      self.logger.debug("creating vao & vbo!");

      c.glGenBuffers(1, &vbo);
      c.glBindBuffer(c.GL_ARRAY_BUFFER, vbo);
      var array: [9]f32 = .{
        -0.5, -0.5, 0.0,
        0.0,  0.5, 0.0,
        0.5, -0.5, 0.0,
      };
      c.glBufferData(c.GL_ARRAY_BUFFER, array.len * @sizeOf(f32), &array[0], c.GL_STATIC_DRAW);

      c.glGenVertexArrays(1, &vao);
      c.glBindVertexArray(vao);
      c.glEnableVertexAttribArray(0);
      c.glBindBuffer(c.GL_ARRAY_BUFFER, vbo);
      c.glVertexAttribPointer(0, 3, c.GL_FLOAT, c.GL_FALSE, 0, noPointerOffset);
    }

    self.defaultShader.enable();

    c.glBindVertexArray(vao);
    c.glDrawArrays(c.GL_TRIANGLES, 0, 3);

    c.SDL_GL_SwapWindow(self.window);
  }
};
