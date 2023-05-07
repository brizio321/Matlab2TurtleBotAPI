# Matlab2TurtleBotAPI

Software interface developed as part of my bachlor's thesis with the goal to provide a simple toolbox to develop new actions performed by a TurtleBot3 model Burger.
The TurtleBot series run Robot Operating System (ROS), encouraging users to write their softwares in Python or C/C++ according to ROS development guidelines. This software interface try to reduce as much as possible the necessary concepts of ROS needed to implement a new action, providing to both ROS comfortable and uncomfortable users the possibility to write their programs in Matlab.
**Need ROS Toolbox to run.**

---

The set of provided classes and procedures to implement new actions, obviously, will never be as powerful as a native ROS implementation. However, all essential operations are supported: you can control robot's speed, acquire robot's state and LIDAR's readings.
Most important, the usage of the interface not requires a complete ROS knowledge: all you have to know is an IP address!
Check wiki pages for more information about the structure of the software interface and how to use it. 