classdef TBBurger < Turtlebot3
    %TBBurger Redefine Turtlebot3 abstraction, providing a full-description
    %for Turtlebot3 Model Burger.

    properties(Constant, GetAccess = public)
        weight = 1                              %[kg]
        length = 0.138                          %[m]
        width = 0.178                           %[m]
        height = 0.192                          %[m]
        tbot_circumscribing_radius = 0.105      %[m]

        wheel_radius = 0.033                    %[m]
        wheel_track = 0.16                      %[m]

        maximum_translational_velocity = 0.22   %[m/s]
        maximum_rotational_velocity = 2.84      %[rad/s]

        diff2uni = [TBBurger.wheel_radius/2, TBBurger.wheel_radius/2;
                    TBBurger.wheel_radius/TBBurger.wheel_track, ...
                        -TBBurger.wheel_radius/TBBurger.wheel_track];
        uni2diff = pinv(TBBurger.diff2uni);
    end

    methods

        function obj = TBBurger(ipaddress, loop_rate, implementation)
            %TBBurger Invoke Turtlebot3 constructor and set
            %model-parameter of implementation, in order to know which
            %model is in execution.
            obj = obj@Turtlebot3(ipaddress, loop_rate, implementation);
            obj.implementation = obj.implementation.setModel(obj);
        end
        
    end

end