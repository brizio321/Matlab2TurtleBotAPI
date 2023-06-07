classdef LDSDemo < Action

    properties(SetAccess=private, GetAccess=private)
        cruisingSpeed = 0.10; %m/s

        targetTime = 20; %seconds
        elapsedTime

        measurementAx
        % measurementPolarAx
    end

    methods

        function obj = LDSDemo(loopRate, model)
            obj = obj@Action(loopRate, model);
        end

        function preAction(obj)
            % Create the axes
            figure
            obj.measurementAx = axes();
            % obj.measurementPolarAx = polaraxes();

            %Fire timer
            obj.elapsedTime = tic;
        end

        function postAction(obj)
            %Stop turtlebot
            obj.talker.setSpeed(0, 0);
        end
        
        function check = loop(obj)
            %Check elapsed time
            check = toc(obj.elapsedTime) < obj.targetTime;
        end

        function execute(obj)
            % Read a new scan message
            scanMsg = obj.talker.readScan();

            % Use Scan static class to extract information from a scan message
            [~, ~, x, y] = Scan.cartesianScanData( scanMsg );
            % [~, alpha, ~, ranges] = Scan.validData( scanMsg );

            % Plot measurements
            plot(obj.measurementAx, x, y, '.');
            axis('equal')
            % polarplot(obj.measurementPolarAx, alpha, ranges)

            %Send control signal
            obj.talker.setSpeed(obj.cruisingSpeed, 0);
        end

    end
end