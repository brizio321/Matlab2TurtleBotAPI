clear;
close all;

ROSTalker.openConnection("127.0.0.1");

model = TBBurgerSim("");
action = MoveForwardDist(8, model);

action.startWithRate();

ROSTalker.closeConnection();