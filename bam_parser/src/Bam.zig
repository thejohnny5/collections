const std = @import("std");
const Self = @This();

pub const magic = [4]u8{ 'B', 'A', 'M', 1 };
const EOF_MARKER = [28]u8{ "1f", "8b", "08", "04", "00", "00", "00", "00", "00", "ff", "06", "00", "42", "43", "02", "00", "1b", "00", "03", "00", "00", "00", "00", "00", "00", "00", "00", "00" };
pub const Header = struct {
    l_text: u32, // Length of header text, including any NUL padding
    text: []u8, // Plain header text in SAM; not necessarily NUL terminated
    n_ref: u32, // # reference sequences
};

pub const Reference = struct {
    l_name: u32, // Length of reference name plus 1
    name: [*:0]u8, // Reference sequence name; NUL-terminated
    l_ref: u32, // Length of Reference sequence
};

pub const Alignment = struct {
    block_size: u32, // Total length of alignment record
    ref_id: i32,
    pos: i32,
    l_read_name: u8,
    mapq: u8,
    bin: u16,
    n_cigar_op: u16,
    flag: u16,
    l_seq: u32,
    next_ref_id: i32,
    next_pos: i32,
    tlen: i32,
    read_name: [*:0]u8, // Read name, NUL-terminated (QNAME with trailing \0)
    cigar: []u32, // op_len << 4|op, 'MIDNSHPP=X'-> '012345678' u32[n_cigar_op]
    seq: []u8, // [(l_seq+1)/2]u8
    qual: []u8, // [l_seq]u8
};

const AuxData = struct {
    tag: [2]u8,
    val_type: u8,
    value: Value,
    const Value = union(enum) {
        A: [4]u8,
        c: i8,
        C: u8,
        s: i16,
        S: u16,
        i: i32,
        I: u32,
        f: f32,
        Z: [:0]u8,
        H: [:0]u8,
        B: struct {
            count: u32,
            subtype: SubType,
        },
    };

    const SubType = union(enum) {
        c: []i8,
        C: []u8,
        s: []i16,
        S: []u16,
        i: []i32,
        I: []u32,
        f: []f32,
    };
};
