classdef (Abstract) Action < handle
    %Action Provides a blueprint to define new actions for Turtlebot3.
    % Action class automatically open a new ROSTalker to communicate with
    % Turtlebot and already implements control-loop definition and
    % management.
    % Final user has just to write algorithms to perform intended tasks
    % overriding few methods.

    properties(SetAccess = protected, GetAccess = protected)
        loopRate    %Execution rate of control loop, in Hz.
        meanPeriod  %Estimed execution period in seconds.
        model       %Turtletbot3 object. Refere to a TBBurger or TBWafflePi object.
        talker      %Instance of ROSTalker to communicate with Turtlebot.
        actionTimer %Timer performing control loop methods.
    end

    methods(Sealed, Access = protected)
        function controlLoop(obj)
            %controlLoop Check whether loop condition persists or not. If
            % true, a new action execution is performed. Otherwise, control
            % loop is broken.
            if obj.loop()
                obj.execute();
            else
                obj.stopAction();
            end
            if ~isnan(obj.actionTimer.AveragePeriod)
                obj.meanPeriod = 0.9*obj.meanPeriod + ...
                                 0.1*obj.actionTimer.AveragePeriod;
            end
        end
    end

    methods
        function obj = Action(loopRate, model)
            %Action Create a new Action instance. Initialize ROSTalker
            %object and control-loop timer.
            arguments
                loopRate (1, 1) {mustBePositive, mustBeInteger} = 2;
                model (1, 1) {mustBeA(model, "Turtlebot3")} = TBBurger();
            end
            obj.loopRate = loopRate;
            obj.model = model;

            obj.talker = obj.model.createTalker();
        end

        function preAction(obj)
            %preAction Executes, eventually, preliminary operations 
            %before control-loop starts.
        end

        function postAction(obj)
            %postAction Executes, eventually, post-processing operations.
        end

    end

    methods(Sealed)
        function startAction(obj)
            %Use MATLAB timer. Not fully tested.
            %startAction Fires loop timer.
            obj.meanPeriod = 1/obj.loopRate;
            obj.actionTimer = timer( ...
                    'TimerFcn', @(~, ~) obj.controlLoop(), ...
                    'ExecutionMode', 'fixedRate', ...
                    'Period', 1/obj.loopRate ...
                    );
            obj.actionTimer.StartFcn = {@(~, ~) obj.preAction()};
            obj.actionTimer.StopFcn = {@(~, ~) obj.postAction()};
            obj.actionTimer.start();
        end

        function stopAction(obj)
            %stopAction Invoked when loop condition is no more valid. Stops
            %control-loop timer.
            obj.actionTimer.stop();
            tau = obj.actionTimer.AveragePeriod;
            disp("Action stoppped.\nAverage period: ", string(tau), "'");
            obj.actionTimer.delete();
        end

        function startWithRate(obj)
            %Commonly used.
            r = rosrate(obj.loopRate);
            obj.meanPeriod = 1/obj.loopRate;
            obj.preAction();
            while obj.loop()
                obj.execute();
                
                waitfor(r)
                obj.meanPeriod = 0.9*obj.meanPeriod+0.1*r.LastPeriod;
            end
            disp('Averaged execution period: ')
            disp(obj.meanPeriod)
            obj.postAction();
        end
    end

    methods(Abstract)
        execute(obj);
        check = loop(obj);
    end

end