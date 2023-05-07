classdef(Sealed) Odometry
    %Odometry Implements methods to extract odometry estimations of 
    %position and velocity.
    %   'getX' methods retrieve target information X from input parameter 
    %   'msg'. This is a nav_msgs/odom structure, returned for example by 
    %   Turtlebot3B.getOdometry method.
    %   Each estiation is coupled with a coordinate frame and a 6x6 
    %   covariance matrix expressing uncertainty.

    methods(Access = private)
        function obj = Odometry()
        end
    end

    methods(Static)

        function [frame, pose, covariance] = poseEstimation(msg)
            %poseEstimation Extract Turtlebot's pose estimation from a
            %odometry message.
            %   Output value of the method are the coordinate frame used to
            %   express the pose, the estimated pose and the covariance
            %   matrix. Pose and covariance are respectively a 3x1 vector 
            %   and a 3x3 matrix.
            
            %frame
            frame = msg.Header.FrameId;
            
            %pose
            point = msg.Pose.Pose.Position;
            quat = msg.Pose.Pose.Orientation;
            angles = quat2eul([quat.W quat.X quat.Y quat.Z]);
            
            pose = [point.X;
                     point.Y;
                     angles(1) ];

            %covariance
            covArray = reshape(msg.Pose.Covariance, [6, 6]).';
            covariance = [ covArray(1,1), covArray(1,2), covArray(1,6);
                            covArray(2,1), covArray(2,2), covArray(2,6);
                            covArray(6,1), covArray(6,2), covArray(6,6) ];
        end

        function [frame, speed, covariance] = speedEstimation(msg)
            %speedEstimation Extract Turtlebot's speed estimation from 
            %odometry message.
            %   Output value of the method are the coordinate frame used to
            %   express the speed, the estimated speed and the covariance
            %   matrix. Speed and covariance are respectively a 2x1 vector 
            %   and a 2x2 matrix.
  
            %frame
            frame = msg.ChildFrameId;
            
            %twist
            linear = msg.Twist.Twist.Linear;
            angular = msg.Twist.Twist.Angular;
            
            speed = [linear.X;
                     angular.Z ];

            %covariance
            covArray = reshape(msg.Twist.Covariance, [6, 6]).';
            covariance = [ covArray(1,1), covArray(1,6);
                            covArray(6,1), covArray(6,6) ];
        end

    end
end