classdef(Sealed) Transformation
    %Transformation Implements methods to get coordinate tranformation
    %between Turtlebot's layers and components.

    methods(Access = private)
        function obj = Transformation()
        end
    end
    
    methods(Static)

        % Useful information
        % Turtlebot3 Model Burger returns just a transformation, from odom
        % coordinate system to the base_footprint.
        % The coordinate frame transformation should be characterized just
        % by small X, Y axes translations and Z axis rotation.
        % To read the official definitions for odom and base_footprint
        % follow the two reported links.
        % odom -> https://www.ros.org/reps/rep-0105.html
        % base_footprint -> https://www.ros.org/reps/rep-0120.html

        function [convertedTf, n] = convertTransformation(msg)
            %convertTransformation Convert a ROS TransformStamped object in 
            %a easy-to-read form.
            %   Messages published in /tf topic contain arrays of ROS
            %   TransformStamped object (geometry_msgs/TransformStamped
            %   type). convertTransformation methods extracts usefull
            %   information as Initial and Target Frame Names,
            %   translational vector and rotational angles.
            %   Translational vector contains, in order, [X, Y, Z] values.
            %   Rotational vector contains Euler's angles, hence [Z, Y, X]
            %   rotation values.
            %   convertedTf is an array of structs; each struct contains
            %   aforementioned properties.
            %   Output 'n' is the array length.
            convertedTf = []; n = 0;
            if ~isstruct(msg) || strcmp(msg.MessageType, ...
                    'tf2_msgs/TFMessage') ~= 1
                disp("Input argument tf must be a Ros Message of type" +...
                    " tf2_msgs/TFMessaged");
                return
            end

            n = numel(msg.Transforms);
            for i=1:n
                currentTf = msg.Transforms(i);
                newTf = {};
                newTf.inizialFrame = currentTf.Header.FrameId;
                newTf.targetFrame = currentTf.ChildFrameId;

                newTf.translation = [...
                    currentTf.Transform.Translation.X;
                    currentTf.Transform.Translation.Y;
                    currentTf.Transform.Translation.Z ];

                quat = currentTf.Transform.Rotation;
                newTf.eulRotation = quat2eul([quat.W quat.X quat.Y quat.Z])';

                convertedTf = [convertedTf, newTf];
            end

        end
        
    end
end