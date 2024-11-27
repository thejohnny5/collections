const std = @import("std");
const httpz = @import("httpz");

var server: httpz.ServerCtx(void, void) = undefined;
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    server = try httpz.Server().init(allocator, .{ .port = 5882 });
    defer server.deinit();

    std.posix.sigaction(std.posix.SIG.INT, &.{ .handler = .{ .handler = shutdown }, .mask = std.posix.empty_sigset, .flags = 0 }, null);

    var router = server.router();
    router.get("/api/user/:id", getUser);

    std.debug.print("Server listening on port 5882", .{});
    try server.listen();
}

fn getUser(req: *httpz.Request, res: *httpz.Response) !void {
    try res.json(.{ .id = req.param("id").?, .name = "Teg" }, .{});
}

fn shutdown(_: c_int) callconv(.C) void {
    server.stop();
}
