clear
close all

options = ConfiguredOptions.lds();

tb = TBBurger("192.168.1.11", 4, ReadScan(options));

input('perform >');
tb.perform();