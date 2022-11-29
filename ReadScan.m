classdef ReadScan < TurtlebotImpl
    %ReadScan Keep reading LDS scan every seconds uninterruptedly.

    properties
        ax

        obs_x
        obs_y
    end

    methods

        function obj = ReadScan(options)
            obj = obj@TurtlebotImpl(options);
            obj.ax = axes;
            xlim([-3, 3]);
            ylim([-3, 3]);
        end

    end
    
    methods
        
        function obj = startConnection(obj, ipaddress)
            obj = startConnection@TurtlebotImpl(obj, ipaddress);
            %Execute HERE needed operations before entering in control 
            %loop.
        end

        function obj = closeConnection(obj)
            %Execute HERE needed operations once control loop end.
            obj = closeConnection@TurtlebotImpl(obj);
        end

        function check = loop(obj)
            check = true;
        end

        function obj = sense(obj)
            [~, ~, obj.obs_x, obj.obs_y] = Scan.getCartesianScanData( read(obj, 'scan') );
        end

        function obj = process(obj)
            %Manipulate read data.
        end

        function obj = control(obj)
            %Apply a control law.
        end

        function obj = visualize(obj)
            %Plot data. Eventually, use attributes to store axis.
            plot(obj.ax, obj.obs_x, obj.obs_y, '.b');
            xlim([-3, 3]);
            ylim([-3, 3]);
        end

    end

end