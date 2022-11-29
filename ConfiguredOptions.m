classdef ConfiguredOptions
    %ConfiguredOptions Provide some standard options to initialize a
    %Turtlebot Implementation class.

    methods(Access = private)
        function obj = ConfiguredOptions()
        end
    end

    methods(Static)

        function options = lds()
            %lds Options to enable just scan subscriber.
            builder = ConfigureOptions();
            builder = builder.enableScan();
            options = builder.getOptions();
        end

        function options = core()
            %core Options to enable publishers and subscribers for all
            %topic initialized from Core Node. Follow a list of all.
            %PUBLISHERS: /cmd_vel, /motor_power, /reset.
            %SUBSCRIBERS: /scan, /battery_state, /tf, /imu, /odom,
            %/magnetic_field, /joint_states, /diagnostics.
            builder = ConfigureOptions();

            builder = builder.enableBatteryState();
            builder = builder.enableTransformations();
            builder = builder.enableOdom();
            builder = builder.enableImu();
            builder = builder.enableMagneticField();
            builder = builder.enableJointStates();
            builder = builder.enableDiagnostics();

            builder = builder.enableMotorPower();
            builder = builder.enableCmdVel();
            builder = builder.enableReset();

            options = builder.getOptions();
        end
        
        function options = full()
            %full Options to enable publishers and subscribers for all
            %topic initialized from Core and LDS Nodes. Essentially, enable
            %all core() method options and lds() options.
            builder = ConfigureOptions();

            builder = builder.enableBatteryState();
            builder = builder.enableTransformations();
            builder = builder.enableOdom();
            builder = builder.enableImu();
            builder = builder.enableScan();
            builder = builder.enableMagneticField();
            builder = builder.enableJointStates();
            builder = builder.enableDiagnostics();

            builder = builder.enableMotorPower();
            builder = builder.enableCmdVel();
            builder = builder.enableReset();

            options = builder.getOptions();
        end

    end
end