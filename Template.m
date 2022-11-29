classdef Template < TurtlebotImpl
    %Template

    properties
        %List attributes used during control loop.
    end

    methods

        function obj = Template(options)
            obj = obj@TurtlebotImpl(options);
        end

    end

    methods

        function obj = startConnection(obj, ipaddress)
            obj = startConnection@TurtlebotImpl(obj, ipaddress);
            %Execute needed operations before entering in control loop.
        end

        function obj = closeConnection(obj)
            obj = closeConnection@TurtlebotImpl(obj);
            %Execute needed operations once control loop end.
        end
        
        function check = loop(obj)
            %Implements here logic to continue control loop.
        end

        function obj = sense(obj)
            %Use attributes to store useful data read from sensors.
        end

        function obj = process(obj)
            %Manipulate read data.
        end

        function obj = control(obj)
            %Apply a control law.
        end

        function obj = visualize(obj)
            %Plot data. Eventually, use attributes to store axis.
        end

    end

end