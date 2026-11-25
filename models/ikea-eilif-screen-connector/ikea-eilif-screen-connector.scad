// --- 사용자 설정값 (단위: mm) ---
gap = 15;            
plate_thick = 2;     
web_thick = 2;       
width = 40;          
flat_length = 80;    
end_flat_w = 10;     
$fn = 80;            

// --- 리지(볼록한 부분) 상세 설정 ---
ridge_visible_h = 1.0; 
ridge_diam = ridge_visible_h * 2; 
edge_offset = 4.0;     
ridge_extra_len = 10;  

module eilif_connector_v24_silver() {
    end_cap_len = (width - end_flat_w) / 2; 
    total_len = flat_length + (end_cap_len * 2);
    
    custom_plate(flat_length, width, end_flat_w, end_cap_len, plate_thick);
    
    translate([0, 0, gap + plate_thick])
        custom_plate(flat_length, width, end_flat_w, end_cap_len, plate_thick);
    
    translate([0, (width/2) - (web_thick/2), plate_thick])
        cube([total_len, web_thick, gap]);
    
    ridge_len = flat_length + ridge_extra_len;
    x_ridge_start = (total_len - ridge_len) / 2;
    ridge_y_pos = [edge_offset, width - edge_offset];
    
    for (y = ridge_y_pos) {
        translate([x_ridge_start, y, plate_thick])
            rounded_ridge_capsule(ridge_len, ridge_diam);
        
        translate([x_ridge_start, y, plate_thick + gap])
            rounded_ridge_capsule(ridge_len, ridge_diam);
    }
}

module custom_plate(L, W, EF, ECL, T) {
    hull() {
        translate([ECL, 0, 0]) cube([L, W, T]);
        translate([ECL, ECL, 0]) cylinder(r=ECL, h=T);
        translate([ECL, W-ECL, 0]) cylinder(r=ECL, h=T);
        translate([0, (W-EF)/2, 0]) cube([0.1, EF, T]); 
        translate([L+ECL, ECL, 0]) cylinder(r=ECL, h=T);
        translate([L+ECL, W-ECL, 0]) cylinder(r=ECL, h=T);
        translate([L+ECL*2, (W-EF)/2, 0]) cube([0.1, EF, T]); 
    }
}

module rounded_ridge_capsule(L, D) {
    rotate([0, 90, 0])
    hull() {
        sphere(d=D);
        translate([0, 0, L]) sphere(d=D);
    }
}

eilif_connector_v24_silver();