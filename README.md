# matlab_to_turtlebot_interface
 A simple and general purpose software interface to control a Turtlebot3 from Matlab

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
![APIv1_3 - Turtlebot Abstraction](https://user-images.githubusercontent.com/101990157/204527367-8f761769-d0d2-4662-84aa-c76658c5baf3.jpg)
Those classes are abstractions of what is a Turtlebot to Matlab: an *ip address* to which send some commands (*implementation* attributes) at a certain *rate*.  
  
---

Sensors and actuators can be interpreted as *optional* components of your Turtlebot. They are useful to implement some actions, unnecessary for others. So, it seams fair to enable them or not during the execution of the scripts. Using *ConfigureOptions* object you'll be able to choose which Turtlebot's component (and ROS Topics) can be used to perform the target action.  Do you wanna have access to all Topics or just Topics created from a particular ROS Node? Get a predefined set of options from *ConfiguredOptions* class.  
  
---

Implements a schematic of what Turtlebot has to do extending *TurtlebotImpl* hierarchy.  
![APIv1_3 - Turtlebot Implementation](https://user-images.githubusercontent.com/101990157/204527433-29025f4f-1ae9-437e-a61f-368e3ace48c9.jpg)
Abstract class *TurtlebotImpl* is designed to manage all the communications over the ROS network. The only thing you have to do is extend the class and implements **five** abstract methods. Those are:  
- ^^loop:^^ returns a boolean value to determine if continue execution or not  
- ^^sense:^^ retrieve all information you need from ROS network  
- ^^process:^^ work on retrieved values, do your stuff  
- ^^control:^^ send commands to the Turtlebot  
- ^^visualize:^^ if needed, plot data  
Eventually, you can also reimplement *startConnection* and *closeConnection* methods as reported in *Template* script. Use them to execute actions before entering in control loop and just out from it.  
  
### A more technical review  
*Currently writing it, come back in few days*  

## Examples and how-to  
### Reading LDS values  
A simple example to show how to put all the pieces together, building an application that (indefinitely) acquire LDS sensor's values and plot data.  
First, derive from *TurtlebotImpl* a new class. Call it *ReadScan*. You can use *Template* file as starting point, changing step-by-step what needed.  
`classdef ReadScan < TurtlebotImpl`  
Since we'll only reimplement the five abstract methods from TurtlebotImpl, there's no way to change their signature to pass parameter. Hence, use *properties block* to create all support variable useful to pass data from one method to the other.  

```
    properties
    ax
    obs_x
    obs_y
    end
```

The actions performed are simply reading data and visualizing them, and these are repeated until user kill execution. So, we can just modify three of the five abstract methods: *loop*, sense* and *visualize*. The others can be left blank, or totally not reported in *ReadScan* class.  
 
```
    function check = loop(obj)
    check = true;
    end
    
    function obj = sense(obj)
    [~, ~, obj.obs_x, obj.obs_y] = Scan.getCartesianScanData( read(obj, 'scan') );
    end
    
    function obj = visualize(obj)
    %Plot data. Eventually, use attributes to store axis.
        plot(obj.ax, obj.obs_x, obj.obs_y, '.b');
        xlim([-3, 3]);
        ylim([-3, 3]);
    end
```

In a new launch script, say *ReadScanLaunch.m*, select the desired *options* to be enabled. In this case, the preconfigured *lds* configuration (enable just /scan topic reading) will be fine.  
Create a new Turtlebot3 object using one of the concrete classes providing ip address, loop rate and options. Invoke *perform* to start execution.  
 
```
    tb = TBBurger("192.168.1.11", 4, ReadScan(options));
    tb.perform();
```

Find this example in source code. Follow a video of a simulation.  


https://user-images.githubusercontent.com/101990157/204527481-b2461b40-a167-45d0-9732-f61376031946.mp4



### TurnAndGo  
*Already included in source code, soon also a description of this example. It's more rich than ReadScan*  
