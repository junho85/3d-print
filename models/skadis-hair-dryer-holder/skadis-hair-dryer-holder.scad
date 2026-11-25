// IKEA SKÅDIS 타공판용 헤어드라이어 거치대
//
// 단위는 mm. 좌표는 X 좌우, Y 앞뒤, Z 위아래.
// 뒤판 앞면이 y=0, 앞쪽이 -y, 타공판 쪽이 +y, 바닥이 z=0.
// OpenSCAD 기본 정면 뷰에서 +x가 오른쪽이다.

/* [뒤판] */
plate_w = 60;          // 너비
plate_h = 80;          // 높이
plate_t = 5;           // 두께
plate_corner_r = 3;    // 모서리 둥글기

/* [SKÅDIS 걸이] */
hook_spacing = 40;     // 두 걸이의 중심 간격
hook_w = 4.8;          // 걸이 너비 (타공 슬롯 너비 5mm에 들어가는 치수)
hook_depth = 4.8;      // 뒤판 뒷면과 걸림턱 사이 틈 (타공판이 끼는 자리)
hook_tab_len = 10;     // 걸림턱 길이 (걸이 윗면에서 아래로)
hook_tab_t = 3;        // 걸림턱 두께
hook_neck_h = 4.8;     // 타공판을 통과하는 목의 높이
hook_top_z = 70;       // 걸이 윗면 높이

/* [드라이어 링] */
ring_id = 80;          // 안지름
ring_wall = 8;         // 벽 두께
ring_h = 20;           // 높이
ring_gap = 35;         // 앞쪽 트임 (가장 좁은 곳 기준)
ring_fillet = 2;       // 모서리 둥글기

/* [코드 걸이] */
cord_hook_w = 15;      // 너비 (뒤판 오른쪽 옆면에서 바깥으로)
cord_hook_depth = 20;  // 깊이 (뒤판 앞면에서 앞으로)
cord_hook_t = 4;       // 살 두께
cord_hook_r = 4;       // 안쪽 바닥 둥글기
cord_hook_tip_h = 12;  // 앞쪽 턱 높이
cord_hook_stem_h = 25; // 뒤판에 붙는 기둥 높이
cord_hook_z = 45;      // 걸이 바닥 높이

/* [출력 방향] */
// upright: 사용할 때 자세 그대로 (링과 뒤판 바닥이 베드에 닿음)
// back: 뒷면이 아래, side: 왼쪽 옆면이 아래
print_orientation = "upright"; // [upright, back, side]

/* [곡면 정밀도] */
$fa = 2;
$fs = 0.4;

// --- 계산값 ---
ring_ir = ring_id / 2;
ring_or = ring_ir + ring_wall;
ring_cy = ring_or;     // 링 중심까지 거리 (링 바깥면이 뒤판 앞면에 닿는다)
// 끝 둥글기까지 포함해 가장 좁은 곳이 ring_gap이 되는 트임 반각
gap_half_angle = asin((ring_gap / 2 + ring_fillet) / (ring_ir + ring_fillet));
eps = 0.01;

assert(hook_tab_len > hook_neck_h, "걸림턱이 목보다 길어야 걸린다");
assert(cord_hook_z >= ring_h, "코드 걸이가 링과 겹친다");
assert(cord_hook_z + cord_hook_stem_h <= plate_h - plate_corner_r, "코드 걸이 기둥이 뒤판 위로 넘어간다");

// --- 부품 (앞쪽을 +y로 놓고 만든 뒤 맨 끝에서 뒤집는다) ---

module plate_outline() {
    translate([-plate_w / 2 + plate_corner_r, plate_corner_r])
        offset(r = plate_corner_r)
            square([plate_w - 2 * plate_corner_r, plate_h - 2 * plate_corner_r]);
}

// 2D (x, z) 도형을 y 방향으로 y0부터 y1까지 세운다
module stand_xz(y0, y1) {
    translate([0, y1, 0]) rotate([90, 0, 0]) linear_extrude(y1 - y0) children();
}

module backplate() {
    stand_xz(-plate_t, 0) plate_outline();
}

module skadis_hook(cx) {
    y_back = -plate_t - hook_depth - hook_tab_t;
    // 목: 뒤판 속으로 0.5mm 겹쳐서 한 덩어리가 되게 한다
    translate([cx - hook_w / 2, y_back, hook_top_z - hook_neck_h])
        cube([hook_w, hook_depth + hook_tab_t + 0.5, hook_neck_h]);
    // 걸림턱
    translate([cx - hook_w / 2, y_back, hook_top_z - hook_tab_len])
        cube([hook_w, hook_tab_t, hook_tab_len]);
}

module ring_profile() {
    translate([ring_ir + ring_fillet, ring_fillet])
        offset(r = ring_fillet)
            square([ring_wall - 2 * ring_fillet, ring_h - 2 * ring_fillet]);
}

// 트임 양 끝을 둥글게 막는 마개
module ring_end_cap(angle) {
    rotate([0, 0, angle]) hull() {
        for (r = [ring_ir + ring_fillet, ring_or - ring_fillet])
            for (z = [ring_fillet, ring_h - ring_fillet])
                translate([r, 0, z]) sphere(r = ring_fillet);
    }
}

module dryer_ring() {
    translate([0, ring_cy, 0]) {
        rotate([0, 0, 90 + gap_half_angle])
            rotate_extrude(angle = 360 - 2 * gap_half_angle) ring_profile();
        ring_end_cap(90 + gap_half_angle);
        ring_end_cap(90 - gap_half_angle);
    }
}

// 뒤판과 링 사이를 꽉 채우는 이음부. 뒤판 윤곽을 그대로 앞으로 잇는다.
module ring_bridge() {
    difference() {
        intersection() {
            stand_xz(-plate_t / 2, ring_cy) plate_outline();
            translate([-plate_w / 2, -plate_t, 0]) cube([plate_w, ring_cy + plate_t, ring_h]);
        }
        translate([0, ring_cy, -1]) cylinder(r = ring_ir + ring_wall / 2, h = ring_h + 2);
    }
}

// (y, z) 단면. y=0이 뒤판 앞면
module cord_hook_profile() {
    d = cord_hook_depth;
    t = cord_hook_t;
    ri = cord_hook_r;
    ro = ri + t;
    slot_w = d - t;
    difference() {
        hull() {
            translate([-plate_t, 0]) square([plate_t, cord_hook_tip_h]);
            translate([d - ro, ro]) circle(r = ro);
            translate([d - t / 2, cord_hook_tip_h - t / 2]) circle(d = t);
        }
        hull() {
            translate([ri, t + ri]) circle(r = ri);
            translate([slot_w - ri, t + ri]) circle(r = ri);
            translate([0, t + ri]) square([slot_w, cord_hook_tip_h]);
        }
    }
    translate([-plate_t, 0]) square([plate_t, cord_hook_stem_h]);
}

module cord_hook() {
    translate([plate_w / 2, 0, cord_hook_z]) {
        rotate([90, 0, 90]) linear_extrude(cord_hook_w) cord_hook_profile();
        // 기둥을 뒤판 속으로 1mm 겹친다
        translate([-1, -plate_t, 0]) cube([1 + eps, plate_t, cord_hook_stem_h]);
    }
}

module holder() {
    // 앞쪽을 -y로 뒤집는다. 정면에서 봤을 때 코드 걸이가 오른쪽에 온다.
    mirror([0, 1, 0]) union() {
        backplate();
        for (s = [-1, 1]) skadis_hook(s * hook_spacing / 2);
        dryer_ring();
        ring_bridge();
        cord_hook();
    }
}

if (print_orientation == "back") {
    translate([0, 0, plate_t + hook_depth + hook_tab_t]) rotate([-90, 0, 0]) holder();
} else if (print_orientation == "side") {
    translate([0, 0, ring_or]) rotate([0, -90, 0]) holder();
} else {
    holder();
}
