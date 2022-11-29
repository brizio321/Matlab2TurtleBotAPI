clear
close all

co = ConfigureOptions();
co = co.enableOdom();
co = co.enableScan();

co = co.enableCmdVel();

options = co.getOptions();

tb = TBBurger("192.168.1.11", 4, TurnAndGo(options));

input('perform >');
tb.perform();