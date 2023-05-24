classdef MoveForward < Action

    properties(SetAccess=private, GetAccess=private)
        cruisingSpeed = 0.10; %m/s

        targetTime = 10; %seconds
        elapsedTime
    end

    methods

        function obj = MoveForward(loopRate, model)
            obj = obj@Action(loopRate, model);
        end

        function preAction(obj)
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
            %Send control signal
            obj.talker.setSpeed(obj.cruisingSpeed, 0);
        end

    end
end