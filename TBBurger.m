classdef TBBurger < Turtlebot3
    %TBBurger Redefine Turtlebot3 abstraction. Provide a full structural
    %description for Turtlebot3 Model Burger.

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

        diff2uni = [TBBurger.wheel_radius/2, TBBurger.wheel_radius/2;
                    TBBurger.wheel_radius/TBBurger.wheel_track, ...
                        -TBBurger.wheel_radius/TBBurger.wheel_track];
        uni2diff = pinv(TBBurger.diff2uni);
    end

    methods
        function obj = TBBurger(namespace)
            arguments
                namespace string = "";
            end
            obj = obj@Turtlebot3(namespace);
        end 

        function talker = createTalker(obj)
            %createTalker Return a ROSTalker object to command and retrieve
            %data from  Turtlebot.
            talker = ROSTalker(obj);
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