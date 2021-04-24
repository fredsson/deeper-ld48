const print = @import("std").debug.print;

pub const Logger = struct {
  pub fn init() Logger {
    return Logger {
    };
  }

  pub fn debug(self: Logger, message: []const u8) void {
    print("{}{}", .{message, "\n"});
  }
};
