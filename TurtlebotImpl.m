classdef (Abstract) TurtlebotImpl
    %TurtlebotImpl Implement all communication methods from Matlab to ROS
    %network and vice-versa. Also provide a blueprint to users interested 
    %in programming new actions for the Turtlebot.

    properties(GetAccess = private, SetAccess = private)
        options
        publisher
        subscriber
    end

    properties(GetAccess = protected, SetAccess = private)
        model
    end

    %Init
    methods(Sealed, Access = private)

        function obj = initPublisher(obj)
            %initPublisher Creates publishers specified in options
            %property.
            if any((obj.options == "cmd_vel"))
                obj.publisher.CmdVel = ...
                    rospublisher('/cmd_vel', 'DataFormat', 'struct');
            end

            if any((obj.options == "motor_power"))
                obj.publisher.MotorPower = ...
                    rospublisher('/motor_power', 'DataFormat', 'struct');
            end

            if any((obj.options == "reset"))
                obj.publisher.Reset = ...
                    rospublisher('/cmd_vel', 'DataFormat', 'struct');
            end
        end

        function obj = initSubscriber(obj)
            %initSubscriber Creates subscribers specified in options 
            %property.
            if any((obj.options == "battery_state"))
                obj.subscriber.BatteryState = ...
                    rossubscriber('/battery_state', 'DataFormat', 'struct');
            end

            if any((obj.options == "tf"))
                obj.subscriber.Transformations = ...
                    rossubscriber('/tf', 'DataFormat', 'struct');
            end

            if any((obj.options == "imu"))
                obj.subscriber.Imu = ...
                    rossubscriber('/imu', 'DataFormat', 'struct');
            end

            if any((obj.options == "odom"))
                obj.subscriber.Odom = ...
                    rossubscriber('/odom', 'DataFormat', 'struct');
            end

            if any((obj.options == "scan"))
                obj.subscriber.Scan = ...
                    rossubscriber('/scan', 'DataFormat', 'struct');
            end

            if any((obj.options == "magnetic_field"))
                obj.subscriber.MagneticField = ...
                    rossubscriber('/magnetic_field', 'DataFormat', 'struct');
            end

            if any((obj.options == "joint_states"))
                obj.subscriber.JointStates = ...
                    rossubscriber('/joint_states', 'DataFormat', 'struct');
            end

            if any((obj.options == "diagnostics"))
                obj.subscriber.Diagnostics = ...
                    rossubscriber('/diagnostics', 'DataFormat', 'struct');
            end
        end

    end

    % Publish methods
    methods(Sealed)

        function publishCmdVel(obj, v, w)
            %publishCmdVel Publish a new geometry_msgs/Twist in /cmd_vel
            %topic.
            %   Input parameter 'v' is used as Linear Speed in X-direction,
            %   'w' as Angular Speed along Z-direction.
            %   Specify a LINEAR speed NOT GREATER THAN 
            %       obj.model.maximum_translational_velocity [m/s]
            %   and an ANGULAR speed NOT GREATER THAN 
            %       obj.model.maximum_rotational_velocity [rad/s].
            %   If values exceed the limits, they will be saturated to the
            %   maximum.
            if ~isfield(obj.publisher, 'CmdVel')
                error("Publihser not created for this topic.")
            end

            if abs(v) > obj.model.maximum_translational_velocity
                v = sign(v)*obj.model.maximum_translational_velocity;
            end
            if abs(w) > obj.model.maximum_rotational_velocity
                w = sign(w)*obj.model.maximum_rotational_velocity;
            end
            msg = rosmessage(obj.publisher.CmdVel);
            msg.Linear.X = v;
            msg.Angular.Z = w;
            send( obj.publisher.CmdVel, msg );
        end

        function motorPowerOn(obj)
            %motorPowerOn Switch on Turtlebot's motors.
            if ~isfield(obj.publisher, 'MotorPower')
                error("Publihser not created for this topic.")
            end

            try
                msg = rosmessage(obj.publisher.MotorPower);
                msg.Data = true;
                send(obj.publisher.MotorPower, msg)
            catch
                obj = obj.startConnection();
                msg = rosmessage(obj.publisher.MotorPower);
                msg.Data = true;
                send(obj.publisher.MotorPower, msg)
                obj.closeConnection();
            end
        end

        function motorPowerOff(obj)
            %motorPowerOff Switch off Turtlebot's motors.
            if ~isfield(obj.publisher, 'MotorPower')
                error("Publihser not created for this topic.")
            end

            try
                msg = rosmessage(obj.publisher.MotorPower);
                msg.Data = false;
                send(obj.publisher.MotorPower, msg)
            catch
                obj = obj.startConnection();
                msg = rosmessage(obj.publisher.MotorPower);
                msg.Data = false;
                send(obj.publisher.MotorPower, msg)
                obj.closeConnection();
            end
        end

        function reset(obj)
            %reset Reset Odometry and IMU data.
            if ~isfield(obj.publisher, 'Reset')
                error("Publihser not created for this topic.")
            end

            try
                msg = rosmessage(obj.publisher.Reset);
                send(obj.publisher.Reset, msg)
                disp("Resetting odometry...")
            catch
                obj = obj.startConnection();
                msg = rosmessage(obj.publisher.Reset);
                send(obj.publisher.Reset, msg)
                disp("Resetting odometry...")
                obj.closeConnection();
            end
        end

    end

    %Subscribe methods
    methods(Sealed)

        function msg = read(obj, topic, varargin)
            %read Wait for the next published message in indicated topic.
            %Eventually, specify a waiting timeout as last parameter.
            if ~any((obj.options == topic))
                error("Subscriber not created for this topic.")
            end

            switch topic
                case 'battery_state'
                    sub = obj.subscriber.BatteryState;
                case 'imu'
                    sub = obj.subscriber.Imu;
                case 'odom'
                    sub = obj.subscriber.Odom;
                case 'scan'
                    sub = obj.subscriber.Scan;
                case 'tf'
                    sub = obj.subscriber.Transformations;
                case 'magnetic_field'
                    sub = obj.subscriber.MagneticField;
                case 'joint_state'
                    sub = obj.subscriber.JointStates;
                otherwise
                    sub = obj.subscriber.Diagnostics;
            end

            if nargin > 2
                time = varargin{1};
                [msg, ~, statustext] = ...
                    receive(sub, time);
            else
                [msg, ~, statustext] = ...
                    receive(sub);
            end
            
            if strcmp(statustext, 'success') == 0
                msg = statustext;
            end
        end

    end

    %Connection methods
    methods
        
        function obj = startConnection(obj, ipaddress)
            %startConnection Initialize Matlab Global Node attempting
            %connection to provided ipaddress. Normally, this methods is
            %invoked by a Turtlebot3 concrete object which already know
            %Turtlebot's ip address.
            %This methods also creates publishers and subscribers used to 
            %communicate on ROS network.
            rosinit(ipaddress, 11311)
            obj = obj.initPublisher();
            obj = obj.initSubscriber();
        end

        function obj = closeConnection(obj)
            %closeConnection Disconnect Global Node from ROS network,
            %deleting publishers and subscribers.
            rosshutdown
        end

    end

    %Step methods
    methods(Abstract)
        loop
        sense
        process
        control
        visualize
    end

    methods

        function obj = TurtlebotImpl(options)
            %TurtlebotImpl Store options to init publishers and
            %subscribers.
            mustBeA(options, 'string');
            obj.options = options;
        end

        function obj = setModel(obj, tbot)
            %setModel Set used Turtlebot3 model.
            mustBeA(tbot, 'Turtlebot3');
            obj.model = tbot;
        end

    end

end