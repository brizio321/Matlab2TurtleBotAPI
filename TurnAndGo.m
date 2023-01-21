classdef TurnAndGo < TurtlebotImpl
    %TurnAndGo Move Turtlebot forward until new obstacle is detected. 
    % Turn left 45° and check if new direction is free from obstacles.
    % Continue turning left untile a free direction is found. A direction
    % theta is defined "free" when the range [theta-30°; theta+30°] does
    % not contains obstacles at a distance shorter than 0.15[m].

    properties
        global_time
        start_time

        tb_x
        tb_y

        obstacles_dir %direction
        obstacles_dis %distance
        free_from_obstacles = false;

        ax
    end

    methods

        function obj = TurnAndGo(options)
            obj = obj@TurtlebotImpl(options);
            figure;
            obj.ax = axes;
        end

    end

    methods

        function obj = startConnection(obj, ipaddress)
            obj = startConnection@TurtlebotImpl(obj, ipaddress);
            obj.global_time = tic;
            obj.start_time = tic;
        end

        function obj = closeConnection(obj)
            CommandVelocity.stop(obj);
            obj = closeConnection@TurtlebotImpl(obj);
        end
        
        function check = loop(obj)
            check = toc(obj.global_time) < 45; %seconds
        end %loop

        function obj = sense(obj)
            %Acquire Odometry and LIDAR data.
            [~, pose, ~] = Odometry.getPoseEstimation( obj.read('odom') );
            obj.tb_x = pose(1);
            obj.tb_y = pose(2);

            [~, obj.obstacles_dir, ~, obj.obstacles_dis] = ...
                Scan.getValidScanDataEnlarged( obj.read('scan'), obj.model.tbot_circumscribing_radius );
        end %sense

        function obj = process(obj)
            %Check whether or not the Turtlebot has front direction free
            %from obstacles.

            %If it's actually turning because of detected obstacle, keep
            %turning.
            if ~obj.free_from_obstacles
                return;
            end

            %If it's moving forward or just turned left of 45°, check for
            %obstacles.
            obj.free_from_obstacles = true;
            for i=1:numel(obj.obstacles_dir)
                if obj.obstacles_dis(i) <= obj.model.tbot_circumscribing_radius && ...
                        (obj.obstacles_dir(i) >= deg2rad(330) || ...
                        obj.obstacles_dir(i) <= deg2rad(30) )
                    obj.free_from_obstacles = false;

                    %Obstacle detected: start timer to perform turning left
                    %trajectory.
                    obj.start_time = tic;
                    break;
                end
            end
        end %process

        function obj = control(obj)
            %Keep moving if forward direction is free from obstacles.
            if obj.free_from_obstacles
                v = 0.05; w = 0;
            else
                [v, w] = turn45Left( toc(obj.start_time) );
                if abs(v) > 0
                   obj.free_from_obstacles = true;
                   v = 0; w = 0;
                end
            end

            obj.setLinearAngularSpeed( v, w );
        end %control

        function obj = visualize(obj)
            cla(obj.ax);
            [x, y] = pol2cart( obj.obstacles_dir, obj.obstacles_dis );
            x = x + obj.tb_x;
            y = y + obj.tb_y;

            plot( obj.ax, obj.tb_x, obj.tb_y, '*g', x, y, '.b' );
        end %visualize

    end

end

function [v, w] = turn45Left(delta_t)
    if delta_t < (pi/4) / 0.25
        v = 0; w = 0.25;
    else
        v = 0.05; w = 0;
    end
end