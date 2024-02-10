//------------------------------------------------------------------------------
//  math.zig
//
//  minimal vector math helper functions, just the stuff needed for
//  the sokol-samples
//
//  Ported from HandmadeMath.h
//------------------------------------------------------------------------------
const math = @import("std").math;

fn radians(deg: f32) f32 {
    return deg * (math.pi / 180.0);
}

pub const Vec2 = extern struct {
    x: f32,
    y: f32,

    pub fn zero() Vec2 {
        return Vec2{ .x = 0.0, .y = 0.0 };
    }

    pub fn new(x: f32, y: f32) Vec2 {
        return Vec2{ .x = x, .y = y };
    }

    pub fn equal(a: Vec2, b: Vec2) bool {
        return math.approxEqAbs(f32, a.x, b.x, 0.0001) and math.approxEqAbs(f32, a.y, b.y, 0.0001);
    }
};

pub const Vec4 = extern struct {
    x: f32,
    y: f32,
    z: f32,
    w: f32,

    pub fn zero() Vec4 {
        return Vec4{ .x = 0.0, .y = 0.0, .z = 0.0, .w = 0.0 };
    }

    pub fn new(x: f32, y: f32, z: f32, w: f32) Vec4 {
        return Vec3{ .x = x, .y = y, .z = z, .w = w };
    }

    pub fn apply_mat4(v: Vec4, m: Mat4) Vec4 {
        const x = m.m[0] * v.x + m.m[1] * v.y + m.m[2] * v.z + m.m[3] * v.w;
        const y = m.m[4] * v.x + m.m[5] * v.y + m.m[6] * v.z + m.m[7] * v.w;
        const z = m.m[8] * v.x + m.m[9] * v.y + m.m[10] * v.z + m.m[11] * v.w;
        const w = m.m[12] * v.x + m.m[13] * v.y + m.m[14] * v.z + m.m[15] * v.w;
        return Vec4.new(x, y, z, w);
    }

    pub fn scale(v: Vec4, s: f32) Vec4 {
        return Vec4.new(v.x * s, v.y * s, v.z * s, v.w * s);
    }

    pub fn add(a: Vec4, b: Vec4) Vec4 {
        return Vec4.new(a.x + b.x, a.y + b.y, a.z + b.z, a.w + b.w);
    }

    pub fn sub(a: Vec4, b: Vec4) Vec4 {
        return Vec4.new(a.x - b.x, a.y - b.y, a.z - b.z, a.w - b.w);
    }

    pub fn normalize(v: Vec4) Vec4 {
        const l: f32 = math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z + v.q * v.w);
        if (l != 0) {
            v.x /= l;
            v.y /= l;
            v.z /= l;
            v.w /= l;
        }
        return v;
    }
};

pub const Vec3 = extern struct {
    x: f32,
    y: f32,
    z: f32,

    pub fn zero() Vec3 {
        return Vec3{ .x = 0.0, .y = 0.0, .z = 0.0 };
    }

    pub fn new(x: f32, y: f32, z: f32) Vec3 {
        return Vec3{ .x = x, .y = y, .z = z };
    }

    pub fn up() Vec3 {
        return Vec3{ .x = 0.0, .y = 1.0, .z = 0.0 };
    }

    pub fn len(v: Vec3) f32 {
        return math.sqrt(Vec3.dot(v, v));
    }

    pub fn add(left: Vec3, right: Vec3) Vec3 {
        return Vec3{ .x = left.x + right.x, .y = left.y + right.y, .z = left.z + right.z };
    }

    pub fn sub(left: Vec3, right: Vec3) Vec3 {
        return Vec3{ .x = left.x - right.x, .y = left.y - right.y, .z = left.z - right.z };
    }

    pub fn mul(v: Vec3, s: f32) Vec3 {
        return Vec3{ .x = v.x * s, .y = v.y * s, .z = v.z * s };
    }

    pub fn norm(v: Vec3) Vec3 {
        const l = Vec3.len(v);
        if (l != 0.0) {
            return Vec3{ .x = v.x / l, .y = v.y / l, .z = v.z / l };
        } else {
            return Vec3.zero();
        }
    }

    pub fn cross(v0: Vec3, v1: Vec3) Vec3 {
        return Vec3{ .x = (v0.y * v1.z) - (v0.z * v1.y), .y = (v0.z * v1.x) - (v0.x * v1.z), .z = (v0.x * v1.y) - (v0.y * v1.x) };
    }

    pub fn dot(v0: Vec3, v1: Vec3) f32 {
        return v0.x * v1.x + v0.y * v1.y + v0.z * v1.z;
    }
};

pub const Mat4 = extern struct {
    m: [4][4]f32,

    pub fn identity() Mat4 {
        return Mat4{
            .m = [_][4]f32{ .{ 1.0, 0.0, 0.0, 0.0 }, .{ 0.0, 1.0, 0.0, 0.0 }, .{ 0.0, 0.0, 1.0, 0.0 }, .{ 0.0, 0.0, 0.0, 1.0 } },
        };
    }

    pub fn zero() Mat4 {
        return Mat4{
            .m = [_][4]f32{ .{ 0.0, 0.0, 0.0, 0.0 }, .{ 0.0, 0.0, 0.0, 0.0 }, .{ 0.0, 0.0, 0.0, 0.0 }, .{ 0.0, 0.0, 0.0, 0.0 } },
        };
    }

    pub fn mul(left: Mat4, right: Mat4) Mat4 {
        var res = Mat4.zero();
        var col: usize = 0;
        while (col < 4) : (col += 1) {
            var row: usize = 0;
            while (row < 4) : (row += 1) {
                res.m[col][row] = left.m[0][row] * right.m[col][0] +
                    left.m[1][row] * right.m[col][1] +
                    left.m[2][row] * right.m[col][2] +
                    left.m[3][row] * right.m[col][3];
            }
        }
        return res;
    }

    pub fn persp(fov: f32, aspect: f32, near: f32, far: f32) Mat4 {
        var res = Mat4.identity();
        const t = math.tan(fov * (math.pi / 360.0));
        res.m[0][0] = 1.0 / t;
        res.m[1][1] = aspect / t;
        res.m[2][3] = -1.0;
        res.m[2][2] = (near + far) / (near - far);
        res.m[3][2] = (2.0 * near * far) / (near - far);
        res.m[3][3] = 0.0;
        return res;
    }

    pub fn ortho(left: f32, right: f32, bottom: f32, top: f32, near: f32, far: f32) Mat4 {
        var res = Mat4.zero();
        res.m[0][0] = 2.0 / (right - left);
        res.m[1][1] = 2.0 / (top - bottom);
        res.m[2][2] = 2.0 / (near - far);
        res.m[3][3] = 1.0;

        res.m[3][0] = (left + right) / (left - right);
        res.m[3][1] = (bottom + top) / (bottom - top);
        res.m[3][2] = (near + far) / (near - far);

        return res;
    }

    pub fn lookat(eye: Vec3, center: Vec3, up: Vec3) Mat4 {
        var res = Mat4.zero();

        const f = Vec3.norm(Vec3.sub(center, eye));
        const s = Vec3.norm(Vec3.cross(f, up));
        const u = Vec3.cross(s, f);

        res.m[0][0] = s.x;
        res.m[0][1] = u.x;
        res.m[0][2] = -f.x;

        res.m[1][0] = s.y;
        res.m[1][1] = u.y;
        res.m[1][2] = -f.y;

        res.m[2][0] = s.z;
        res.m[2][1] = u.z;
        res.m[2][2] = -f.z;

        res.m[3][0] = -Vec3.dot(s, eye);
        res.m[3][1] = -Vec3.dot(u, eye);
        res.m[3][2] = Vec3.dot(f, eye);
        res.m[3][3] = 1.0;

        return res;
    }

    pub fn rotate(angle: f32, axis_unorm: Vec3) Mat4 {
        var res = Mat4.identity();

        const axis = Vec3.norm(axis_unorm);
        const sin_theta = math.sin(radians(angle));
        const cos_theta = math.cos(radians(angle));
        const cos_value = 1.0 - cos_theta;

        res.m[0][0] = (axis.x * axis.x * cos_value) + cos_theta;
        res.m[0][1] = (axis.x * axis.y * cos_value) + (axis.z * sin_theta);
        res.m[0][2] = (axis.x * axis.z * cos_value) - (axis.y * sin_theta);
        res.m[1][0] = (axis.y * axis.x * cos_value) - (axis.z * sin_theta);
        res.m[1][1] = (axis.y * axis.y * cos_value) + cos_theta;
        res.m[1][2] = (axis.y * axis.z * cos_value) + (axis.x * sin_theta);
        res.m[2][0] = (axis.z * axis.x * cos_value) + (axis.y * sin_theta);
        res.m[2][1] = (axis.z * axis.y * cos_value) - (axis.x * sin_theta);
        res.m[2][2] = (axis.z * axis.z * cos_value) + cos_theta;

        return res;
    }

    pub fn direction(dir_norm: Vec3, axis_norm: Vec3) Mat4 {
        var res = Mat4.identity();

        var xaxis: Vec3 = axis_norm.cross(dir_norm);
        xaxis = xaxis.norm();

        var yaxis: Vec3 = dir_norm.cross(xaxis);
        yaxis = yaxis.norm();

        res.m[0][0] = xaxis.x;
        res.m[0][1] = yaxis.x;
        res.m[0][2] = dir_norm.x;
        res.m[1][0] = xaxis.y;
        res.m[1][1] = yaxis.y;
        res.m[1][2] = dir_norm.y;
        res.m[2][0] = xaxis.z;
        res.m[2][1] = yaxis.z;
        res.m[2][2] = dir_norm.z;

        return res.transpose();
    }

    pub fn translate(translation: Vec3) Mat4 {
        var res = Mat4.identity();
        res.m[3][0] = translation.x;
        res.m[3][1] = translation.y;
        res.m[3][2] = translation.z;
        return res;
    }

    pub fn inverse(m: Mat4) Mat4 {
        const a = *m.m;
        const det =
            a[0] * a[5] * a[10] * a[15] +
            a[0] * a[6] * a[11] * a[13] +
            a[0] * a[7] * a[9] * a[14] +
            a[1] * a[4] * a[11] * a[14] +
            a[1] * a[6] * a[8] * a[15] +
            a[1] * a[7] * a[10] * a[12] +
            a[2] * a[4] * a[9] * a[15] +
            a[2] * a[5] * a[11] * a[12] +
            a[2] * a[7] * a[8] * a[13] +
            a[3] * a[4] * a[10] * a[13] +
            a[3] * a[5] * a[8] * a[14] +
            a[3] * a[6] * a[9] * a[12] -
            a[0] * a[5] * a[11] * a[14] -
            a[0] * a[6] * a[9] * a[15] -
            a[0] * a[7] * a[10] * a[13] -
            a[1] * a[4] * a[10] * a[15] -
            a[1] * a[6] * a[11] * a[12] -
            a[1] * a[7] * a[8] * a[14] -
            a[2] * a[4] * a[11] * a[13] -
            a[2] * a[5] * a[8] * a[15] -
            a[2] * a[7] * a[9] * a[12] -
            a[3] * a[4] * a[9] * a[14] -
            a[3] * a[5] * a[10] * a[12] -
            a[3] * a[6] * a[8] * a[13];

        if (det == 0) {
            return Mat4.identity();
        }

        const a0 = a[5] * a[10] * a[15] + a[6] * a[11] * a[13] + a[7] * a[9] * a[14] - a[5] * a[11] * a[14] - a[6] * a[9] * a[15] - a[7] * a[10] * a[13];
        const a1 = a[1] * a[11] * a[14] + a[2] * a[9] * a[15] + a[3] * a[10] * a[13] - a[1] * a[10] * a[15] - a[2] * a[11] * a[13] - a[3] * a[9] * a[14];
        const a2 = a[1] * a[6] * a[15] + a[2] * a[7] * a[13] + a[3] * a[5] * a[14] - a[1] * a[7] * a[14] - a[2] * a[5] * a[15] - a[3] * a[6] * a[13];
        const a3 = a[1] * a[7] * a[10] + a[2] * a[5] * a[11] + a[3] * a[6] * a[9] - a[1] * a[6] * a[11] - a[2] * a[7] * a[9] - a[3] * a[5] * a[10];
        const a4 = a[4] * a[11] * a[14] + a[6] * a[8] * a[15] + a[7] * a[10] * a[12] - a[4] * a[10] * a[15] - a[6] * a[11] * a[12] - a[7] * a[8] * a[14];
        const a5 = a[0] * a[10] * a[15] + a[2] * a[11] * a[12] + a[3] * a[8] * a[14] - a[0] * a[11] * a[14] - a[2] * a[8] * a[15] - a[3] * a[10] * a[12];
        const a6 = a[0] * a[7] * a[14] + a[2] * a[4] * a[15] + a[3] * a[6] * a[12] - a[0] * a[6] * a[15] - a[2] * a[7] * a[12] - a[3] * a[4] * a[14];
        const a7 = a[0] * a[6] * a[11] + a[2] * a[7] * a[8] + a[3] * a[4] * a[10] - a[0] * a[7] * a[10] - a[2] * a[4] * a[11] - a[3] * a[6] * a[8];
        const a8 = a[4] * a[9] * a[15] + a[5] * a[11] * a[12] + a[7] * a[8] * a[13] - a[4] * a[11] * a[13] - a[5] * a[8] * a[15] - a[7] * a[9] * a[12];
        const a9 = a[0] * a[11] * a[13] + a[1] * a[8] * a[15] + a[3] * a[9] * a[12] - a[0] * a[9] * a[15] - a[1] * a[11] * a[12] - a[3] * a[8] * a[13];
        const a10 = a[0] * a[5] * a[15] + a[1] * a[7] * a[12] + a[3] * a[4] * a[13] - a[0] * a[7] * a[13] - a[1] * a[4] * a[15] - a[3] * a[5] * a[12];
        const a11 = a[0] * a[7] * a[9] + a[1] * a[4] * a[11] + a[3] * a[5] * a[8] - a[0] * a[5] * a[11] - a[1] * a[7] * a[8] - a[3] * a[4] * a[9];
        const a12 = a[4] * a[10] * a[13] + a[5] * a[8] * a[14] + a[6] * a[9] * a[12] - a[4] * a[9] * a[14] - a[5] * a[10] * a[12] - a[6] * a[8] * a[13];
        const a13 = a[0] * a[9] * a[14] + a[1] * a[10] * a[12] + a[2] * a[8] * a[13] - a[0] * a[10] * a[13] - a[1] * a[8] * a[14] - a[2] * a[9] * a[12];
        const a14 = a[0] * a[6] * a[13] + a[1] * a[4] * a[14] + a[2] * a[5] * a[12] - a[0] * a[5] * a[14] - a[1] * a[6] * a[12] - a[2] * a[4] * a[13];
        const a15 = a[0] * a[5] * a[10] + a[1] * a[6] * a[8] + a[2] * a[4] * a[9] - a[0] * a[6] * a[9] - a[1] * a[4] * a[10] - a[2] * a[5] * a[8];

        return Mat4{
            .m = [_][4]f32{ .{
                a0 / det,
                a1 / det,
                a2 / det,
                a3 / det,
            }, .{
                a4 / det,
                a5 / det,
                a6 / det,
                a7 / det,
            }, .{
                a8 / det,
                a9 / det,
                a10 / det,
                a11 / det,
            }, .{
                a12 / det,
                a13 / det,
                a14 / det,
                a15 / det,
            } },
        };
    }
};
