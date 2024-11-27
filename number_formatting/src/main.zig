const std = @import("std");
const stdin = std.io.getStdIn().reader();
const stdout = std.io.getStdOut().writer();

const Parser = struct {
    buff: []u8,
    curr: usize,
    const Self = @This();

    const errors = error{OutOfBounds};
    pub fn init(buff: []u8) Self {
        return .{ .buff = buff, .curr = 0 };
    }

    pub fn next(self: *Self) errors!u8 {
        if (self.curr < self.buff.len) {
            const tmp = self.curr;
            self.*.curr += 1;
            return self.buff[tmp];
        }
        return errors.OutOfBounds;
    }
    pub fn peak(self: *Self) errors!u8 {
        if (self.curr < self.buff.len) {
            return self.buff[self.curr];
        }
        return errors.OutOfBounds;
    }
    pub fn getBuff(self: *Self) []u8 {
        return self.buff[self.curr..];
    }
    pub fn readToSpaceOrEnd(self: *Self) []u8 {
        const start = self.curr;
        while (self.curr < self.buff.len) : (self.*.curr += 1) {
            if (self.curr == ' ') {
                self.curr += 1;
                return self.buff[start .. self.curr - 1];
            }
        }
        return self.buff[start..self.curr];
    }
};

pub const NumberConversions = struct {
    const errors = error{InvalidCharacter};
    pub fn bitToDecimal(num: []u8) !u64 {
        var bin_idx: u64 = 0;
        var idx: usize = num.len - 1;
        var out: u64 = 0;
        bit: switch (num[idx]) {
            '0' => {
                if (idx == 0) {
                    return out;
                }
                idx -= 1;
                bin_idx += 1;
                continue :bit num[idx];
            },
            '1' => {
                out += std.math.pow(u64, @as(u64, 2), bin_idx);
                if (idx == 0) {
                    return out;
                }
                idx -= 1;
                bin_idx += 1;
                continue :bit num[idx];
            },
            else => {
                return errors.InvalidCharacter;
            },
        }
        noreturn;
    }
    pub fn hex(buff: []u8) !u64 {
        var bin_idx: u64 = 0;
        var idx: usize = buff.len - 1;
        var out: u64 = 0;
        num: switch (buff[idx]) {
            '0'...'9' => |val| {
                const char: u64 = @as(u64, val - '0');
                out += std.math.pow(u64, @as(u64, 10), bin_idx) * char;
                if (idx == 0) {
                    return out;
                }
                idx -= 1;
                bin_idx += 1;
                continue :num buff[idx];
            },
            'a'...'f' => |val| {
                const char: u64 = @as(u64, val - 87);
                out += std.math.pow(u64, @as(u64, 16), bin_idx) * char;
                if (idx == 0) {
                    return out;
                }
                idx -= 1;
                bin_idx += 1;
                continue :num buff[idx];
            },
            else => {
                return errors.InvalidCharacter;
            },
        }
        noreturn;
    }
    pub fn decimal(buff: []u8) !u64 {
        var bin_idx: u64 = 0;
        var idx: usize = buff.len - 1;
        var out: u64 = 0;
        num: switch (buff[idx]) {
            '0'...'9' => |val| {
                const char: u64 = @as(u64, val - '0');
                out += std.math.pow(u64, @as(u64, 10), bin_idx) * char;
                if (idx == 0) {
                    return out;
                }
                idx -= 1;
                bin_idx += 1;
                continue :num buff[idx];
            },
            else => {
                return errors.InvalidCharacter;
            },
        }
        noreturn;
    }
};

pub fn parseInput(buff: []u8) !void {
    var parser = Parser.init(buff);
    val: switch (try parser.next()) {
        '-' => {
            const char = try parser.next();
            const space = try parser.next();
            std.debug.assert(' ' == space);
            switch (char) {
                'b' => {
                    const num: u64 = try NumberConversions.bitToDecimal(parser.readToSpaceOrEnd());
                    return std.debug.print("Decimal: {d}. Hex: 0x{x}\n", .{ num, num });
                },
                'h' => {
                    const num: u64 = try NumberConversions.hex(parser.readToSpaceOrEnd());
                    return std.debug.print("Binary: {b}. Decimal: {d}\n", .{ num, num });
                },
                'd' => {
                    const num: u64 = try NumberConversions.decimal(parser.readToSpaceOrEnd());
                    return std.debug.print("Binary: {b}. Hex: 0x{x}\n", .{ num, num });
                },
                else => return error.InvalidOption,
            }
        },
        ' ' => continue :val try parser.next(),
        else => {
            return;
        },
    }
}

pub fn main() !void {
    var buffer: [4096]u8 = undefined;
    const line = try stdin.readUntilDelimiter(&buffer, '\n');
    try parseInput(line);
}
