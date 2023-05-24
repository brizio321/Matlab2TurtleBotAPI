clear
close all

ROSTalker.openConnection("127.0.0.1");

model = TBBurgerSim("");
action = MoveForward(4, model);

action.startWithRate();

ROSTalker.closeConnection();