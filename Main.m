clear all
clc;
fprintf('Network Generation Code, version A01\n');
netgen = Netgen('netgen1.dat'); % All initialixation takes place in the constructor
netgen.writeData(); % The network data is written to file

