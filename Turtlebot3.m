classdef (Abstract) Turtlebot3
    %Turtlebot3 Describe Turtlebot3 robot model. On a high level 
    % abstraction, Matlab see Turtlebot as a computer running ROS nodes in 
    % the same network.The only characterizing property is the namespace.
    % Turtlebot3 is an abstract class concretized by subclasses TB3Burger 
    % and TB3WafflePi. Both extends abstract class definition adding 
    % model-specific structural properties.

    properties(SetAccess = protected)
        namespace   %Namespace specified for Turtlebot's nodes.
    end

    methods

        function obj = Turtlebot3(namespace)
            %Turtlebot3 Create a new Turtlebot3 object.
            %   Eventually, specify Turtlebot nodes' namespace as input
            %   parameter. Empty string is used as default namespace.
            arguments
                namespace string = "";
            end
            obj.namespace = namespace;
        end

        function obj = setNamespace(namespace)
            %setNamespace Specify Turtlebot nodes' namespace.
            mustBeA(a, ["string", "char"])
            obj.namespace = namespace;
        end

    end

    methods(Abstract)
        talker = createTalker(obj);
    end

end