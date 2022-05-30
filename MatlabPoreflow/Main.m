clear all
clc
fprintf('Network Model Code v2, build 20031028\n');
inputFileName = 'runflow.dat';
input = InputData(inputFileName);

matlabMode = false;
excelMode = false;
[matlabFormat,excelFormat] = input.resFormat(matlabMode, excelMode);

seedNum = -858993460;
seedNum = input.randSeed(seedNum);

baseFileName = [];
baseFileName = input.title(baseFileName);

netsim = Netsim(seedNum,1);

prtFile = [baseFileName,'.prt'];
input.echoKeywords(prtFile);

netsim.addOStreamForPrt(prtFile);

netsim.init(input);


