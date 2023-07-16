/*
3D Course Miniature

Use a GPX file from a run or bike ride to generate a 3D printable miniature figurine of the course.
See the README for complete instructions.

Mike Kasberg
*/

// The activity title. Max X chars.
title = "Century *100*";

// Bold fonts print best (especially at small sizes)
// Make sure these fonts are installed
font = "Roboto:style=bold";

// Font size (mm height)
font_size = 3.5;

// Percentage of the route to render. Useful for out & back routes where you might only render ~50%
out_back = 100;

// Rotate the map this many degrees from North.
map_rotation = 0;

// Elevation data. Length should match distance data.
elevation_values = [1720.8,1710.8,1697.8,1688.6,1701.6,1706.2,1695,1708.4,1663.8,1643.2,1635.4,1630.4,1621.6,1615,1606.6,1612.8,1626,1637.8,1673.8,1677.8,1677.8,1676.6,1676,1676.2,1675.8,1676.8,1677.4,1675.6,1674.4,1672.8,1674.8,1677.2,1669.4,1676,1675.2,1674.4,1666.8,1664,1651.8,1645.8,1636.8,1626.6,1623,1611,1601.6,1594.2,1598.4,1605,1626.6,1654,1666.6,1694.4,1703.8,1724.2,1731.6,1733.2,1720.2,1707.2,1688.6,1668.6,1644,1629.2,1613.4,1608.2,1603.6,1600.6,1601.2,1599,1593.2,1593.4,1588,1598.4,1608.2,1613,1617.4,1623.2,1631.6,1634.8,1644.2,1655.6,1662.8,1666.6,1679.2,1689.8,1707.4,1722.6,1753,1765,1762.8,1811.6,1824,1850.4,1894,1879,1848.8,1869,1870,1852.8,1785.6,1741.2];
//elevation_values = [10, 8, 1, 9];

// Lat/Lng Data. As [[lat, lng], ...]. Length should match elevation data. Used for Map polyline.
lat_lng_values = [[39.697617,-105.114367],[39.707925,-105.109325],[39.710864,-105.090804],[39.702874,-105.081766],[39.696743,-105.084336],[39.69672,-105.084323],[39.696607,-105.101603],[39.696551,-105.109824],[39.682102,-105.100284],[39.664776,-105.095238],[39.665081,-105.081653],[39.655418,-105.060867],[39.653035,-105.041319],[39.65172,-105.023027],[39.65023,-105.010298],[39.631711,-105.014171],[39.624404,-105.000207],[39.620549,-104.988403],[39.614992,-104.980698],[39.61782,-104.976218],[39.612654,-104.956054],[39.607029,-104.938771],[39.620769,-104.945875],[39.617083,-104.930792],[39.626368,-104.939147],[39.634235,-104.931316],[39.641142,-104.934008],[39.64574,-104.944436],[39.653966,-104.940405],[39.660134,-104.927182],[39.667744,-104.920932],[39.67202,-104.915579],[39.667024,-104.910402],[39.665375,-104.906386],[39.665488,-104.90634],[39.662945,-104.903277],[39.677324,-104.906979],[39.665157,-104.885798],[39.671156,-104.890801],[39.677683,-104.895694],[39.690709,-104.912812],[39.704824,-104.933883],[39.715606,-104.955392],[39.719961,-104.977794],[39.736866,-104.996192],[39.753354,-105.007923],[39.743621,-105.016497],[39.735341,-105.027454],[39.734178,-105.039862],[39.734887,-105.060998],[39.73303,-105.080351],[39.732853,-105.100298],[39.723924,-105.109573],[39.712287,-105.10945],[39.701752,-105.109932],[39.700287,-105.112046],[39.707805,-105.109373],[39.723776,-105.109473],[39.732893,-105.100351],[39.733018,-105.076205],[39.734899,-105.058526],[39.733904,-105.038458],[39.738026,-105.02169],[39.74868,-105.015869],[39.760812,-105.00326],[39.765925,-104.988914],[39.778347,-104.978331],[39.793513,-104.966335],[39.807444,-104.959491],[39.822743,-104.950157],[39.827979,-104.950684],[39.823603,-104.972366],[39.820359,-104.992269],[39.814708,-105.008221],[39.811384,-105.015254],[39.802112,-105.030044],[39.796494,-105.044195],[39.791209,-105.06037],[39.785736,-105.074031],[39.780581,-105.091472],[39.774528,-105.10267],[39.771611,-105.110842],[39.77504,-105.1126],[39.77444,-105.126187],[39.772551,-105.149305],[39.772871,-105.16899],[39.769178,-105.19297],[39.766285,-105.209956],[39.757146,-105.21958],[39.750857,-105.230602],[39.743192,-105.221308],[39.731522,-105.210985],[39.725248,-105.198814],[39.713542,-105.1977],[39.699643,-105.194658],[39.686825,-105.18621],[39.681691,-105.173868],[39.683388,-105.158657],[39.696747,-105.145313],[39.696574,-105.126556]];
//lat_lng_values = [[0, 0], [1,1], [1,2], [0,3]];

// Total output width (mm)
width = 50;

// The depth of the text plate (mm)
plate_depth = 10;

// Base thickness (mm)
thickness = 5;

// Text thickness (mm)
text_thickness = 2;

// Margins (around map) (mm)
margin = 2.5;

// Max height of the polyline
max_polyline_height = 20;

// END Params.
// Everything below here is generation code.

function half_angle_difference(a2, a1) =
  abs(a2 - a1) < 180 ? (a2 - a1) / 2 :
  abs(a2 - a1 - 360) < 180 ? (a2 - a1 - 360) / 2 :
  (a2 - a1 + 360) / 2;


/**
 * Generates a map polyline using lat/lng and elevation.
 */
module map_polyline(scaled_points, elevation) {
  max_idx = round(out_back / 100 * len(scaled_points) - 1);

  elevation_min = min(elevation);
  elevation_diff = max(elevation) - elevation_min;
  map_polyline_height = min([max_polyline_height, elevation_diff / 10]); // Looks bad if stretched too far vertically.
  echo("Map Height", map_polyline_height);
  scaled_elevation = [ for (e = elevation) (e - elevation_min) * 0.95 * map_polyline_height / elevation_diff + 0.05 * map_polyline_height ];


  // for (i = [1 : 1]) {
  for (i = [0 : max_idx - 1]) {
    p0 = scaled_points[i];
    p1 = scaled_points[i+1];
    h0 = scaled_elevation[i];
    h1 = scaled_elevation[i+1];
    dx = p1.x - p0.x;
    dy = p1.y - p0.y;

    dx_prev = i > 0 ? p0.x - scaled_points[i - 1].x : 0;
    dy_prev = i > 0 ? p0.y - scaled_points[i - 1].y : 0;
    dx_next = i < max_idx - 1 ? scaled_points[i + 2].x - p1.x : 0;
    dy_next = i < max_idx - 1 ? scaled_points[i + 2].y - p1.y : 0;

    edge_width = 1;
    edge_len = sqrt(pow(dx, 2) + pow(dy, 2)) + 0.01;
    
    angle = atan2(dy, dx);
    angle_prev = atan2(dy_prev, dx_prev);
    angle_next = atan2(dy_next, dx_next);

    // Make a "cube" with a slanted top, oriented along the x-axis toward (1, 0).
    // https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Primitive_Solids#polyhedron
    cube_points = [
      [0, -edge_width/2, 0],         //0
      [edge_len, -edge_width/2, 0],  //1
      [edge_len, edge_width/2, 0],   //2
      [0, edge_width/2, 0],          //3
      [0, -edge_width/2, h0],        //4
      [edge_len, -edge_width/2, h1], //5
      [edge_len, edge_width/2, h1],  //6
      [0, edge_width/2, h0]          //7
    ];
    cube_faces = [
      [0, 1, 2, 3],  // bottom
      [4, 5, 1, 0],  // front
      [7, 6, 5, 4],  // top
      [5, 6, 2, 1],  // right
      [6, 7, 3, 2],  // back
      [7, 4, 0, 3]   // left
    ];

    translate([p0.x, p0.y, 0]) {
      // An edge of the correct length pointing in the correct diretion.
      // 0 rotation points in the direction of (1, 0).
      //rotate([0, 0, angle]) translate([0, -edge_width / 2, 0]) cube([edge_len, edge_width, 10]);
      rotate([0, 0, angle]) {
        difference() {
          polyhedron(cube_points, cube_faces);

          if (i < max_idx - 1) {
            // Remove intersection with next edge
            translate([edge_len, 0, 0]) rotate([0, 0, half_angle_difference(angle_next, angle)]) translate([0, -2*edge_width, -1]) cube([edge_width, 4*edge_width, map_polyline_height + 2]);
          }

          if (i > 0) {
            // Remove intersection with previous edge
            rotate([0, 0, 180 - half_angle_difference(angle, angle_prev)]) translate([0, -2*edge_width, -1]) cube([edge_width, 4*edge_width, map_polyline_height + 2]);
          }
        } 
      }
      

      difference() {
        cylinder(h=h0, r=edge_width/2, $fn=12);

        // Remove intersection with current edge
        rotate([0, 0, angle]) translate([0.001, -(edge_width + 2) / 2, -0.001]) cube([edge_width, edge_width + 2, map_polyline_height + 0.002]);

        if (i > 0) {
          // Remove intersection with previous edge
          rotate([0, 0, 180 + angle_prev]) translate([0.001, -(edge_width + 2) / 2, -0.001]) cube([edge_width, edge_width + 2, map_polyline_height + 0.002]);
        }
      }
    }

    // Final cylinder
    if (i == max_idx - 1) {
      translate([p1.x, p1.y, 0]) {
        difference() {
        cylinder(h=h1, r=edge_width/2, $fn=12);

        // Remove intersection with edge
        rotate([0, 0, 180+angle]) translate([0.001, -(edge_width + 2) / 2, -0.001]) cube([edge_width, edge_width + 2, map_polyline_height + 0.002]);
        }
      }
    }
  }
}


/**
 * The "text plate" is a 3D rectangular plaque below the map.
 */
module text_plate() {
  angle = atan(thickness / plate_depth);
  intersection() {
    rotate([angle, 0, 0]) translate([0, 0, -thickness]) cube([width, plate_depth * 2, thickness]);
    cube([width, plate_depth, thickness]);
  }
  rotate([angle, 0, 0]) translate([0, 0, -thickness]) {
    // Center Aligned Title
    translate([width / 2, 3.5, thickness - 0.001]) {
      color("orange") linear_extrude(text_thickness / 2) {
        text(title, size = font_size, font = font, halign = "center");
      }
    }
  }
}


// Combine all the parts
translate([0, plate_depth - 0.001, 0]) cube([width, width, thickness]);
text_plate();

max_size = width - 2*margin;
// lat/lng is swapped x/y
points = [ for (p = lat_lng_values) [p.y, p.x] ];

points_x = [ for (p = points) p.x ];
points_y = [ for (p = points) p.y ];
points_x_min = min(points_x);
points_y_min = min(points_y);

points_width = max(points_x) - points_x_min;
points_height = max(points_y) - points_y_min;

map_width = points_width > points_height ? max_size : points_width / points_height * max_size;
map_height = points_width > points_height ? points_height / points_width * max_size : max_size;
scale = map_width / points_width;

scaled_points = [ for (p = points) [(p.x - points_x_min) * scale, (p.y - points_y_min) * scale] ];

// We're using the "outer photo dimensions" as our map area
x_pos = margin;
y_pos = plate_depth + margin;
translate([x_pos + (width - 2*margin)/2, y_pos + (width - 2*margin)/2, thickness - 0.001]) color("orange") rotate([0, 0, map_rotation]) translate([-map_width/2, -map_height/2, 0]) map_polyline(scaled_points, elevation_values);
