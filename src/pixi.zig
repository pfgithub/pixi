const std = @import("std");
const upaya = @import("upaya");
const imgui = @import("imgui");
const sokol = @import("sokol");

pub const editor = @import("editor/editor.zig");

pub fn main() !void {

    upaya.run(.{
        .init = editor.init,
        .update = editor.update,
        .shutdown = editor.shutdown,
        .docking = true,
        .docking_flags = imgui.ImGuiDockNodeFlags_NoWindowMenuButton | imgui.ImGuiDockNodeFlags_HiddenTabBar | imgui.ImGuiDockNodeFlags_NoCloseButton | imgui.ImGuiDockNodeFlags_NoTabBar,
        .setupDockLayout = editor.setupDockLayout,
        .window_title = "Pixi",
        .onFileDropped = editor.onFileDropped,
        .fullscreen = true, //currently broken on macOS
    });
}


