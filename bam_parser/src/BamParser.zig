const std = @import("std");
const Bam = @import("Bam.zig");
const Allocator = std.mem.Allocator;
const Self = @This();

allocator: Allocator,
//fd: std.fs.File,
//reader: std.io.Reader,

sequence: ?usize, // where sequences begin
alignments: ?usize, // where alignments begin

pub fn init(allocator: Allocator) Self {
    return .{ .allocator = allocator, .sequence = null, .alignments = null };
}

pub fn deinit(self: Self) void {
    _ = self;
}

pub fn readHeader(self: Self) !void {
    _ = self;
    var file = try std.fs.cwd().openFile("test.bam", .{});
    defer file.close();
    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    // Read in first 4 bytes, should match Bam.magic
    var buffer: [4]u8 = undefined;
    _ = try in_stream.read(&buffer);
    std.debug.print("Buffer: {any}", .{buffer});
    if (!std.mem.eql(u8, &buffer, &Bam.magic)) {
        return BamError.IncorrectFile;
    }
}

const BamError = error{IncorrectFile // Missing Magic Header
};

fn verifyBam(self: Self) !void {
    _ = self;
}
