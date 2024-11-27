const std = @import("std");
const BamParser = @import("BamParser.zig");

pub fn main() !void {
    var buffer: [4096]u8 = undefined;
    var bufferedAllocator = std.heap.FixedBufferAllocator.init(&buffer);

    const allocator = bufferedAllocator.allocator();
    const parser = BamParser.init(allocator);
    try parser.readHeader();
}
