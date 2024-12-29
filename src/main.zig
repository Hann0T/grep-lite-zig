const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const args = std.process.argsAlloc(allocator) catch |err| {
        std.log.err("Failed to alloc arguments: {s}", .{@errorName(err)});
        return;
    };
    defer std.process.argsFree(allocator, args);

    if (args.len < 3) {
        std.log.info("{s} <file> <pattern>", .{args[0]});
        return;
    }

    const file_name = args[1];
    const to_match = args[2];

    const file: std.fs.File = std.fs.cwd().openFile(file_name, .{ .mode = .read_only }) catch |err| {
        std.log.err("Failed to open file '{s}': {s}", .{ file_name, @errorName(err) });
        return;
    };
    defer file.close();

    const red = "\x1b[31m";
    const reset = "\x1b[0m";

    var buffer: [4096]u8 = undefined;
    while (file.reader().readUntilDelimiterOrEof(&buffer, '\n') catch |err| {
        std.log.err("Failed to read from file: {s}", .{@errorName(err)});
        return;
    }) |line| {
        const found = std.mem.indexOf(u8, line, to_match);
        if (found != null) {
            const start = found.?;
            const end = start + to_match.len;
            std.debug.print("{s}{s}{s}{s}{s}\n", .{ line[0..start], red, line[start..end], reset, line[end..] });
        }
    }
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
