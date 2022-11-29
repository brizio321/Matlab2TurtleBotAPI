classdef(Sealed) JointState
    %JointState Offer methods to reorganize data describing robot's joints
    %state. These are published by /joint_state topic in a "parallel array"
    %representation.

    methods(Access = private)
        function obj = JointState()
        end
    end

    methods(Static)
        
        %As wrote in sensor_msgs/JointState message definition:
        %"The state of each joint (revolute or prismatic) is defined by:
        % position of the joint (rad or m), velocity of the joint (rad/s 
        % or m/s) and effort applied in the joint (Nm or N)."
        %
        %JointState messages contains four vectors: one used to store joint
        %names, the others to store the three properties defining a state.
        %State of i-th joint is described by the i-th element of each
        %vector.
        %
        %Goal of 'convertStates' method is reorganize states in individual
        %structure; in output it returns an array of structures, where each
        %element describe the state of a joint.
        %JointState messages define all position, velocity and effort as
        %optional attributes. If known, they'll be specified in output
        %structures.

        function [states, n] = convertStates(msg)
            states = []; n = numel(msg.Name);
            for i=1:n
                newState = {};
                
                nameCell = msg.Name(i);
                newState.name = nameCell{1};

                if ~isempty(msg.Position)
                    newState.position = msg.Position(i);
                end
                
                if ~isempty(msg.Velocity)
                    newState.velocity  = msg.Velocity(i);
                end
                   
                if ~isempty(msg.Effort)
                    newState.effort = msg.Effort(i);
                end

                states = [ states, newState ];
            end
        end
    
    end
end