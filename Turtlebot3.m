classdef (Abstract) Turtlebot3
    %Turtlebot3 Describe Turtlebot3 as Matlab object. From Matlab point of
    %view, a Turtlebot3 is just a host in the network performing an action
    %at a fixed rate. 
    %Hence, a Turtlebot3 is described by its ip address, the rate at which
    %the action is performed and the action performed itself.
    %Turtlebot3 is an abstract class concretized by subclasses TBBurger and
    %TBWafflePi. Each of this enhance abstract class with model-specific
    %properties.

    properties(GetAccess = protected, SetAccess = protected)
        ipaddress
        loop_rate

        implementation
    end

    methods

        function obj = Turtlebot3(ipaddress, loop_rate, implementation)
            %Turtlebot3 Initialize Turtlebot3 properties.
            %   Specify Turtlebot IP Address as input parameter. Port 11311
            %   is automatically used to create Matlab global node.
            %   Loop Rate is intended to be an integeer, as rate is
            %   described in Hz (not Time Period).
            %   The provided implementation must be a concrete subclass of
            %   TurtlebotImpl.
            mustBeA(implementation, 'TurtlebotImpl');
            mustBeInteger(loop_rate);
            mustBePositive(loop_rate);

            obj.ipaddress = ipaddress;
            obj.loop_rate = loop_rate;
            obj.implementation = implementation;
        end

    end

    methods(Sealed, Access = public)

        function obj = perform(obj)
            %Perform Perform method invokes every step of control loop. 
            %Each step is provided by implementation properties. Overall
            %there are seven steps, see TurtlebotImpl doc/comments for
            %more.
            obj.implementation = obj.implementation.startConnection(obj.ipaddress);
            while obj.implementation.loop
                obj.implementation = obj.implementation.sense;
                obj.implementation = obj.implementation.process;
                obj.implementation = obj.implementation.control;
                obj.implementation = obj.implementation.visualize;
                waitfor(rosrate( obj.loop_rate ));
            end
            obj.implementation = obj.implementation.closeConnection();
        end

    end

    % Publish methods
    methods(Sealed)

        function publishCmdVel(obj, v, w)
            %publishCmdVel Set Turtlebot speed.
            %   Input parameter 'v' is used as Linear Speed in X-direction,
            %   'w' as Angular Speed along Z-direction.
            %   Specify Linear and Angular speeds NOT GREATER THAN MODEL
            %   LIMITS. Model-specific subclasses state speed limits.
            %   If values exceed the limits, they will be saturated to the
            %   maximum.
            obj.implementation.publishCmdVel(v, w);
        end

        function motorPowerOn(obj)
            %motorPowerOn Switch on Turtlebot's motors.
            try
                obj.implementation.motorPowerOn();
            catch
                obj.implementation = obj.implementation.startConnection(obj.ipaddress);
                obj.implementation.motorPowerOn();
                obj.implementation.closeConnection();
            end
        end

        function motorPowerOff(obj)
            %motorPowerOff Switch off Turtlebot's motors.
            try
                obj.implementation.motorPowerOff();
            catch
                obj.implementation = obj.implementation.startConnection(obj.ipaddress);
                obj.implementation.motorPowerOff();
                obj.implementation.closeConnection();
            end
        end

        function reset(obj)
            %reset Reset Odometry and IMU data.
            try
                obj.implementation.reset();
            catch
                obj.implementation = obj.implementation.startConnection(obj.ipaddress);
                obj.implementation.reset();
                obj.implementation.closeConnection();
            end
        end

    end

    %Subscribe methods
    methods(Sealed)

        function msg = read(obj, topic, varargin)
            msg = obj.implementation.read(topic, varargin);
        end

    end

end