classdef ConfigureOptions
    %ConfigureOptions Create option parameter for Turtlebot Implementation
    %hierarchy. Initialize an empty configuration and enable
    %publishers/subscribers just for topic you're interested in.

    properties(GetAccess = private, SetAccess = private)
        pub
        sub
    end

    methods
        function obj = ConfigureOptions()
            %PubSubSelector Construct an empty set of options.
            obj.pub = [];
            obj.sub = [];
        end

        function obj = enableMotorPower(obj)
            %enableMotorPower Add /motor_power to desired publishers.
            obj.pub = [obj.pub, "motor_power"];
        end

        function obj = enableCmdVel(obj)
            %enableCmdVel Add /cmd_vel to desired publishers.
            obj.pub = [obj.pub, "cmd_vel"];
        end

        function obj = enableReset(obj)
            %enableReset Add /reset to desired publishers.
            obj.pub = [obj.pub, "reset"];
        end

        function obj = enableBatteryState(obj)
            %enableBatteryState Add /battery_state to desired subscribers.
            obj.sub = [obj.sub, "battery_state"];
        end

        function obj = enableTransformations(obj)
            %enableTransformations Add /tf to desired subscribers.
            obj.sub = [obj.sub, "tf"];
        end

        function obj = enableOdom(obj)
            %enableOdom Add /odom to desired subscribers.
            obj.sub = [obj.sub, "odom"];
        end

        function obj = enableImu(obj)
            %enableImu Add /imu to desired subscribers.
            obj.sub = [obj.sub, "imu"];
        end

        function obj = enableScan(obj)
            %enableScan Add /scan to desired subscribers.
            obj.sub = [obj.sub, "scan"];
        end

        function obj = enableMagneticField(obj)
            %enableMagneticField Add /magnetic_field to desired subscribers.
            obj.sub = [obj.sub, "magnetic_field"];
        end

        function obj = enableJointStates(obj)
            %enableJointStates Add /joint_states to desired subscribers.
            obj.sub = [obj.sub, "joint_states"];
        end

        function obj = enableDiagnostics(obj)
            %enableDiagnostics Add /diagnostics to desired subscribers.
            obj.sub = [obj.sub, "diagnostics"];
        end

        function options = getOptions(obj)
            %getOptions Generate options list to be passed to TurtlebotImpl
            %constructor.
            options = horzcat(obj.pub, obj.sub);
        end
    end
end