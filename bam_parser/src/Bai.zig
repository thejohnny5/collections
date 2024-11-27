const std = @import("std");
const Self = @This();
const magic = [4]u8{ 'B', 'A', 'I', 1 };

n_ref: u32,
n_no_coor: u64,

const BinIndex = struct {
    n_bin: u32,
    n_intv: u32,
};
const DistinctBin = struct {
    bin: u32,
    n_chunk: u32,
};

const Chunks = struct {
    chunk_beg: u64,
    chunk_end: u64,
};
