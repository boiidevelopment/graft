--[[
--------------------------------------------------

This file is part of GRAFT.
You are free to use these files within your own resources.
Please retain the original credit and attached MIT license.
Support honest development.

Author: Case @ BOII Development
License: MIT (https://github.com/boiidevelopment/graft/blob/main/LICENSE)
GitHub: https://github.com/boiidevelopment/graft

--------------------------------------------------
]]

--- @module maths
--- @description Maths utilities beyond standard Lua math library

--- @section Constants

local EPSILON = 1e-10 -- Epsilon for floating-point comparisons

--- @section Helper Functions

--- Validates that input is a non-empty table of numbers
--- @param numbers table The data to validate
--- @return boolean Valid
local function validate_numbers(numbers)
    if type(numbers) ~= "table" or #numbers == 0 then
        error("Input must be a non-empty table of numbers")
    end
    for i, v in ipairs(numbers) do
        if type(v) ~= "number" then
            error("All elements must be numbers (index " .. i .. " is " .. type(v) .. ")")
        end
    end
    return true
end

--- Validates that input is a non-empty table of points
--- @param points table The data to validate
--- @return boolean Valid
local function validate_points(points)
    if type(points) ~= "table" or #points == 0 then
        error("Input must be a non-empty table of points")
    end
    for i, p in ipairs(points) do
        if type(p) ~= "table" or type(p.x) ~= "number" or type(p.y) ~= "number" then
            error("All points must have x and y number fields (index " .. i .. " invalid)")
        end
    end
    return true
end

--- @section Module

local m = {}

--- @section Core

--- Rounds a number to the specified number of decimal places.
--- @param number number The number to round.
--- @param decimals number The number of decimal places.
--- @return number The rounded number.
function m.round(number, decimals)
    local mult = 10 ^ decimals
    return math.floor(number * mult + 0.5) / mult
end

--- Clamps a value within a specified range.
--- @param val number The value to clamp.
--- @param lower number The lower bound.
--- @param upper number The upper bound.
--- @return number The clamped value.
function m.clamp(val, lower, upper)
    if lower > upper then lower, upper = upper, lower end
    return math.max(lower, math.min(upper, val))
end

--- Linearly interpolates between two values.
--- @param a number The start value.
--- @param b number The end value.
--- @param t number Interpolation factor between 0 and 1.
--- @return number The interpolated value.
function m.lerp(a, b, t)
    return a + (b - a) * t
end

--- Calculates the factorial of a non-negative integer.
--- @param n number The integer to compute factorial for.
--- @return number The factorial of n.
function m.factorial(n)
    if n == 0 then
        return 1
    else
        return n * m.factorial(n - 1)
    end
end

--- Converts degrees to radians.
--- @param deg number Angle in degrees.
--- @return number Angle in radians.
function m.deg_to_rad(deg)
    return deg * (math.pi / 180)
end

--- Converts radians to degrees.
--- @param rad number Angle in radians.
--- @return number Angle in degrees.
function m.rad_to_deg(rad)
    return rad * (180 / math.pi)
end

--- @section Easing

--- Linear easing (no curve).
--- @param t number Current time [0–1]
--- @return number Eased value
function m.linear(t)
    return t
end

--- Quadratic ease-in.
--- @param t number Current time [0–1]
--- @return number Eased value
function m.in_quad(t)
    return t * t
end

--- Quadratic ease-out.
--- @param t number Current time [0–1]
--- @return number Eased value
function m.out_quad(t)
    return t * (2 - t)
end

--- Quadratic ease-in-out.
--- @param t number Current time [0–1]
--- @return number Eased value
function m.in_out_quad(t)
    return (t < 0.5) and (2 * t * t) or (-1 + (4 - 2 * t) * t)
end

--- Cubic ease-in.
--- @param t number Current time [0–1]
--- @return number Eased value
function m.in_cubic(t)
    return t * t * t
end

--- Cubic ease-out.
--- @param t number Current time [0–1]
--- @return number Eased value
function m.out_cubic(t)
    t = t - 1
    return t * t * t + 1
end

--- Cubic ease-in-out.
--- @param t number Current time [0–1]
--- @return number Eased value
function m.in_out_cubic(t)
    return (t < 0.5) and (4 * t * t * t) or ((t - 1) * (2 * t - 2)^2 + 1)
end

--- Elastic ease-out.
--- @param t number Current time [0–1]
--- @return number Eased value
function m.out_elastic(t)
    if math.abs(t) < EPSILON or math.abs(t - 1) < EPSILON then
        return t
    end
    return (math.pow(2, -10 * t) * math.sin((t - 0.075) * (2 * math.pi) / 0.3) + 1)
end

--- @section 2D Geometry

--- Calculates the circumference of a circle.
--- @param radius number The circle radius.
--- @return number The circumference.
function m.circle_circumference(radius)
    return 2 * math.pi * radius
end

--- Calculates the area of a circle.
--- @param radius number The circle radius.
--- @return number The area.
function m.circle_area(radius)
    return math.pi * radius ^ 2
end

--- Calculates the area of a triangle using its 2D vertices.
--- @param p1 table {xnumber,ynumber} First vertex.
--- @param p2 table {xnumber,ynumber} Second vertex.
--- @param p3 table {xnumber,ynumber} Third vertex.
--- @return number The triangle area.
function m.triangle_area(p1, p2, p3)
    return math.abs((p1.x * (p2.y - p3.y) + p2.x * (p3.y - p1.y) + p3.x * (p1.y - p2.y)) / 2)
end

--- Calculates the distance between two 2D points.
--- @param p1 table The first point (x, y).
--- @param p2 table The second point (x, y).
--- @return number The Euclidean distance between the two points.
function m.distance_2d(p1, p2)
    return math.sqrt((p2.x - p1.x)^2 + (p2.y - p1.y)^2)
end

--- Determines if a point is inside a given 2D rectangle boundary.
--- @param point table The point to check (x, y).
--- @param rect table The rectangle (x, y, width, height).
--- @return boolean True if the point is inside the rectangle, false otherwise.
function m.is_point_in_rect(point, rect)
    return point.x >= rect.x and point.x <= (rect.x + rect.width) and point.y >= rect.y and point.y <= (rect.y + rect.height)
end

--- Determines if a point is on a line segment defined by two 2D points.
--- @param point table The point to check (x, y).
--- @param line_start table The starting point of the line segment (x, y).
--- @param line_end table The ending point of the line segment (x, y).
--- @param tolerance number Optional tolerance for floating-point comparison (default: EPSILON).
--- @return boolean True if the point is on the line segment, false otherwise.
function m.is_point_on_line_segment(point, line_start, line_end, tolerance)
    tolerance = tolerance or EPSILON
    local dist_start = m.distance_2d(point, line_start)
    local dist_end = m.distance_2d(point, line_end)
    local segment_length = m.distance_2d(line_start, line_end)
    
    return math.abs(dist_start + dist_end - segment_length) < tolerance
end

--- Projects a point onto a line segment defined by two 2D points.
--- @param p table The point to project (x, y).
--- @param p1 table The starting point of the line segment (x, y).
--- @param p2 table The ending point of the line segment (x, y).
--- @return table The projected point (x, y).
function m.project_point_on_line(p, p1, p2)
    local l2 = (p2.x-p1.x)^2 + (p2.y-p1.y)^2
    local t = ((p.x-p1.x)*(p2.x-p1.x) + (p.y-p1.y)*(p2.y-p1.y)) / l2

    return {x = p1.x + t * (p2.x - p1.x), y = p1.y + t * (p2.y - p1.y)}
end

--- Calculates the slope of a line given two 2D points.
--- @param p1 table The first point (x, y).
--- @param p2 table The second point (x, y).
--- @return number The slope of the line. Returns nil if the slope is undefined (vertical line).
function m.calculate_slope(p1, p2)
    if p2.x - p1.x == 0 then
        return nil
    end

    return (p2.y - p1.y) / (p2.x - p1.x)
end

--- Returns the angle between two 2D points in degrees.
--- @param p1 table The first point (x, y).
--- @param p2 table The second point (x, y).
--- @return number The angle in degrees.
function m.angle_between_points(p1, p2)
    return math.atan2(p2.y - p1.y, p2.x - p1.x) * (180 / math.pi)
end

--- Determines if two circles defined by center and radius intersect.
--- @param c1_center table The center of the first circle (x, y).
--- @param c1_radius number The radius of the first circle.
--- @param c2_center table The center of the second circle (x, y).
--- @param c2_radius number The radius of the second circle.
--- @return boolean True if the circles intersect, false otherwise.
function m.do_circles_intersect(c1_center, c1_radius, c2_center, c2_radius)
    return m.distance_2d(c1_center, c2_center) <= (c1_radius + c2_radius)
end

--- Determines if a point is inside a circle defined by center and radius.
--- @param point table The point to check (x, y).
--- @param circle_center table The center of the circle (x, y).
--- @param circle_radius number The radius of the circle.
--- @return boolean True if the point is inside the circle, false otherwise.
function m.is_point_in_circle(point, circle_center, circle_radius)
    return m.distance_2d(point, circle_center) <= circle_radius
end

--- Determines if two 2D line segments intersect.
--- @param l1_start table The starting point of the first line segment (x, y).
--- @param l1_end table The ending point of the first line segment (x, y).
--- @param l2_start table The starting point of the second line segment (x, y).
--- @param l2_end table The ending point of the second line segment (x, y).
--- @return boolean True if the line segments intersect, false otherwise.
function m.do_lines_intersect(l1_start, l1_end, l2_start, l2_end)
    local function ccw(a, b, c)
        return (c.y-a.y) * (b.x-a.x) > (b.y-a.y) * (c.x-a.x)
    end

    return ccw(l1_start, l2_start, l2_end) ~= ccw(l1_end, l2_start, l2_end) and ccw(l1_start, l1_end, l2_start) ~= ccw(l1_start, l1_end, l2_end)
end

--- Determines if a line segment intersects a circle.
--- @param line_start table Starting point of the line (x, y).
--- @param line_end table Ending point of the line (x, y).
--- @param circle_center table Center of the circle (x, y).
--- @param circle_radius number Radius of the circle.
--- @return boolean True if the line intersects the circle, false otherwise.
function m.line_intersects_circle(line_start, line_end, circle_center, circle_radius)
    local d = {x = line_end.x - line_start.x, y = line_end.y - line_start.y}
    local f = {x = line_start.x - circle_center.x, y = line_start.y - circle_center.y}
    local a = d.x^2 + d.y^2
    local b = 2 * (f.x * d.x + f.y * d.y)
    local c = (f.x^2 + f.y^2) - circle_radius^2
    local discriminant = b^2 - 4 * a * c

    if discriminant >= 0 then
        discriminant = math.sqrt(discriminant)
        local t1 = (-b - discriminant) / (2 * a)
        local t2 = (-b + discriminant) / (2 * a)
        if t1 >= 0 and t1 <= 1 or t2 >= 0 and t2 <= 1 then
            return true
        end
    end

    return false
end

--- Determines if a rectangle intersects with a 2D line segment.
--- @param rect table The rectangle (x, y, width, height).
--- @param line_start table The starting point of the line segment (x, y).
--- @param line_end table The ending point of the line segment (x, y).
--- @return boolean True if the rectangle intersects with the line segment, false otherwise.
function m.does_rect_intersect_line(rect, line_start, line_end)
    if m.is_point_in_rect(line_start, rect) or m.is_point_in_rect(line_end, rect) then
        return true
    end

    return m.do_lines_intersect({x = rect.x, y = rect.y}, {x = rect.x + rect.width, y = rect.y}, line_start, line_end) or 
           m.do_lines_intersect({x = rect.x + rect.width, y = rect.y}, {x = rect.x + rect.width, y = rect.y + rect.height}, line_start, line_end) or 
           m.do_lines_intersect({x = rect.x + rect.width, y = rect.y + rect.height}, {x = rect.x, y = rect.y + rect.height}, line_start, line_end) or 
           m.do_lines_intersect({x = rect.x, y = rect.y + rect.height}, {x = rect.x, y = rect.y}, line_start, line_end)
end

--- Determines the closest point on a 2D line segment to a given point.
--- @param point table The point to find the closest point for (x, y).
--- @param line_start table The starting point of the line segment (x, y).
--- @param line_end table The ending point of the line segment (x, y).
--- @return table The closest point on the line segment (x, y).
function m.closest_point_on_line_segment(point, line_start, line_end)
    local l2 = m.distance_2d(line_start, line_end)^2
    if l2 == 0 then 
        return line_start 
    end
    local t = ((point.x - line_start.x) * (line_end.x - line_start.x) + (point.y - line_start.y) * (line_end.y - line_start.y)) / l2
    if t < 0 then 
        return line_start 
    end
    if t > 1 then 
        return line_end 
    end
    return {x = line_start.x + t * (line_end.x - line_start.x), y = line_start.y + t * (line_end.y - line_start.y)}
end

--- Determines if a point is inside a 2D convex polygon.
--- @param point table The point to check (x, y).
--- @param polygon table The polygon defined as a sequence of points [{x, y}, {x, y}, ...]. Vertices must be ordered consistently (all clockwise or all counter-clockwise).
--- @return boolean True if the point is inside the polygon, false otherwise.
function m.is_point_in_convex_polygon(point, polygon)
    local sign = nil

    for i = 1, #polygon do
        local dx1 = polygon[i].x - point.x
        local dy1 = polygon[i].y - point.y
        local dx2 = polygon[(i % #polygon) + 1].x - point.x
        local dy2 = polygon[(i % #polygon) + 1].y - point.y
        local cross = dx1 * dy2 - dx2 * dy1
        if i == 1 then
            sign = cross > 0
        else
            if sign ~= (cross > 0) then
                return false
            end
        end
    end

    return true
end

--- Rotates a point around another point in 2D by a given angle in degrees.
--- @param point table The point to rotate (x, y).
--- @param pivot table The pivot point to rotate around (x, y).
--- @param angle_degrees number The angle in degrees to rotate the point.
--- @return table The rotated point (x, y).
function m.rotate_point_around_point_2d(point, pivot, angle_degrees)
    local angle_rad = math.rad(angle_degrees)
    local sin_angle = math.sin(angle_rad)
    local cos_angle = math.cos(angle_rad)
    local dx = point.x - pivot.x
    local dy = point.y - pivot.y

    return {x = cos_angle * dx - sin_angle * dy + pivot.x, y = sin_angle * dx + cos_angle * dy + pivot.y}
end

--- @section 3D Geometry

--- Calculates the distance between two 3D points.
--- @param start_coords table {x=number,y=number,z=number} The starting coordinates.
--- @param end_coords table {x=number,y=number,z=number} The ending coordinates.
--- @return number The Euclidean distance between the two points.
function m.calculate_distance(start_coords, end_coords)
    local dx = end_coords.x - start_coords.x
    local dy = end_coords.y - start_coords.y
    local dz = end_coords.z - start_coords.z
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

--- Calculates the distance between two 3D points.
--- @param p1 table The first point (x, y, z).
--- @param p2 table The second point (x, y, z).
--- @return number The Euclidean distance between the two points.
function m.distance_3d(p1, p2)
    return math.sqrt((p2.x - p1.x)^2 + (p2.y - p1.y)^2 + (p2.z - p1.z)^2)
end

--- Returns the midpoint between two 3D points.
--- @param p1 table The first point (x, y, z).
--- @param p2 table The second point (x, y, z).
--- @return table The midpoint (x, y, z).
function m.midpoint(p1, p2)
    return {x = (p1.x + p2.x) / 2, y = (p1.y + p2.y) / 2, z = (p1.z + p2.z) / 2}
end

--- Determines if a point is inside a given 3D box boundary.
--- @param point table The point to check (x, y, z).
--- @param box table The box (x, y, z, width, height, depth).
--- @return boolean True if the point is inside the box, false otherwise.
function m.is_point_in_box(point, box)
    return point.x >= box.x and point.x <= (box.x + box.width) and point.y >= box.y and point.y <= (box.y + box.height) and point.z >= box.z and point.z <= (box.z + box.depth)
end

--- Calculates the angle between three 3D points (p1, p2 as center, p3).
--- @param p1 table The first point (x, y, z).
--- @param p2 table The center point (x, y, z).
--- @param p3 table The third point (x, y, z).
--- @return number The angle in degrees.
function m.angle_between_3_points(p1, p2, p3)
    local a = m.distance_3d(p2, p3)
    local b = m.distance_3d(p1, p3)
    local c = m.distance_3d(p1, p2)

    return math.acos((a*a + c*c - b*b) / (2*a*c)) * (180 / math.pi)
end

--- Calculates the area of a 3D triangle given three points.
--- @param p1 table The first point of the triangle (x, y, z).
--- @param p2 table The second point of the triangle (x, y, z).
--- @param p3 table The third point of the triangle (x, y, z).
--- @return number The area of the triangle.
function m.triangle_area_3d(p1, p2, p3)
    local u = {x = p2.x - p1.x, y = p2.y - p1.y, z = p2.z - p1.z}
    local v = {x = p3.x - p1.x, y = p3.y - p1.y, z = p3.z - p1.z}
    local cross_product = {x = u.y * v.z - u.z * v.y, y = u.z * v.x - u.x * v.z, z = u.x * v.y - u.y * v.x}
    return 0.5 * math.sqrt(cross_product.x^2 + cross_product.y^2 + cross_product.z^2)
end

--- Determines if a point is inside a 3D sphere defined by center and radius.
--- @param point table The point to check (x, y, z).
--- @param sphere_center table The center of the sphere (x, y, z).
--- @param sphere_radius number The radius of the sphere.
--- @return boolean True if the point is inside the sphere, false otherwise.
function m.is_point_in_sphere(point, sphere_center, sphere_radius)
    return m.distance_3d(point, sphere_center) <= sphere_radius
end

--- Determines if two spheres intersect.
--- @param s1_center table The center of the first sphere (x, y, z).
--- @param s1_radius number The radius of the first sphere.
--- @param s2_center table The center of the second sphere (x, y, z).
--- @param s2_radius number The radius of the second sphere.
--- @return boolean True if the spheres intersect, false otherwise.
function m.do_spheres_intersect(s1_center, s1_radius, s2_center, s2_radius)
    return m.distance_3d(s1_center, s2_center) <= (s1_radius + s2_radius)
end

--- Calculates the distance from a point to a plane.
--- @param point table The point to check (x, y, z).
--- @param plane_point table A point on the plane (x, y, z).
--- @param plane_normal table The normal of the plane (x, y, z). Must be a unit vector (normalized).
--- @return number The distance from the point to the plane.
function m.distance_point_to_plane(point, plane_point, plane_normal)
    local v = { x = point.x - plane_point.x, y = point.y - plane_point.y, z = point.z - plane_point.z }
    local dist = v.x * plane_normal.x + v.y * plane_normal.y + v.z * plane_normal.z

    return math.abs(dist)
end

--- Normalizes a 3D vector.
--- @param v table The vector (x, y, z).
--- @return table The normalized vector (x, y, z).
function m.normalize_vector(v)
    local length = math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z)
    if length == 0 then
        return {x = 0, y = 0, z = 0}
    end
    return {x = v.x / length, y = v.y / length, z = v.z / length}
end

--- @section Probability

--- Set the random seed for reproducibility
--- @param seed number Seed value for RNG
function m.set_seed(seed)
    if type(seed) ~= "number" then
        error("Seed must be a number")
    end
    math.randomseed(seed)
end

--- Returns a random float between min and max.
--- @param min number Lower bound.
--- @param max number Upper bound.
--- @param rand_func? function Optional RNG function returning 0.0–1.0 (default math.random).
--- @return number Random float in the range [min, max].
function m.random_between(min, max, rand_func)
    if type(min) ~= "number" or type(max) ~= "number" then
        error("Min and max must be numbers")
    end
    
    if min > max then
        min, max = max, min
    end
    
    rand_func = rand_func or math.random
    return min + rand_func() * (max - min)
end

--- Returns a random integer between min and max (inclusive).
--- @param min number Lower bound.
--- @param max number Upper bound.
--- @param rand_func? function Optional RNG function returning 0.0–1.0.
--- @return number Random integer in the range [min, max].
function m.random_int(min, max, rand_func)
    if type(min) ~= "number" or type(max) ~= "number" then
        error("Min and max must be numbers")
    end
    
    min, max = math.floor(min), math.floor(max)
    
    if min > max then
        min, max = max, min
    end
    
    if min == max then
        return min
    end
    
    rand_func = rand_func or math.random
    return math.floor(rand_func() * (max - min + 1)) + min
end

--- Check if something happens with a given probability (0.0 to 1.0)
--- @param probability number Chance of success (0.0 to 1.0)
--- @param rand_func? function Optional RNG function returning 0.0–1.0
--- @return boolean True if the event occurs
function m.chance(probability, rand_func)
    if type(probability) ~= "number" then
        error("Probability must be a number")
    end
    
    if probability < 0 or probability > 1 then
        error("Probability must be between 0.0 and 1.0")
    end
    
    rand_func = rand_func or math.random
    return rand_func() < probability
end

--- Check if something happens with a given percentage chance (0 to 100)
--- @param percentage number Chance of success (0 to 100)
--- @param rand_func? function Optional RNG function returning 0.0–1.0
--- @return boolean True if the event occurs
function m.percent_chance(percentage, rand_func)
    if type(percentage) ~= "number" then
        error("Percentage must be a number")
    end
    
    if percentage < 0 or percentage > 100 then
        error("Percentage must be between 0 and 100")
    end
    
    return m.chance(percentage / 100, rand_func)
end

--- Select a random element from a table with uniform probability
--- @param tbl table Table to select from
--- @param rand_func? function Optional RNG function returning 0.0–1.0
--- @return any|nil Random element, or nil if table is empty
function m.random_choice(tbl, rand_func)
    if type(tbl) ~= "table" or #tbl == 0 then
        return nil
    end
    
    rand_func = rand_func or math.random
    local index = math.floor(rand_func() * #tbl) + 1
    return tbl[index]
end

--- Selects a random choice from a mapping of options with weights.
--- @param map table Table of weighted options `{ option = weight, ... }`.
--- @param rand_func? function Optional RNG function returning 0.0–1.0.
--- @return any|nil The chosen option key, or nil if all weights <= 0.
function m.weighted_choice(map, rand_func)
    if type(map) ~= "table" then
        error("Map must be a table")
    end
    
    rand_func = rand_func or math.random
    
    local total = 0
    for _, w in pairs(map) do
        if type(w) ~= "number" then
            error("All weights must be numbers")
        end
        if w > 0 then
            total = total + w
        end
    end
    
    if total < EPSILON then
        return nil
    end
    
    local thresh = rand_func() * total
    local cumulative = 0
    
    for key, w in pairs(map) do
        if w > 0 then
            cumulative = cumulative + w
            if thresh < cumulative then
                return key
            end
        end
    end

    for key, w in pairs(map) do
        if w > 0 then
            local last_key = key
            for k, wt in pairs(map) do
                if wt > 0 then
                    last_key = k
                end
            end
            return last_key
        end
    end
    
    return nil
end

--- Shuffle a table in-place using Fisher-Yates algorithm
--- @param tbl table Table to shuffle
--- @param rand_func? function Optional RNG function returning 0.0–1.0
--- @return table The shuffled table (same reference)
function m.shuffle(tbl, rand_func)
    if type(tbl) ~= "table" then
        error("Input must be a table")
    end
    
    rand_func = rand_func or math.random
    
    for i = #tbl, 2, -1 do
        local j = math.floor(rand_func() * i) + 1
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
    
    return tbl
end

--- Generate a random value from a normal (Gaussian) distribution
--- @param mean number Mean of the distribution (default 0)
--- @param stddev number Standard deviation (default 1)
--- @param rand_func? function Optional RNG function returning 0.0–1.0
--- @return number Random value from normal distribution
function m.random_normal(mean, stddev, rand_func)
    mean = mean or 0
    stddev = stddev or 1
    
    if type(mean) ~= "number" or type(stddev) ~= "number" then
        error("Mean and stddev must be numbers")
    end
    
    if stddev <= 0 then
        error("Standard deviation must be positive")
    end
    
    rand_func = rand_func or math.random

    local u1 = rand_func()
    local u2 = rand_func()

    while u1 < EPSILON do
        u1 = rand_func()
    end
    
    local z0 = math.sqrt(-2 * math.log(u1)) * math.cos(2 * math.pi * u2)
    return mean + z0 * stddev
end

--- Generate a random value from an exponential distribution
--- @param lambda number Rate parameter (lambda > 0)
--- @param rand_func? function Optional RNG function returning 0.0–1.0
--- @return number Random value from exponential distribution
function m.random_exponential(lambda, rand_func)
    if type(lambda) ~= "number" or lambda <= 0 then
        error("Lambda must be a positive number")
    end
    
    rand_func = rand_func or math.random
    
    local u = rand_func()
    while u < EPSILON do
        u = rand_func()
    end
    
    return -math.log(u) / lambda
end

--- Generate a random value from a uniform distribution (same as random_between)
--- @param min number Lower bound
--- @param max number Upper bound
--- @param rand_func? function Optional RNG function returning 0.0–1.0
--- @return number Random value from uniform distribution
function m.random_uniform(min, max, rand_func)
    return m.random_between(min, max, rand_func)
end

--- @section Statistics

--- Calculates the mean (average) of a list of numbers.
--- @param numbers table The list of numbers.
--- @return number The mean value.
function m.mean(numbers)
    validate_numbers(numbers)
    local sum = 0
    for _, v in ipairs(numbers) do
        sum = sum + v
    end
    return sum / #numbers
end

--- Calculates the median of a list of numbers.
--- @param numbers table The list of numbers.
--- @return number The median value.
function m.median(numbers)
    validate_numbers(numbers)

    local sorted = {}
    for i, v in ipairs(numbers) do
        sorted[i] = v
    end
    table.sort(sorted)
    
    local n = #sorted
    if n % 2 == 0 then
        return (sorted[n / 2] + sorted[n / 2 + 1]) / 2
    else
        return sorted[math.ceil(n / 2)]
    end
end

--- Calculates the mode (most frequent value) of a list of numbers.
--- @param numbers table The list of numbers.
--- @return number|nil The mode value, or nil if no clear mode exists.
function m.mode(numbers)
    validate_numbers(numbers)
    
    local counts = {}
    for _, v in ipairs(numbers) do
        counts[v] = (counts[v] or 0) + 1
    end
    
    local max_count = 0
    local mode_val = nil
    local mode_count = 0
    
    for v, count in pairs(counts) do
        if count > max_count then
            max_count = count
            mode_val = v
            mode_count = 1
        elseif count == max_count then
            mode_count = mode_count + 1
        end
    end

    if mode_count > 1 then
        return nil
    end
    
    return mode_val
end

--- Calculates the variance of a list of numbers.
--- @param numbers table The list of numbers.
--- @param population boolean If true, use population variance; if false (default), use sample variance.
--- @return number The variance.
function m.variance(numbers, population)
    validate_numbers(numbers)
    
    local mean_val = m.mean(numbers)
    local sum = 0
    
    for _, v in ipairs(numbers) do
        sum = sum + (v - mean_val) ^ 2
    end
    
    local divisor = population and #numbers or (#numbers - 1)
    if divisor == 0 then
        return 0
    end
    
    return sum / divisor
end

--- Calculates the standard deviation of a list of numbers.
--- @param numbers table The list of numbers.
--- @param population boolean If true, use population stddev; if false (default), use sample stddev.
--- @return number The standard deviation.
function m.standard_deviation(numbers, population)
    validate_numbers(numbers)
    return math.sqrt(m.variance(numbers, population))
end

--- Calculates the range (max - min) of a list of numbers.
--- @param numbers table The list of numbers.
--- @return number The range.
function m.range(numbers)
    validate_numbers(numbers)
    local min, max = numbers[1], numbers[1]
    for i = 2, #numbers do
        if numbers[i] < min then
            min = numbers[i]
        elseif numbers[i] > max then
            max = numbers[i]
        end
    end
    return max - min
end

--- Calculates the minimum value in a list of numbers.
--- @param numbers table The list of numbers.
--- @return number The minimum value.
function m.min(numbers)
    validate_numbers(numbers)
    local min_val = numbers[1]
    for i = 2, #numbers do
        if numbers[i] < min_val then
            min_val = numbers[i]
        end
    end
    return min_val
end

--- Calculates the maximum value in a list of numbers.
--- @param numbers table The list of numbers.
--- @return number The maximum value.
function m.max(numbers)
    validate_numbers(numbers)
    local max_val = numbers[1]
    for i = 2, #numbers do
        if numbers[i] > max_val then
            max_val = numbers[i]
        end
    end
    return max_val
end

--- Calculates the sum of a list of numbers.
--- @param numbers table The list of numbers.
--- @return number The sum.
function m.sum(numbers)
    validate_numbers(numbers)
    local sum = 0
    for _, v in ipairs(numbers) do
        sum = sum + v
    end
    return sum
end

--- Calculates the quantile (percentile) of a list of numbers.
--- @param numbers table The list of numbers.
--- @param q number The quantile (0.0 to 1.0, where 0.5 is the median).
--- @return number The quantile value.
function m.quantile(numbers, q)
    validate_numbers(numbers)
    
    if type(q) ~= "number" or q < 0 or q > 1 then
        error("Quantile must be a number between 0.0 and 1.0")
    end
    
    local sorted = {}
    for i, v in ipairs(numbers) do
        sorted[i] = v
    end
    table.sort(sorted)
    
    local n = #sorted
    local index = q * (n - 1) + 1
    local lower_idx = math.floor(index)
    local upper_idx = math.ceil(index)
    
    if lower_idx == upper_idx then
        return sorted[lower_idx]
    end
    
    local fraction = index - lower_idx
    return sorted[lower_idx] * (1 - fraction) + sorted[upper_idx] * fraction
end

--- Performs linear regression on a list of 2D points.
--- @param points table The list of points with {x=number, y=number}.
--- @return table Result with {slope=number, intercept=number, r_squared=number}.
function m.linear_regression(points)
    validate_points(points)
    
    local n = #points
    local sum_x, sum_y, sum_xx, sum_xy, sum_yy = 0, 0, 0, 0, 0
    
    for _, p in ipairs(points) do
        sum_x = sum_x + p.x
        sum_y = sum_y + p.y
        sum_xx = sum_xx + p.x * p.x
        sum_xy = sum_xy + p.x * p.y
        sum_yy = sum_yy + p.y * p.y
    end
    
    local denominator = n * sum_xx - sum_x * sum_x
    
    if math.abs(denominator) < EPSILON then
        error("Cannot perform linear regression: points are collinear or insufficient variance")
    end
    
    local slope = (n * sum_xy - sum_x * sum_y) / denominator
    local intercept = (sum_y - slope * sum_x) / n

    local numerator = (n * sum_xy - sum_x * sum_y) ^ 2
    local r_squared = numerator / (denominator * (n * sum_yy - sum_y * sum_y))
    
    return {
        slope = slope,
        intercept = intercept,
        r_squared = math.max(0, math.min(1, r_squared))
    }
end

--- Calculates the correlation coefficient between two datasets.
--- @param x table The first dataset.
--- @param y table The second dataset.
--- @return number The Pearson correlation coefficient (-1 to 1).
function m.correlation(x, y)
    if type(x) ~= "table" or type(y) ~= "table" or #x ~= #y or #x == 0 then
        error("Both inputs must be non-empty tables of equal length")
    end
    
    for i, v in ipairs(x) do
        if type(v) ~= "number" or type(y[i]) ~= "number" then
            error("All elements must be numbers")
        end
    end
    
    local mean_x = m.mean(x)
    local mean_y = m.mean(y)
    local cov = 0
    local var_x = 0
    local var_y = 0
    
    for i = 1, #x do
        local dx = x[i] - mean_x
        local dy = y[i] - mean_y
        cov = cov + dx * dy
        var_x = var_x + dx * dx
        var_y = var_y + dy * dy
    end
    
    if math.abs(var_x) < EPSILON or math.abs(var_y) < EPSILON then
        return 0
    end
    
    return cov / math.sqrt(var_x * var_y)
end

--- Calculates the covariance between two datasets.
--- @param x table The first dataset.
--- @param y table The second dataset.
--- @param population boolean If true, use population covariance; if false (default), use sample covariance.
--- @return number The covariance.
function m.covariance(x, y, population)
    if type(x) ~= "table" or type(y) ~= "table" or #x ~= #y or #x == 0 then
        error("Both inputs must be non-empty tables of equal length")
    end
    
    for i, v in ipairs(x) do
        if type(v) ~= "number" or type(y[i]) ~= "number" then
            error("All elements must be numbers")
        end
    end
    
    local mean_x = m.mean(x)
    local mean_y = m.mean(y)
    local sum = 0
    
    for i = 1, #x do
        sum = sum + (x[i] - mean_x) * (y[i] - mean_y)
    end
    
    local divisor = population and #x or (#x - 1)
    if divisor == 0 then
        return 0
    end
    
    return sum / divisor
end

return m