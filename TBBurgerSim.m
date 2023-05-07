classdef TBBurgerSim < Turtlebot3
    %TBBurgerSim Redefine Turtlebot3 abstraction. Provide a full structural
    %description for Turtlebot3 Model Burger. Use this class to control a
    %simulated TurtleBot3 in a Gazebo simulation.

    properties(Constant, GetAccess = public)
        weight = 1           %[kg]
        length = 0.138       %[m]
        width = 0.178        %[m]
        height = 0.192       %[m]
        padding = 0.105      %[m]

        wheel_radius = 0.033 %[m]
        wheel_track = 0.16   %[m]

        maximum_translational_velocity = 0.22   %[m/s]
        maximum_rotational_velocity = 2.84      %[rad/s]

        diff2uni = [TBBurgerSim.wheel_radius/2, TBBurgerSim.wheel_radius/2;
                    TBBurgerSim.wheel_radius/TBBurgerSim.wheel_track, ...
                        -TBBurgerSim.wheel_radius/TBBurgerSim.wheel_track];
        uni2diff = pinv(TBBurgerSim.diff2uni);
    end

    methods
        function obj = TBBurgerSim(namespace)
            arguments
                namespace string = "";
            end
            obj = obj@Turtlebot3(namespace, true);
        end 

        function [v, w] = DDSpeed2UnicycleSpeed(wr, wl)
            %DDSpeed2UnicycleSpeed Convert right and left wheel speeds to
            %linear and angular speeds.
            speed = obj.diff2uni*[ wr; wl ];
            v = speed(1); w = speed(2);
        end

        function [wr, wl] = UnicycleSpeed2DDSpeed(v, w)
            %UnicycleSpeed2DDSpeed Convert linear and angular speeds to 
            %right and left wheel speeds.
            w = obj.uni2diff*[ v; w ];
            wr = w(1); wl = w(2);
        end
    end

end