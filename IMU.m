classdef(Sealed) IMU
    %IMU Implements methods to extract IMU estimations of robot's attitude.
    %   'getX' methods retrieve target information X from input parameter 
    %   'msg'. This is a sensor_msgs/Imu structure, returned
    %   for example by Turtlebot3B.getImuData method.
    %   IMU estimations are based on acceleration and gyro sensor. 
    %   Attitude includes estimation of orientation, angular velocity and 
    %   linear acceleration.
    %   Units of measurement are [m/s^2] for accelerations and [rad/s] for
    %   rotational velocity.
    %   Each measure is coupled with a covariance matrix when known.

    methods(Access = private)
        function obj = IMU()
        end
    end

    methods(Static)

        function [frame, orientation, covariance] = getOrientation(msg)
            %getOrientation Extract Turtlebot's orientation estimation from
            %an imu message.
            %   Output value of the method are the coordinate frame used to
            %   express the orientation, the estimation and a covariance
            %   matrix if available (otherwise -1). 
            %   Orientation is a 3x1 vector. Angles are measured in [rad].
            %   Covariance between the three angles is expressed by a 3x3 
            %   matrix.
            %   If orientation is not available, all three outputs will be
            %   setted to -1.
            if msg.OrientationCovariance(1) == -1
                frame = -1; orientation = -1; covariance = -1;
                return
            end

            %frame
            frame = msg.Header.FrameId;
            
            %orientation
            quat = msg.Orientation;
            orientation = quat2eul([quat.W quat.X quat.Y quat.Z])';

            %covariance
            covArray = msg.OrientationCovariance;
            covariance = reshape(covArray, [3, 3]).';
        end

        function [frame, w, covariance] = getAngularVelocity(msg)
            %getAngularVelocity Extract Turtlebot's angular velocity 
            %estimation from an imu message.
            %   Output value of the method are the coordinate frame used to
            %   express the velocity, the estimation and a covariance
            %   matrix if available (otherwise -1). 
            %   Angular velocity is a 3x1 vector. Speeds are measured in 
            %   [rad/s]. Covariance between the three speeds is expressed 
            %   by a 3x3 matrix.
            %   If angular velocity is not available, all three outputs 
            %   will be setted to -1.
            if msg.AngularVelocityCovariance(1) == -1
                frame = -1; w = -1; covariance = -1;
                return
            end

            %frame
            frame = msg.Header.FrameId;
            
            %angular velocity
            w = [msg.AngularVelocity.X;
                 msg.AngularVelocity.Y;
                 msg.AngularVelocity.Z ];

            %covariance
            covArray = msg.AngularVelocityCovariance;
            covariance = reshape(covArray, [3, 3]).';
        end

        function [frame, a, covariance] = getLinearAcceleration(msg)
            %getLinearAcceleration Extract Turtlebot's linear acceleration
            %estimation from an imu message.
            %   Output value of the method are the coordinate frame used to
            %   express the acceleraion, the estimation and a covariance
            %   matrix if available (otherwise -1). 
            %   Linear Acceleraion is a 3x1 vector. Accelerations are 
            %   measured in [m/s^2]. Covariance between the accelerations 
            %   is expressed by a 3x3 matrix.
            %   If linear acceleration is not available, all three outputs 
            %   will be setted to -1.
            if msg.LinearAccelerationCovariance(1) == -1
                frame = -1; a = -1; covariance = -1;
                return
            end

            %frame
            frame = msg.Header.FrameId;
            
            %linear acceleration
            a = [msg.LinearAcceleration.X;
                 msg.LinearAcceleration.Y;
                 msg.LinearAcceleration.Z ];

            %covariance
            covArray = msg.LinearAccelerationCovariance;
            covariance = reshape(covArray, [3, 3]).';
        end

    end
end