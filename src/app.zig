const print = @import("std").debug.print;

pub const App = struct {
  pub fn init() App {
    print("init!\n", .{});
    return App {
    };
  }

  pub fn deinit(self: App) void {
    print("deinit\n", .{});
  }

  pub fn run(self: App) void {
    print("running!\n", .{});
  }
};
