
const App = @import("app.zig").App;

pub fn main() !void {
  var app = App.init();
  defer app.deinit();

  app.run();
}
