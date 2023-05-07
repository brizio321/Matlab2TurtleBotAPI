classdef ROSTalker
    %ROSTalker Implements MATLAB communication methods from/to ROS network.

    properties(GetAccess = private, SetAccess = private)
        %Each property is a strutcture containing several field. Object
        %corrisponding to a field is the publisher/subscriber used to
        %communicate over the network.
        publisher
        subscriber
    end

    properties(GetAccess = private, SetAccess = private)
        %Keep trace of Turtlebot3 model used. Model object keep trace of
        %structural properties and constraints. In this case, robot's speed
        %limits are used to (eventually) saturate speed settings.
        model
    end

    %Static methods independently of Turtlebot3's model. Use it to
    %initialize/delete MATLAB global node in ROS network.
    methods(Static)
        function openConnection(ipaddress)
            rosinit(ipaddress, 11311)
        end

        function closeConnection()
            rosshutdown
        end
    end

    %Public methods.
    methods
        function obj = ROSTalker(model)
            %ROSTalker Construct an instance of this class. Create 
            %and store a set of predefined publishers and subscribers.
            obj.model = model;
            obj = obj.initPublisher();
            obj = obj.initSubscriber();
        end
    end

    %Private methods to initialize publishers and subscribers.
    %Automatically read Turtlebot's namespace specified by model object.
    methods(Access = private)
        function obj = initPublisher(obj)
            obj.publisher.speed = ...
                rospublisher(strcat(obj.model.namespace, '/cmd_vel'), 'DataFormat', 'struct');

            obj.publisher.reset = ...
                rospublisher(strcat(obj.model.namespace, '/reset'), 'DataFormat', 'struct');
        end

        function obj = initSubscriber(obj)
            obj.subscriber.odometry = ...
                rossubscriber(strcat(obj.model.namespace, '/odom'), 'DataFormat', 'struct');
            
            obj.subscriber.scan = ...
                rossubscriber(strcat(obj.model.namespace, '/scan'), 'DataFormat', 'struct');

            obj.subscriber.imu = ...
                rossubscriber(strcat(obj.model.namespace, '/imu'), 'DataFormat', 'struct');

            obj.subscriber.Transformations = ...
                rossubscriber(strcat(obj.model.namespace, '/tf'), 'DataFormat', 'struct');
        end
    end

    %Public methods to command Turtlebot motion.
    methods(Sealed)
        function stop(obj)
            %stop Stop Turtlebot's motion.
            obj.setSpeed(0, 0);
        end

        function setSpeed(obj, v, w)
            %setSpeed Set Turtlebot's linear and angular speed.
            %Automatically saturate both speeds if greater than model's
            %constraints.
            if abs(v) > obj.model.maximum_translational_velocity
                v = sign(v)*obj.model.maximum_translational_velocity;
            end
            if abs(w) > obj.model.maximum_rotational_velocity
                w = sign(w)*obj.model.maximum_rotational_velocity;
            end
            pub = obj.publisher.speed;
            msg = rosmessage(pub);
            msg.Linear.X = v;
            msg.Angular.Z = w;
            pub.send(msg );
        end

        function resetOdometry(obj)
            %reset Reset Odometry and IMU data.
            pub = obj.publisher.reset;
            msg = rosmessage(pub);
            pub.send(msg)
            disp("Resetting odometry.")
        end
    end

    %Public methods to retrieve data from Turtlebot.
    methods(Sealed)
        function msg = readOdometry(obj, varargin)
            %readOdometry Return the last odometry message as a structure.
            %If not comfortable with ROS messages structures, check
            %Odometry utility class.
            %Optionally, specify a timeout to read the message.
            msg = ROSTalker.readMsg(obj.subscriber.odometry, varargin);
        end

        function msg = readScan(obj, varargin)
            %readScan Return the last scan message as a structure.
            %If not comfortable with ROS messages structures, check
            %Scan utility class.
            %Optionally, specify a timeout to read the message.
            msg = ROSTalker.readMsg(obj.subscriber.scan, varargin);
        end

        function msg = readImu(obj, varargin)
            %readImu Return the last imu message as a structure.
            %If not comfortable with ROS messages structures, check
            %Imu utility class.
            %Optionally, specify a timeout to read the message.
            msg = ROSTalker.readMsg(obj.subscriber.imu, varargin);
        end

        function msg = readCoordinateTf(obj, varargin)
            %readCoordinateTf Return the last coordinate transformation
            %message as a structure. If not comfortable with ROS messages 
            %structures, check Transformation utility class.
            %Optionally, specify a timeout to read the message.
            msg = ROSTalker.readMsg(obj.subscriber.tf, varargin);
        end
    end

    %Private method to read messages from ROS network.
    methods(Access = private, Static)
        function msg = readMsg(sub, varargin)
            if nargin > 2
                time = varargin{1};
                [msg, ~, statustext] = ...
                    sub.receive(time);
            else
                [msg, ~, statustext] = ...
                    sub.receive();
            end
            
            if strcmp(statustext, 'success') == 0
                msg = statustext;
            end
        end
    end

end