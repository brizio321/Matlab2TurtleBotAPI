classdef MoveForwardDist < Action

    properties
        targetDistance = 2; %m

        startPose; %[x, y, theta]'
        pose;

        v = 0.15; %m/s
    end

    methods

        function obj = MoveForwardDist(loopRate, model)
            obj = obj@Action(loopRate, model);
        end

        function check = loop(obj)
            check = norm( obj.pose(1:2) - obj.startPose(1:2) ) < ...
                    obj.targetDistance;
        end

        function execute(obj)
            poseMsg = obj.talker.readOdometry();
            [~, obj.pose, ~] = Odometry.poseEstimation( poseMsg );

            obj.talker.setSpeed( obj.v, 0 )
        end

        function preAction(obj)
            poseMsg = obj.talker.readOdometry();
            [~, obj.startPose, ~] = Odometry.poseEstimation( poseMsg );
            obj.pose = obj.startPose;
        end

        function postAction(obj)
            obj.talker.stop();

            figure
            plot([obj.startPose(1), obj.pose(1)],...
                 [obj.startPose(2), obj.pose(2)], '--r',...
                 'Marker', '*')
            norm( obj.pose(1:2) - obj.startPose(1:2) )
        end

    end
end