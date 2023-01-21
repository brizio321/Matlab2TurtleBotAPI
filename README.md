# matlab_to_turtlebot_interface
A simple and general purpose software interface to control a Turtlebot3 from Matlab
**Need ROS Toolbox to run.**

## Roadmap
What I'd like to do to update this repo.
- [x] Describe, at least, another example to better understand how to use this set of classes.
- [ ] Add WafflePi class to concretize in code also Turtlebot3 model WafflePi.
- [ ] Add few methods, for WafflePi model, to deal with camera images.
- [ ] Write a more technical description.
- [ ] If useful, write a brief documentation for every utility class.

Roadmap list updated on 04/12/2022.

## Aim of scripts  
For personal developement, I needed an interface on Matlab to command a Turtlebot3 model Burger. After few research I found a great support from Matlab towards Turtlebot and, in general, ROS worlds: a lot of guides and tutorials are provided to get started with Turtlebots and ROS Toolbox.  
Since I had to write a general-purpose software interface, and considering also that the same interface could be used in future by people not necessarily familiar with ROS Toolbox, someone else online may need a similar collection of classes and methods.  
IMHO, the whole set of scripts it's composed in such a way to provide a **simple** but **complete** interface. Feel free to notify me about possible improvements, or eventually modify it yourself.  
In order to fully understand these scripts, just remind few concepts:  
- To establish a communication from and to a ROS network, Matlab initialize a *Node* to join the network and *publish/subscribe* to a *Topic*; however, first of all,   Matlab needs to know *where to find an access point to ROS network*. So, make sure computer running Matlab and the Turtlebot are connected to the same network and note take note of **Turtlebot's ip address**.  

## How scripts are structured  
This section is divided in two paragraphs.  
In the first one are mentioned and described relevant classes for final users, those who just want to download files and work without necessary knowing how they're wrote. I'll try to go easy with this description, and be as clear as I can.  
The second paragraph wants to be slightly more technical. It is addressed to who modify scripts and needs a deeper insight of the code: better to know first where to "put your hands".  
### A brief introduction  
Essentially, there are **three** key aspects when you're interacting with a Turtlebot3:  
1. Turtlebot's model (Burger/Waffle/Waffle Pi)  
2. Sensors and actuators you need to pursue a certain action
3. An outline of what (and in which order) Turtlebot has to do

All these three aspects are concretized in some class or class hierarchy.  
  
---

Turtlebot's model -> *Turtlebot3* hierarchy.
Those classes are abstractions of what is a Turtlebot to Matlab: an *ip address* to which send some commands (*implementation* attributes) at a certain *rate*.  
<img src="https://user-images.githubusercontent.com/101990157/204527367-8f761769-d0d2-4662-84aa-c76658c5baf3.jpg" width="400">

---

Sensors and actuators can be interpreted as *optional* components of your Turtlebot. They are useful to implement some actions, unnecessary for others. So, it seams fair to enable them or not during the execution of the scripts. Using *ConfigureOptions* object you'll be able to choose which Turtlebot's component (and ROS Topics) can be used to perform the target action.  Do you wanna have access to all Topics or just Topics created from a particular ROS Node? Get a predefined set of options from *ConfiguredOptions* class.  
  
---

Implements a schematic of what Turtlebot has to do extending *TurtlebotImpl* hierarchy.
Abstract class *TurtlebotImpl* is designed to manage all the communications over the ROS network. The only thing you have to do is extend the class and implements **five** abstract methods. Those are:  
- *loop*: returns a boolean value to determine if continue execution or not  
- *sense:* retrieve all information you need from ROS network  
- *process:* work on retrieved values, do your stuff  
- *control:* send commands to the Turtlebot  
- *visualize:* if needed, plot data  
Eventually, you can also reimplement *startConnection* and *closeConnection* methods as reported in *Template* script. Use them to execute actions before entering in control loop and just out from it.
<img src="https://user-images.githubusercontent.com/101990157/204527433-29025f4f-1ae9-437e-a61f-368e3ace48c9.jpg" width="200">
  
### A more technical review  
*Currently writing it, come back in few days*  

## Examples and how-to
### Reading LDS values  
This is a simple example to show how put all the pieces together. The goal is to write an application that (indefinitely) acquire LDS sensor's values and plot data.
Starting from *Template* file and apply necessary changes would be a straightforward approach.
First of all, starts from name: call the new file, and the class, *ReadScan*.

```
classdef ReadScan < TurtlebotImpl
```

Think a bit about what we need. The control loop is broke up in five times: 
1. Check loop condition (**check()**)
2. Acquire data (**sense()**)
3. Process data (**process()**)
4. Apply a control based on processing (**control()**)
5. Eventually, plot data you need (**visualize()**)

Retrieving and plotting data from LDS sensor can be achieved adjusting **sense()** and **visualize()** methods.
Similarly, perform the action without time constraints is obtained modifying **check()** method.
Hence, a new blueprint for *ReadScan* class is the following code.

```
properties
    %What's here?
end

methods
    function obj = Template(options)
        obj = obj@TurtlebotImpl(options);
    end
end

methods
    function obj = startConnection(obj, ipaddress)
        obj = startConnection@TurtlebotImpl(obj, ipaddress);
        %NO NEED TO ADD ACTION HERE
    end

    function obj = closeConnection(obj)
        %NO NEED TO ADD ACTION HERE
        obj = closeConnection@TurtlebotImpl(obj);
    end

    function check = loop(obj)
        %SAY IT'S GONNA BE FOREVER
        check = true;
    end

    function obj = sense(obj)
        %RETRIEVE DATA. Continue reading.
    end

    function obj = process(obj)
        %NOTHING TO DO HERE
    end

    function obj = control(obj)
        %NOTHING TO DO HERE
    end

    function obj = visualize(obj)
        %PLOT DATA. Continue reading.
    end
end
```

Few things to do. With order:
- Indefinitely running: done. :white_check_mark:
- Read scan: TODO. :heavy_exclamation_mark:
- Pass data from **sense()** to **visualize()**: TODO. :bangbang:
- Plot scan: TODO, but easy. :heavy_exclamation_mark:

About read values from /scan topic (read LDS measurements) I encourage you to check out ***Scan*** *utility class*.
***Scan*** class combined with *read()* method inherited from superclass *TurtlebotImpl* provide different ways to read LDS data.
For example choose to retrieve readings in polar or cartesian coordinates, or choose to enlarge readings of a certain distance or not.
In this case, we'll read data in cartesian coordinates without enlargin it.

```
function obj = sense(obj)
    [~, ~, obj.obs_x, obj.obs_y] = Scan.getCartesianScanData( read(obj, 'scan') );
end
```

But what about pass LDS read distances from **sense()** to **visualize()**?
Since *TurtlebotImpl* and derived classes have no ways to modify signature to invoke control-loop functions using different parameters, a solution is to use private properties class to store values from a method to the other.
*ReadScan* example store data for obstacle positions and axes to plot scans.

```
properties
    ax
    obs_x
    obs_y
end
```

Finally, just plot memorized values.  
 
```
function obj = visualize(obj)
    %Plot data. Eventually, use attributes to store axis.
    plot(obj.ax, obj.obs_x, obj.obs_y, '.b');
    xlim([-3, 3]);
    ylim([-3, 3]);
end
```

Create a script to launch the new implementation, say *ReadScanLaunch.m*.
To create a new Turtlbot object:
1. Build a set of options using *ConfigureOptions* objects or select a preconfiguration from *ConfiguredOptions* class. To just read scan, enabling /scan topic is sufficient. (*lds()* configuration if you use *ConfiguredOptions*).  
2. Note Turtlebot's ip address
3. Create a new Turtlebot3 object (use one of the concrete classes) providing ip address, loop rate and options.
4. Invoke *perform* to start execution.  

```
co = ConfigureOptions();
co = co.enableScan();
options = co.getOptions();
%Equivalent to
%options = ConfiguredOptions.lds();

tb = TBBurger("192.168.1.11", 4, ReadScan(options));
tb.perform();
```

Find this example in source code. Follow a video of a simulation.  


https://user-images.githubusercontent.com/101990157/204527481-b2461b40-a167-45d0-9732-f61376031946.mp4



### TurnAndGo  
*TurnAndGo* implementation makes Turtlebot go on in its front direction until near obstacles are detected. An obstacle, for simplicity, is considered to be in front of the Turtlebot when obstacle's points are detected by LDS and, in a polar coordinate system, have alpha coordinate greater than -30° and smaller than 30°.
When a new obstacle is detected, Turtlebot turn 45° left. If new front direction is free, it move on. Otherwise, it turns left of other 45° until a free direction is achieved.
This time, let's set a time for the simulation: after a fixed time, program ends.
As for *ReadScan* implementation, extend *TurtlebotImpl* class and work by difference.
Let's wrote down what to do:
1. Since simulation has a fixed time, we need to initialize a global timer and check for time expired on every iteration.
2. Acquire LDS measurements.
3. Process measurements: verify if distances measured for [-30°, 30°] angles are under distance treshold.
4. Based on processing, set a linear speed if direction is free or an angular speed if Turtlebot have to turn.
5. *Optional, not described in this comment, plot LDS measurement.*

Class properties needed to pass data through control loop method are:
- Two timers, one for global time and the other to complete the 45° rotation when obstacles are detecte. 
- Two vectors, to store LDS measurements coordinates.
- A boolean variable, to state when front direction is free.

```
properties
    global_time
    start_time

    obstacles_dir %direction
    obstacles_dis %distance
    free_from_obstacles = false;
end

```

Timer-based implementation are simply managed re-implementing **startConnection()** and **loop()** methods.
```
methods
    function obj = startConnection(obj, ipaddress)
        obj = startConnection@TurtlebotImpl(obj, ipaddress);
        obj.global_time = tic;
        obj.start_time = tic;
    end

    function obj = closeConnection(obj)
        CommandVelocity.stop(obj);
        obj = closeConnection@TurtlebotImpl(obj);
    end
    
    function check = loop(obj)
        check = toc(obj.global_time) < 45; %seconds
    end %loop
end
```

To acquire LDS scans in polar coordinates let's use *Scan* utility class methods.
*Scan.getValidScanDataEnlarged* method extract from a message, published in /scan topic, only measures considered "reliable" (not negative and not out-of bound for sensor's range).
Also, *Scan.getValidScanDataEnlarged* wants a second parameter (double) and reduce distances of a certain amount in order to enlarge the detected obstacle.
```
function obj = sense(obj)
    [~, obj.obstacles_dir, ~, obj.obstacles_dis] = ...
        ( obj.read('scan'), obj.model.tbot_circumscribing_radius );
end %sense
```

Once read measurements from LDS, **process()** method test whether or not an obstacle is placed along Turtlebot's front direction. If Turtlebot is currently turning to change direction, the method does not modify this state.
When a new obstacle is detected, start the timer used to perform the 45° rotation.
```
function obj = process(obj)
    %If it's actually turning because of detected obstacle, keep
    %turning.
    if ~obj.free_from_obstacles
        return;
    end

    %If it's moving forward or just turned left of 45°, check for
    %obstacles.
    obj.free_from_obstacles = true;
    for i=1:numel(obj.obstacles_dir)
        if obj.obstacles_dis(i) <= obj.model.tbot_circumscribing_radius && ...
                (obj.obstacles_dir(i) >= deg2rad(330) || ...
                obj.obstacles_dir(i) <= deg2rad(30) )
            obj.free_from_obstacles = false;

            %Obstacle detected: start timer to perform turning left
            %trajectory.
            obj.start_time = tic;
            break;
        end
    end
end %process
```

Finally, **control()** method follow what **process()** decided. If direction is free, set a linear speed to move on. If not, keep setting angular speed to perform the 45° rotation.
```
function obj = control(obj)
    %Keep moving if forward direction is free from obstacles.
    if obj.free_from_obstacles
        v = 0.05; w = 0;
    else
        [v, w] = turn45Left( toc(obj.start_time) );
        if abs(v) > 0
        obj.free_from_obstacles = true;
        v = 0; w = 0;
        end
    end

    obj.setLinearAngularSpeed( v, w );
end %control

function [v, w] = turn45Left(delta_t)
    if delta_t < (pi/4) / 0.25
        v = 0; w = 0.25;
    else
        v = 0.05; w = 0;
    end
end
```

Note that *turn45Left(t)* method can be included as a private static method or wrote external to classdef.
**Source code is comprehensive of visualization of LDS measurements.**

Create a script to launch the new implementation.
```
co = ConfigureOptions();
co = co.enableOdom();
co = co.enableScan();

co = co.enableCmdVel();

options = co.getOptions();

tb = TBBurger("192.168.1.11", 4, TurnAndGo(options));
tb.perform();
```
