//! By convention, main.zig is where your main function lives in the case that
//! you are building an executable. If you are making a library, the convention
//! is to delete this file and start with root.zig instead.
const std = @import("std");
const posix = std.posix;
const Arena = struct {
    const Self = @This();
    raw_allocation: []align(std.mem.page_size) u8,
    next_addr: *anyopaque,

    fn init(size: usize) ?Self {
        const addr: []align(std.mem.page_size) u8 = std.posix.mmap(null, size, posix.PROT.READ | posix.PROT.WRITE, .{ .TYPE = .PRIVATE, .ANONYMOUS = true }, -1, 0) catch return null;
        return .{ .raw_allocation = addr, .next_addr = @ptrCast(addr.ptr) };
    }

    pub fn rawAlloc(self: *Self, size: usize) ?[]u8 {
        if (size + self.curr >= self.raw.len) {
            return null;
        }
        const new_size = self.curr + size;
        const slice = self.raw[self.curr..new_size];
        self.*.curr = new_size;
        return slice;
    }

    pub fn alloc(self: *Self, T: type, size: usize) ?[]T {
        // Get size of T and total size, see if it exceeds the buffer
        // Get offset and alignment needed
        const type_pointer: [*]T = @ptrCast(@alignCast(self.next_addr));
        const type_size: usize = @as(usize, @sizeOf(T)) * size;
        const max_address: usize = @as(usize, @intFromPtr(&self.raw_allocation[self.raw_allocation.len - 1]));

        const end_address = @as(usize, @intFromPtr(type_pointer)) + type_size;
        if (end_address > max_address) {
            return null;
        }
        self.*.next_addr = @ptrFromInt(end_address);
        return type_pointer[0..size];
    }

    pub fn deinit(self: *Self) void {
        // free backing allocator
        posix.munmap(self.raw_allocation);
    }

    pub fn free(self: *Self) void {
        self.*.next_addr = @ptrCast(self.raw_allocation.ptr);
    }
};

pub fn main() !void {}

test "Basic Allocation" {
    var arena = Arena.init(1024).?;
    defer arena.deinit();
    std.debug.print("Original Pointer: {*}. Size: {d}. Next Addr: {*}\n", .{ arena.raw_allocation.ptr, arena.raw_allocation.len, arena.next_addr });
    const MyStruct = struct {
        x1: usize,
        x2: u32,
    };

    const buff = arena.alloc(MyStruct, 10).?;
    std.debug.print("Buffer Addr: {*}\n", .{buff.ptr});
    std.debug.print("Next Addr: {*}\n", .{arena.next_addr});
    std.debug.assert(@sizeOf(MyStruct) * 10 == @intFromPtr(arena.next_addr) - @intFromPtr(arena.raw_allocation.ptr));
    arena.free();
    std.debug.assert(@intFromPtr(arena.next_addr) == @intFromPtr(arena.raw_allocation.ptr));
}
