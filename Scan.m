classdef(Sealed) Scan
    %Scan Implements methods to read LIDAR sensor messages.
    %   'getX' methods retrieve target information X from input parameter 
    %   'msg'. This is a sensor_msgs/Scan structure, returned
    %   for example by Turtlebot3B.getScan method.
    %   Messages are composed by:
    %   - Sensor's rotation extremes, i.e. start and end angles of scan;
    %   - Rotation and time increment between measurements;
    %   - Time between scans;
    %   - Range data: distance measured for each increment, maximum and
    %       minimum range values;
    %   - (if available) Intensity measured for each increment.
    %   Time is expressed in [seconds], angles in [rad], distances in [m].

    methods(Access = private)
        function obj = Scan()
        end
    end

    methods(Static)

        function [min_range, max_range] = getExtremeValues(msg)
            %getExtremeValues Extract minimum and maximum measured 
            %distances from a /scan message.
            %   Distances are measured in [m].
            min_range = msg.RangeMin; max_range = msg.RangeMax;
        end

        function [frame, angles, times, ranges] = getScanData(msg)
            %getScanData Extract detected points from a scan message and
            %return them in polar coordinates.
            %   All outputs, except frame, are column vectors of the same
            %   size: 360 elements.
            %   Times are in [seconds], angles in [rad], distances in [m].
            %   Values of time starts from zero, so are relative to 
            %   current measurements.

            %frame
            frame = msg.Header.FrameId;

            %angles
            angles = (msg.AngleMin:msg.AngleIncrement:msg.AngleMax)';

            %times
            times = (1:numel(angles))'.*msg.TimeIncrement;

            %ranges
            ranges = reshape(msg.Ranges, numel(angles), 1);
        end

        function [frame, angles, times, ranges] = getValidScanData(msg)
            %getValidScanData Extract detected points from a scan message 
            %discarding out of bounds measurements. Points are returned in
            %polar coordinates.
            %   Return LIDAR measurements ignoring angles, times and ranges 
            %   entries where range value is not between minimum and 
            %   maximum distances specified by scan message. 
            %   Returns only "valuable" data.
            [r_min ,r_max] = Scan.getExtremeValues(msg);
            [frame, a, t, r] = Scan.getScanData(msg);

            angles = zeros(size(a));
            times = zeros(size(a));
            ranges = zeros(size(a));

            ven = 0; %ven -> valuable entry number
            for i=1:numel(r)
                if r(i) >= r_min && r(i) <= r_max
                    ven = ven+1;
                    angles(ven) = a(i);
                    times(ven) = t(i);
                    ranges(ven) = r(i);
                end
            end

            angles = angles(1:ven);
            times = times(1:ven);
            ranges = ranges(1:ven);
        end

        function [frame, angles, times, ranges] = getValidScanDataEnlarged(msg, radius)
            %getValidScanDataEnlarged Extract detected points from a scan 
            %message discarding out of bounds measurements and reducing 
            %observed distances of 'radius'. Points are returned in
            %polar coordinates.
            [r_min ,r_max] = Scan.getExtremeValues(msg);
            [frame, a, t, r] = Scan.getScanData(msg);

            angles = zeros(size(a));
            times = zeros(size(a));
            ranges = zeros(size(a));

            ven = 0; %ven -> valuable entry number
            for i=1:numel(r)
                if r(i) >= r_min && r(i) <= r_max
                    ven = ven+1;
                    angles(ven) = a(i);
                    times(ven) = t(i);
                    if r(i) - radius < 0.1
                        ranges(ven) = 0;
                    else
                        ranges(ven) = r(i) - radius;
                    end
                end
            end

            angles = angles(1:ven);
            times = times(1:ven);
            ranges = ranges(1:ven);
        end

        function [frame, times, x, y] = getCartesianScanData(msg)
            %getCartesianScanData Extract detected points from a scan 
            %message and return them in cartesian coordinates.
            %   Return LIDAR measurements only for valid points, where 
            %   range value is between minimum and maximum distances 
            %   specified by scan message. 
            %   Times are in [seconds], distances in [m].
            %   Values of time starts from zero, so are relative to 
            %   current measurements.
            [frame, angles, times, ranges] = Scan.getValidScanData(msg);
            [x, y] = pol2cart(angles, ranges); 
        end

        function [frame, times, x, y] = getCartesianScanEnlargingObstacles(msg, radius)
            %getCartesianScanEnlargingObstacles Extract detected points 
            %from a scan message and return them in cartesian coordinates,
            %reducing observed distances of 'radius'.
            [frame, angles, times, ranges] = Scan.getValidScanData(msg);
            for i=1:numel(ranges)
                if ranges(i) - radius < 0.1
                    ranges(i) = 0;
                else
                    ranges(i) = ranges(i) - radius;
                end
            end
            [x, y] = pol2cart(angles, ranges); 
        end

    end
end