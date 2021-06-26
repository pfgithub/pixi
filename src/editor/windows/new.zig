const std = @import("std");
const upaya = @import("upaya");
const imgui = @import("imgui");
const canvas = @import("../windows/canvas.zig");
const menubar = @import("../menubar.zig");

const types = @import("../types/types.zig");
const File = types.File;
const Layer = types.Layer;
const Sprite = types.Sprite;

const checkerColor1: upaya.math.Color = .{ .value = 0xFFDDDDDD };
const checkerColor2: upaya.math.Color = .{ .value = 0xFFEEEEEE };

var new_file: File = .{
    .name = "untitled",
    .width = 32,
    .height = 32,
    .tileWidth = 32,
    .tileHeight = 32,
    .background = undefined,
    .layers = undefined,
    .sprites = undefined,
};
var tiles_wide: i32 = 1;
var tiles_tall: i32 = 1;

pub fn draw() void {

    const width = 300;
    const height = 150;
    const center = imgui.ogGetWindowCenter();
    imgui.ogSetNextWindowSize(.{ .x = width, .y = height }, imgui.ImGuiCond_Always);
    imgui.ogSetNextWindowPos(.{ .x = center.x - width/2, .y = center.y - height/ 2 }, imgui.ImGuiCond_Always, .{});
    if (imgui.igBeginPopupModal("New File", &menubar.new_file_popup, imgui.ImGuiWindowFlags_Popup | imgui.ImGuiWindowFlags_NoResize)) {
        defer imgui.igEndPopup();

        _ = imgui.ogDrag(i32, "Tile Width", &new_file.tileWidth, 1, 1, 1024);
        _ = imgui.ogDrag(i32, "Tile Height", &new_file.tileHeight, 1, 1, 1024);
        _ = imgui.ogDrag(i32, "Tiles Wide", &tiles_wide, 1, 1, 1024);
        _ = imgui.ogDrag(i32, "Tiles Tall", &tiles_tall, 1, 1, 1024);

        if (imgui.ogButton("Create")) {

            new_file.height = new_file.tileHeight * tiles_tall;
            new_file.width = new_file.tileWidth * tiles_wide;

            var name = std.fmt.allocPrint(upaya.mem.allocator, "untitled_{d}", .{canvas.getNumberOfFiles()}) catch unreachable;
            defer upaya.mem.allocator.free(name);

            new_file.name = std.mem.dupe(upaya.mem.allocator, u8, name) catch unreachable;
            new_file.background = upaya.Texture.initChecker(new_file.width, new_file.height, checkerColor1, checkerColor2);
            new_file.layers = std.ArrayList(Layer).init(upaya.mem.allocator);
            new_file.sprites = std.ArrayList(Sprite).initCapacity(upaya.mem.allocator, @intCast(usize, tiles_wide * tiles_tall)) catch unreachable;

            var image = upaya.Image.init(@intCast(usize, new_file.width), @intCast(usize, new_file.height));
            image.fillRect(.{.x = 0, .y = 0, .width = new_file.width, .height = new_file.height}, upaya.math.Color.transparent);

            new_file.layers.append(.{.name = "Layer 0", .image = image, .texture = image.asTexture(.nearest)}) catch unreachable;
            
            // for (new_file.sprites.items) |sprite, i| {
            //     var sprite_name = std.fmt.allocPrint(upaya.mem.allocator, "{s}_{d}", .{name, i}) catch unreachable;
            //     defer upaya.mem.allocator.free(sprite_name);
            //     var sprite_origin: upaya.math.Vec2 = .{.x = @intToFloat(f32, @divTrunc(new_file.tileWidth, 2)), .y = @intToFloat(f32, @divTrunc(new_file.tileHeight, 2))};
            //     new_file.sprites.items[i].name = std.mem.dupe(upaya.mem.allocator, u8, sprite_name) catch unreachable;
            //     new_file.sprites.items[i].origin = sprite_origin;
            //     new_file.sprites.items[i].index = i;
            // }

            var i : usize = 0;
            while (i < tiles_wide * tiles_tall) : (i += 1) {
                var sprite_name = std.fmt.allocPrint(upaya.mem.allocator, "{s}_{d}\u{0}", .{new_file.name, i}) catch unreachable;
                defer upaya.mem.allocator.free(sprite_name);
                var sprite_origin: upaya.math.Vec2 = .{.x = @intToFloat(f32, @divTrunc(new_file.tileWidth, 2)), .y = @intToFloat(f32, @divTrunc(new_file.tileHeight, 2))};
                var new_sprite: Sprite = .{
                    .name = std.mem.dupe(upaya.mem.allocator, u8, sprite_name) catch unreachable,
                    .origin = sprite_origin,
                    .index = i,
                };
                new_file.sprites.append(new_sprite) catch unreachable;

            }

            canvas.newFile(new_file);
            menubar.new_file_popup = false;
        }
    }
}
