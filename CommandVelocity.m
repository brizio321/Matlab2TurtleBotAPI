classdef(Sealed) CommandVelocity
    %CommandVelocity Implements methods to set turtlebot's speed.
    %   Speed-setter methods requires a Turtlebot3B object to communicate
    %   over ROS network and publish messages in /cmd_vel topic.

    methods(Access = private)
        function obj = CommandVelocity()
        end
    end

    methods(Static)

        function [v, w] = toLinearAngularForm(wr, wl)
            %toLinearAngularForm Convert right and left wheel speeds to
            %linear and angular speeds.
            speed = Turtlebot3B.diff2uni*[ wr; wl ];
            v = speed(1); w = speed(2);
        end

        function [wr, wl] = toDifferentialDriveForm(v, w)
            %toDifferentialDriveForm Convert linear and angular speeds to 
            %right and left wheel speeds.
            w = Turtlebot3B.uni2diff*[ v; w ];
            wr = w(1); wl = w(2);
        end

        function setDDSpeed(tbot, wr, wl)
            %setDDSpeed Use Differential Drive Model to set speed.
            %   Input parameters 'wr' and 'wl' must be expressed in
            %   [rad/s]; converted in Linear and Angular form, these must
            %   not be greater than 0.22 [m/s] and 2.84 [rad/s].
            %   Turtlebot3B publishing methods automatically saturate
            %   excessive speeds.
            mustBeA(tbot, 'TurtlebotImpl')
            [v, w] = CommandVelocity.toLinearAngularForm(wr, wl);
            publishCmdVel(tbot, v, w);
        end

        function setSpeed(tbot, v, w)
            %setSpeed Apply Linear and Angular speeds to turtlebot.
            %   Linear and Angular speeds must not be greater than 
            %   0.22 [m/s] and 2.84 [rad/s].
            %   Turtlebot3B publishing methods automatically saturate
            %   excessive speeds.
            mustBeA(tbot, 'TurtlebotImpl')
            publishCmdVel(tbot, v, w);
        end

        function stop(tbot)
            %stop Stop turtlebot setting Linear and Angular speeds both 
            %equals to zero.
            publishCmdVel(tbot, 0, 0);
        end

    end
end