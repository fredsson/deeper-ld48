const Builder = @import("std").build.Builder;

pub fn build(b: *Builder) void {
  const mode = b.standardReleaseOptions();
  const exe = b.addExecutable("zigsdl", "src/main.zig");
  exe.setBuildMode(mode);
  exe.linkSystemLibrary("SDL2");
  exe.linkSystemLibrary("c");

  b.default_step.dependOn(&exe.step);
  b.installArtifact(exe);

  const run = b.step("run", "Run the game");
  const run_cmd = exe.run();
  run.dependOn(&run_cmd.step);
}