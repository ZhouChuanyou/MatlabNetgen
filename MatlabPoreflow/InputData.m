classdef InputData < handle
    %UNTITLED4 此处显示有关此类的摘要
    %   此处显示详细说明
    %     //  Available keywords are:
    %     //
    %     //X  TITLE               Title of run
    %     //X  RAND_SEED           Seed for random number generator
    %     //X  SAT_TARGET          Specifying saturation targets
    %     //X  RELPERM_DEF         USe flowrate at single or residual saturation to calculate kr
    %     //X  PRS_BDRS            What type of pressure boundaries should be used
    %     //X  SAT_COMPRESS        Reduce saturation interval once kr drops below given threshold
    %     //X  MAT_BAL             Calculates material balace of the fluids present
    %     //X  APEX_PRS            Record tme minimum (drainage) pc observed in the last step
    %     //X  POINT_SOURCE        Rather than inject across ine inlet face, inject from a single pore index
    %     //X  SOLVER_TUNE         Tuning options for rel perm solver
    %     //X  PORE_FILL_WGT       Weights for pore body filling mechnism
    %     //X  PORE_FILL_ALG       Pore body filling mechnism algorithm
    %     //X  MODIFY_RAD_DIST     Modify inscribed radii distribution
    %     //X  MODIFY_G_DIST       Modify shape factor distribution
    %     //X  MODIFY_PORO         Modify porosity
    %     //X  MODIFY_CONN_NUM     Reduce connection number
    %     //X  MODIFY_MOD_SIZE     Modify absolute model size
    %     //X  SAT_COVERGENCE      Saturation covergence tuning
    %     //X  TRAPPING            Trapping options
    %     //X  FILLING_LIST        Create list for movie post processing
    %     //X  OUTPUT              Create water sat map
    %     //X  RES_FORMAT          Which output format to use
    %     //X  GRAV_CONST          Vectorized gravity constant
    %     //X  FLUID               Fluid properties
    %     //X  CLAY_EDIT           Edit clay content
    %     //X  A_CLOSE_SHAVE       Shave off boundaries to remove end-effects in net generation
    %     //X  CALC_BOX            Where to set pressure boundaries for rel perm solver
    %     //X  PRS_DIFF            Define the pressure differential across network for rel perm calculations
    %     //X  NETWORK             The network to be used
    %     //  NET_SERIES          Add networks in series
    %     //  PERIODIC_PBC        Add periodic bc
    %     //X  FRAC_CON_ANG        Fractional wetting options
    %     //X  INIT_CON_ANG        Initial contact angle
    %     //X  EQUIL_CON_ANG       Equilibration contact angle
    %     //X  WRITE_NET           Write new network to file
    %     //  SOLVER_DBG          Debugging options for solver
    %     //
    properties
        MultiConnValType
        MapItr
        
        DUMMY_INDEX = -99;
        m_poreConn;
        m_poreProp;
        m_throatConn;
        m_throatProp;
        m_parsedData;
        m_baseFileName;
        m_connectionsRemoved;
        m_origNumPores;
        m_origNumThroats;
        m_numNetInSeries;
        m_workingSatEntry;
        m_numInletThroats;
        m_binaryFiles;
        m_useAvrXOverThroatLen;
        m_useAvrPbcThroatLen;
        m_addPeriodicBC;
        m_poreData;
        m_throatData;
        m_inletPores;
        m_outletPores;
        m_outletConnections;
        m_inletConnections;
        m_xyPbcConn;
        m_xzPbcConn;
        m_pbcData;
        m_throatHash;
        m_reverseThroatHash;
        m_origXDim;
        m_origYDim;
        m_origZDim;
        m_averageThroatLength;
        m_averagePoreHalfLength;
        m_networkSeparation;
        m_PoreStruct=struct('index',[],'x',[],'y',[],'z',[],'connNum',[],...
            'volume',[],'radius',[],'shapeFact',[],'clayVol',[]);
        m_ThroatStruct = struct('index',[],'poreOne',[],'poreTwo',[],...
            'radius',[],'shapeFact',[],'lenPoreOne',[],'lenPoreTwo',[],...
            'lenThroat',[],'lenTot',[],'volume',[],'clayVol',[]);
    end
    
    methods
        function obj = InputData(inputFileName)
            %UNTITLED4 构造此类的实例
            %   此处显示详细说明
            previousKeyword = 'NO_KEYWORD_READ';
            obj.m_workingSatEntry = 0;
            obj.m_numInletThroats = 0;
            obj.m_averageThroatLength = 0.0;
            obj.m_networkSeparation = 0.0;
            obj.m_connectionsRemoved = 0;
            obj.m_useAvrXOverThroatLen = false;
            obj.m_addPeriodicBC = false;
            obj.m_useAvrPbcThroatLen = false;
            
            if ~exist(inputFileName)
                error...
                    ('Error:Unable to open input file %s\r\n',inputFileName);
            else
                fid = fopen(inputFileName);
                while ~feof(fid) % 判断是否为文件末尾
                    line = fgetl(fid);
                    if isempty(line)
                        continue;
                    elseif line(1) == '%'
                        keyword = [];
                    elseif size(line,2)<5 || size(line,2)>15
                        error...
                            ('Data file contains errors after keyword:%s\r\n'...
                            ,previousKeyword);
                    else
                        keyword = line;
                        dataString = [];
                        while true
                            bufferStr = fgetl(fid);
                            obj.removeComments(bufferStr);
                            bufferStr = evalin('base','bufferStr');
                            dataString = [dataString,bufferStr,'  '];
                            if obj.terminatorFound(dataString)
                                dataString = evalin('base','dataString');
                                break;
                            end
                        end
                        dataEntry = containers.Map(keyword,dataString);
                        obj.m_parsedData{end+1} = dataEntry;
                        previousKeyword = keyword;
                    end
                end
                fclose(fid);
                obj.m_baseFileName = inputFileName...
                    (1:strfind(inputFileName, '.')-1);
            end
        end
        
        function removeComments(obj,data)
            itr = find(data == '%');
            if itr ~= size(data,2)
                data(itr:size(data,2))=[];
            end
            assignin('base','bufferStr',data);
        end
        
        function terminatorFound = terminatorFound(obj,data)
            itr = find(data == '#');
            if itr ~= size(data,2)
                data(itr:size(data,2))=[];
                terminatorFound = true;
            else
                terminatorFound = false;
            end
            assignin('base','dataString',data);
        end
        
        function [matlabFormat,excelFormat] = resFormat(obj,matlabFormat,excelFormat)
            data = [];
            keyword = 'RES_FORMAT';
            if obj.getData(data,keyword)
                resForm = evalin('base','data');
                resForm = strtrim(resForm);
                fprintf('Reading %s\r\n',keyword);
                matlabFormat = ...
                    strcmp(resForm,'MATLAB')...
                    || strcmp(resForm,'matlab') ...
                    || strcmp(resForm,'Matlab');
                excelFormat = ...
                    strcmp(resForm,'EXCEL')...
                    || strcmp(resForm,'excel') ...
                    || strcmp(resForm,'Excel');
                if isempty(resForm)
                    obj.errorMsg(keyword);
                end
                obj.errorInDataCheck(resForm, keyword);
            else
                matlabFormat = false;
                excelFormat = false;
            end
        end
        
        % All basic keywords are retived from the parsed storage. If not present the
        % default values are used.
        function baseFileName = title(obj,baseFileName)
            data =[];
            keyword = 'TITLE';
            if obj.getData(data,keyword)
                baseFileName = evalin('base','data');
                baseFileName = strtrim(baseFileName);
                if isempty(baseFileName)
                    obj.errorMsg(keyword);
                end
                obj.errorInDataCheck(baseFileName, keyword);
            else
                baseFileName = obj.m_baseFileName;
            end
        end
        
        % Retrieves data sting based on supplied keyword, and connects a
        % string stream to it. Data is removed from storage after having been
        % retrived
        function getData = getData(obj,data,keyword)
            for i = 1:size(obj.m_parsedData,2)
                key = keys(obj.m_parsedData{i});
                if strcmp(key{1},keyword)
                    value = values(obj.m_parsedData{i});
                    data = value{1};
                    getData = true;
                    assignin('base','data',data);
                    return;
                end
            end
            getData = false;
            assignin('base','data',data);
        end
        
        % Returns error message is error occurs during reading of data string
        function errorMsg(obj,keyword)
            error('Error while reading input file.\r\nKeyword: %s\r\n',...
                keyword);
        end
        
        function errorInDataCheck(obj,data,keyword)
            if length(data)>50    %('matlab','8657423(seedNum)' ……)
                error...
                    ('Error: Too much data read for keyword:%s\r\nData read:%s\r\n'...
                    ,keyword,data);
            end
        end
        
        function seedNum = randSeed(obj,seedNum)
            data = [];
            keyword = 'RAND_SEED';
            if obj.getData(data, keyword)
                fprintf('Reading %s\r\n',keyword);
                seedNum = evalin('base','data');
                if isempty(seedNum)
                    obj.errorMsg(keyword);
                end
                obj.errorInDataCheck(seedNum, keyword);
            else
                %                 ran = num2str(randperm(9)-1);
                %                 ran(find(isspace(ran))) = [];
                %                 ran = ['1',ran];
                %                 seedNum = str2num(ran);
                seedNum = randi([1000000000,2000000000]);
            end
        end
        
        % Echos the keywords and associated data to the given output stream
        function echoKeywords(obj,prtFile)
            fid = fopen(prtFile,'w');
            for i = 1:size(obj.m_parsedData,2)
                key = keys(obj.m_parsedData{i});
                value = values(obj.m_parsedData{i});
                fprintf(fid,'%s\r\n%s\r\n\r\n',key{1},value{1});
            end
            fclose(fid);
        end
        
        function [inletBdr,outletBdr]=calcBox(obj,inletBdr,outletBdr)
            data = [];
            keyword = 'CALC_BOX';
            if obj.getData(data, keyword)
                fprintf('Reading %s\r\n',keyword);
                data = evalin('base','data');
                data = textscan(data,'%f');
                inletBdr = data{1}(1);
                outletBdr = data{1}(2);
                if isempty(data)
                    obj.errorMsg(keyword);
                end
                obj.errorInDataCheck(data, keyword);
            else
                inletBdr = 0.5;
                outletBdr = 1.0;
            end
        end
        
        % The nework data is supplied back as the pores and throats are created. The input
        % streams are intially just opened and the headers read.
        function [numPores,numThroats,xDim,yDim,zDim]=network(obj,...
                numPores,numThroats,xDim,yDim,zDim)
            dataPbc = [];
            keyword = 'NETWORK';
            keywordNet = 'NET_SERIES';
            keywordPbc = 'PERIODIC_BC';
            if obj.getData(dataPbc,keywordPbc)
                fprintf('Reading %s\r\n',keywordPbc);
                dataPbc = evalin('base','data');
                dataPbc = textscan(dataPbc,'%f');
                usePbc = dataPbc{1}(1);
                avrLen = dataPbc{1}(2);
                obj.m_useAvrPbcThroatLen = usePbc == 'T' || usePbc == 't';
                if isempty(dataPbc)
                    obj.errorMsg(keywordPbc);
                end
                obj.errorInDataCheck(dataPbc, keywordPbc);
            else
                obj.m_addPeriodicBC = false;
                obj.m_useAvrPbcThroatLen = false;
            end
            dataNet = [];
            if obj.getData(dataNet, keywordNet)
                fprintf('Reading %s\r\n',keywordNet);
                dataNet = evalin('base','data');
                dataNet = textscan(dataNet,'%f');
                obj.m_numNetInSeries = dataNet{1}(1);
                avrLen = dataNet{1}(2);
                obj.m_networkSeparation= dataNet{1}(3);
                obj.m_useAvrXOverThroatLen = avrLen == 'T' || avrLen == 't';
                if isempty(dataNet)
                    obj.errorMsg(keywordNet);
                end
                obj.errorInDataCheck(dataNet, keywordNet);
            else
                obj.m_numNetInSeries = 1;
                obj.m_useAvrXOverThroatLen = false;
            end
            
            data = [];
            if obj.getData(data, keyword)
                fprintf('Reading %s\r\n',keyword);
                data = evalin('base','data');
                datar = regexp(data,'\s+','split');
                datar(cellfun(@isempty,datar))=[];
                % data = textscan(data,'%f');
                binFile = datar{1};
                netFileBase = datar{2};
                obj.m_binaryFiles = binFile == 'T' || binFile == 't';
                if isempty(data)
                    obj.errorMsg(keyword);
                end
                obj.errorInDataCheck(data, keyword);
            else
                obj.missingDataErr(keyword);
            end
            
            if obj.m_binaryFiles
                porePropFile = [netFileBase ,'_node.bin'];
                obj.m_poreProp = fopen(porePropFile,'rb');
                throatPropFile = [netFileBase + '_link.bin'];
                obj.m_throatProp = fopen(throatPropFile,'rb');
                numPores = fread(obj.m_poreProp,1);
                xDim = fread(obj.m_poreProp,1);
                yDim = fread(obj.m_poreProp,1);
                zDim = fread(obj.m_poreProp,1);
                % fclose(obj.m_poreProp);
                numThroats = fread(obj.m_throatProp,1);
                % fclose(obj.m_throatProp);
            else
                poreConnFile = [netFileBase,'_node1.dat'];  % Open file containing pore connection data
                obj.m_poreConn = fopen(poreConnFile,'r');
                porePropFile = [netFileBase,'_node2.dat']; % Open file containing pore geometry data
                obj.m_poreProp = fopen(porePropFile,'r');
                throatConnFile = [netFileBase, '_link1.dat']; % Open file containing throat connection data
                obj.m_throatConn = fopen(throatConnFile,'r');
                throatPropFile = [netFileBase, '_link2.dat']; % Open file containing throat geometry data
                obj.m_throatProp = fopen(throatPropFile,'r');
                tline=fgetl(obj.m_poreConn);
                % data = regexp(tline,'\s+','split');
                data = str2num(tline);
                numPores = data(1);
                xDim = data(2);
                yDim = data(3);
                zDim = data(4);
                % fclose(obj.m_poreConn);
                numThroats=str2num(fgetl(obj.m_throatConn));
                % fclose(obj.m_throatConn);
            end
            obj.m_origNumPores = numPores;
            obj.m_origNumThroats = numThroats;
            obj.m_origXDim = xDim;
            obj.m_origYDim = yDim;
            obj.m_origZDim = zDim;
            if ~obj.m_poreProp || ~obj.m_throatProp || ...
                    (~obj.m_binaryFiles && ...
                    (~obj.m_poreConn || ~obj.m_throatConn))
                error('Error: Unable to open network data files\r\n');
            end
            if obj.m_numNetInSeries<1
                error('Error: There need to be at least one net in series\r\n');
            end
            obj.loadPoreData();
            obj.loadThroatData();
            numPores =numPores* obj.m_numNetInSeries;
            numThroats = obj.m_origNumThroats*obj.m_numNetInSeries -...
                obj.m_connectionsRemoved*(obj.m_numNetInSeries-1);
            xDim = xDim*obj.m_numNetInSeries + ...
                (obj.m_numNetInSeries-1)*obj.m_networkSeparation;
        end
        
        % As the throats are created the data is read from file and supplied back together with contact angles
        % that are stored in vectors.
        % The format of throat network files are:
        % *_link1.dat:
        % index, pore 1 index, pore 2 index, radius, shape factor, total length (pore center to pore center)
        % *_link2.dat:
        % index, pore 1 index, pore 2 index, length pore 1, length pore 2, length throat, volume, clay volume
        function loadThroatData(obj)
            obj.m_throatData = cell(1,obj.m_origNumThroats);
            lenSumPore = 0;
            lenSumThroat = 0;
            for i = 0+1:obj.m_origNumThroats
                if (~obj.m_binaryFiles && ~obj.m_throatConn)||~obj.m_throatProp
                    error('Error while reading network data.\r\n');
                end
                throatProp = obj.m_ThroatStruct;
                if obj.m_binaryFiles  % 有问题，但是目前没有进入这个判断，先不管
                    throatProp = fread(obj.m_throatProp,1);
                else
                    tline = fgetl(obj.m_throatConn);
                    data = str2num(tline);
                    throatProp.index = data(1);
                    throatProp.poreOne=data(2);
                    throatProp.poreTwo=data(3);
                    throatProp.radius = data(4);
                    throatProp.shapeFact=data(5);
                    throatProp.lenTot=data(6);
                    
                    tline = fgetl(obj.m_throatProp);
                    data = str2num(tline);
                    idx = data(1);
                    tmp= data(2);
                    tmp= data(3);
                    throatProp.lenPoreOne= data(4);
                    throatProp.lenPoreTwo= data(5);
                    throatProp.lenThroat= data(6);
                    throatProp.volume= data(7);
                    throatProp.clayVol= data(8);
                    assert(idx == throatProp.index);
                end
                obj.m_throatData{i} = throatProp;
                lenSumThroat =lenSumThroat+ throatProp.lenThroat;
                lenSumPore =lenSumPore+...
                    (throatProp.lenPoreOne+throatProp.lenPoreTwo)/2.0;
                if throatProp.poreOne == -1 || throatProp.poreTwo == -1
                    obj.m_numInletThroats = obj.m_numInletThroats +1;
                end
            end
            fclose(obj.m_throatConn);
            fclose(obj.m_throatProp);
            obj.m_averageThroatLength = lenSumThroat/obj.m_origNumThroats;
            obj.m_averagePoreHalfLength = lenSumPore/obj.m_origNumThroats;
            if obj.m_addPeriodicBC
                index = obj.m_origNumThroats+1;
                for conn = 0:obj.m_pbcData-1  % conn从0开始
                    pbcThroat = obj.m_ThroatStruct;
                    randNum = rand();
                    randThroatIdx = randNum*obj.m_origNumThroats;
                    if randThroatIdx >= obj.m_origNumThroats
                        randThroatIdx = obj.m_origNumThroats-1;
                    end
                    pbcThroat.clayVol = 0.0;
                    index = index+1;
                    pbcThroat.index = index;
                    pbcThroat.poreOne = obj.m_pbcData{conn+1}.first(); % +1
                    pbcThroat.poreTwo = obj.m_pbcData{conn+1}.second();% +1
                    pbcThroat.radius = obj.m_throatData{randThroatIdx}.radius;
                    pbcThroat.shapeFact = obj.m_throatData{randThroatIdx}.shapeFact;
                    pbcThroat.volume = 0.0;
                    if obj.m_useAvrPbcThroatLen || ...
                            obj.m_pbcData{conn+1}.third() == 0.0
                        pbcThroat.lenPoreOne = obj.m_averagePoreHalfLength;
                        pbcThroat.lenPoreTwo = obj.m_averagePoreHalfLength;
                        pbcThroat.lenThroat = obj.m_averageThroatLength;
                        pbcThroat.lenTot = obj.m_averageThroatLength+...
                            2.0*obj.m_averagePoreHalfLength;
                    else
                        pbcThroat.lenTot = obj.m_pbcData{conn+1}.third();
                        pbcThroat.lenThroat = obj.m_pbcData{conn+1}.third()...
                            *(obj.m_averageThroatLength/...
                            (obj.m_averageThroatLength+2.0*obj.m_averagePoreHalfLength));
                        pbcThroat.lenPoreOne = (pbcThroat.lenTot-...
                            pbcThroat.lenThroat)/2.0;
                        pbcThroat.lenPoreTwo = (pbcThroat.lenTot-...
                            pbcThroat.lenThroat)/2.0;
                    end
                    obj.m_throatData{end+1} = pbcThroat;
                    obj.appendPoreData(pbcThroat.poreOne,pbcThroat.index,...
                        pbcThroat.poreTwo);
                    obj.appendPoreData(pbcThroat.poreTwo,pbcThroat.index,...
                        pbcThroat.poreOne);
                end
                obj.m_origNumThroats =obj.m_origNumThroats+size(obj.m_pbcData,2);
            end
            addedInletThroats = [];
            if obj.m_numNetInSeries>1
                for outT = 1:obj.m_origNumThroats
                    if obj.m_throatData{outT}.poreOne == 0 ||...
                            obj.m_throatData{outT}.poreTwo == 0
                        if obj.m_throatData{outT}.poreOne == 0
                            outFacePore = obj.m_throatData{outT}.poreTwo;
                        else
                            outFacePore = obj.m_throatData{outT}.poreOne;
                        end
                        xPos = obj.m_poreData{outFacePore-1}.first().x -...
                            obj.m_origXDim - obj.m_networkSeparation;
                        yPos = obj.m_poreData{outFacePore-1}.first().y;
                        zPos = obj.m_poreData{outFacePore-1}.first().z;
                        p2pLength = 0;
                        inFacePore = obj.findClosestPore(obj.m_inletPores,...
                            xPos, yPos, zPos, p2pLength);
                        outEntry = ThreeSome(outT+1,inFacePore, p2pLength);
                        inEntry = ThreeSome(outT+1,outFacePore, p2pLength);
                        obj.MultiConnValType = containers.Map(inFacePore, inEntry);
                        obj.m_inletConnections{end+1}=obj.MultiConnValType;
                        obj.MultiConnValType = containers.Map(outFacePore, outEntry);
                        obj.m_outletConnections{end+1}=obj.MultiConnValType;
                    end
                end
                for inT = 1:obj.m_origNumThroats
                    if obj.m_throatData{inT}.poreOne == -1 || ...
                            obj.m_throatData{inT}.poreTwo == -1
                        if obj.m_throatData{inT}.poreOne == -1
                            inFacePore = obj.m_throatData{inT}.poreTwo;
                        else
                            inFacePore = obj.m_throatData{inT}.poreOne;
                        end
                        if ismember(inFacePore,obj.m_inletConnections) == 0
                            addedInletThroats{end+1} = inT+1;
                            xPos = obj.m_poreData{inFacePore-1}.first().x...
                                + obj.m_origXDim + obj.m_networkSeparation;
                            yPos = obj.m_poreData{inFacePore-1}.first().y;
                            zPos = obj.m_poreData{inFacePore-1}.first().z;
                            p2pLength = 0;
                            outFacePore = obj.findClosestPore...
                                (obj.m_outletPores, xPos, yPos, zPos, p2pLength);
                            outEntry = ThreeSome(inT+1,inFacePore, p2pLength);
                            inEntry = ThreeSome(inT+1,outFacePore, p2pLength);
                            obj.MultiConnValType = containers.Map(inFacePore, inEntry);
                            obj.m_inletConnections{end+1}=obj.MultiConnValType;
                            obj.MultiConnValType = containers.Map(outFacePore, outEntry);
                            obj.m_outletConnections{end+1}=obj.MultiConnValType;
                        else
                            obj.m_connectionsRemoved=obj.m_connectionsRemoved+1;
                        end
                    end
                    
                end
            end
            runningIndex = -1+1;  % +1
            % Since inlet throats do not exist in serial nets, we end up
            % having to take into accountan offset for the indecies
            obj.m_throatHash = cell(1,obj.m_origNumThroats-...
                obj.m_connectionsRemoved);
            for j = 1+1: obj.m_origNumThroats+1  % +1
                if (obj.m_throatData{j-1}.poreOne ~= -1 && ...
                        obj.m_throatData{j-1}.poreTwo ~= -1) ||...
                        ismember(j,addedInletThroats) > 0
                    runningIndex = runningIndex+1;
                    obj.m_throatHash{runningIndex} = j;
                end
            end
            runningIndex = 1+1;
            obj.m_reverseThroatHash = cell(1,obj.m_origNumThroats);
            for k =1: obj.m_origNumThroats
                hashedIdx = obj.DUMMY_INDEX;
                if (obj.m_throatData{k}.poreOne ~= -1 && ...
                        obj.m_throatData{k}.poreTwo ~= -1) ||...
                        ismember(k+1,addedInletThroats)> 0
                    
                    hashedIdx = runningIndex;
                    runningIndex = runningIndex+1;
                end
                obj.m_reverseThroatHash{k} = hashedIdx;
            end
        end
        
        function index = findClosestPore(obj,pores,Pos,yPos,zPos,totalLen)
            totalLen = 1.0e21;
            index = obj.DUMMY_INDEX;
            for i = 1:size(pore,2)
                len = sqrt(power(xPos-pores{i}.first().x, 2.0)+...
                    power(yPos-pores{i}.first().y, 2.0)+...
                    power(zPos-pores{i}.first().z, 2.0));
                if len<totalLen
                    totalLen = len;
                    index = pores{i}.first().index;
                end
            end
            assert(index ~= obj.DUMMY_INDEX);
        end
        
        
        function appendPoreData(obj,thisPoreIdx,throatIdx,thatPoreIdx)
            oldConnNum = obj.m_poreData{thisPoreIdx-1}.first().connNum;
            temp1 = obj.m_poreData{thisPoreIdx-1}.second();
            temp2 = obj.m_poreData{thisPoreIdx-1}.third();
            for i = 1:oldConnNum                
                newPoreConnList{i} = temp1{i};                
                newThroatConnList{i} = temp2{i};
            end
            newPoreConnList{oldConnNum} = thatPoreIdx;
            newThroatConnList{oldConnNum} = throatIdx;
            obj.m_poreData{thisPoreIdx-1}.first().connNum=...
                obj.m_poreData{thisPoreIdx-1}.first().connNum+1;
            % obj.m_poreData{thisPoreIdx-1}.second()=[];
            % obj.m_poreData{thisPoreIdx-1}.third() =[];
            obj.m_poreData{thisPoreIdx-1}.second(newPoreConnList);
            obj.m_poreData{thisPoreIdx-1}.third(newPoreConnList);
        end
        
        % As the pores are created the data is read from file and supplied
        % back together with contact angles that are stored in vectors.        
        % The format of pore network files are:
        % *_node1.dat:
        % index, x_pos, y_pos, z_pos, connection num, connecting nodes...,
        % at inlet?, at outlet?, connecting links...
        % *_node2.dat:
        % index, volume, radius, shape factor, clay volume
        function loadPoreData(obj)
            obj.m_poreData = cell(1,obj.m_origNumPores);
            for i = 1:obj.m_origNumPores  % +1
                if (~obj.m_binaryFiles && ~obj.m_poreConn)||~obj.m_poreProp
                    error('Error while reading network data.\r\n');
                end
                poreProp = obj.m_PoreStruct;
                if obj.m_binaryFiles  % 有问题，但是目前没有进入这个判断，先不管
                    poreProp = fread(obj.m_poreProp,1);
                    connPores = fread(obj.m_poreProp,[1,poreProp.connNum+1]);
                    connThroats = fread(obj.m_poreProp,[1,poreProp.connNum+1]);
                else
                    tline = fgetl(obj.m_poreProp);
                    data = str2num(tline);
                    poreProp.index = data(1);
                    poreProp.volume = data(2);
                    poreProp.radius = data(3);
                    poreProp.shapeFact = data(4);
                    poreProp.clayVol = data(5);
                    
                    tline = fgetl(obj.m_poreConn);
                    data = str2num(tline);
                    idx = data(1);
                    poreProp.x = data(2);
                    poreProp.y = data(3);
                    poreProp.z = data(4);
                    poreProp.connNum = data(5);
                    assert(idx == poreProp.index);
                    
                    for k = 5+1:5+poreProp.connNum  % 5是上面的data(5)中的5，+1
                        connPores{k-5} = data(k);
                    end
                    
                    isAtInletRes = logical(data(5+poreProp.connNum+1));
                    isAtOutletRes = logical(data(5+poreProp.connNum+2));
                    
                    for j=5+poreProp.connNum+2+1:...
                            5+poreProp.connNum+2+poreProp.connNum  % +1
                        connThroats{j-(5+poreProp.connNum+2)} = data(j);
                    end
                end
                elem = ThreeSome(poreProp, connPores, connThroats);
                obj.m_poreData{i} = elem;
                for conn = 0+1:poreProp.connNum % +1
                    if connPores{conn} == -1
                        obj.m_inletPores{end+1} = elem;
                    elseif connPores{conn} == 0
                        obj.m_outletPores{end+1} = elem;
                    end
                end
            end
            if obj.m_addPeriodicBC
                obj.findBoundaryPores();
            end
            fclose(obj.m_poreProp);
            fclose(obj.m_poreConn);
        end
        
        function findBoundaryPores(obj)
            nDir = power(obj.m_origNumPores, 1.0/3.0)+1;
            xStep = obj.m_origXDim/nDir;
            yStep = obj.m_origYDim/nDir;
            zStep = obj.m_origZDim/nDir;
            for i = 1:nDir
                xPos = xStep/2.0 + i*xStep;
                assert(xPos < obj.m_origXDim);
                for j = 1:nDir
                    yPos = yStep/2.0 + j*yStep;
                    zPos = zStep/2.0 + j*zStep;
                    assert(xPos < obj.m_origXDim && yPos < obj.m_origYDim...
                        && zPos < obj.m_origZDim);
                    xyMinus = ThreeSome(xPos, yPos, 0.0);
                    positonData{end+1} = xyMinus;
                    xyPluss = ThreeSome(xPos, yPos, obj.m_origZDim);
                    positonData{end+1 }= xyPluss;
                    xzMinus = ThreeSome(xPos, 0, zPos);
                    positonData{end+1 }= xzMinus;
                    xzPluss = ThreeSome(xPos,obj.m_origYDim, zPos);
                    positonData{end+1 }= xzPluss;
                    
                    poreIndecies = [];
                    p2BdrLength = [];
                    obj.findClosestPoreForPBC(positonData, poreIndecies,...
                        p2BdrLength);
                    poreIndecies = evalin('base','poreIndecies');
                    p2BdrLength = evalin('base','p2BdrLength');
                    xyConn = containers.Map(poreIndecies{0+1},...
                        poreIndecies{1+1});  % +1
                    xzConn = containers.Map(poreIndecies{2+1},...
                        poreIndecies{3+1});  % +1
                    if xyConn.first ~= xyConn.second &&...
                            ismember(xyConn,obj.m_xyPbcConn) == 0  % Detect 2D networks and duplicates
                        % 先用ismember吧
                        pbcConn = ThreeSome(xyConn.first, xyConn.second,...
                            p2BdrLength{0+1}+p2BdrLength{1+1});  %两个都 +1
                        obj.m_pbcData{end+1} = pbcConn;
                    end
                    if xzConn.first ~= xzConn.second &&...
                            ismember(xzConn,obj.m_xzPbcConn) == 0
                        pbcConn = ThreeSome(xzConn.first, xzConn.second,...
                            p2BdrLength{2+1}+p2BdrLength{3+1});  %两个都 +1
                        obj.m_pbcData{end+1} = pbcConn;
                    end
                    
                    obj.m_xyPbcConn{end+1} = xyConn;
                    obj.m_xzPbcConn{end+1} = xzConn;
                end
            end
            
        end
        
        function findClosestPoreForPBC(obj,positonData,poreIndecies,p2BdrLength)
            poreIndecies = cell(1,size(positonData,2));
            p2BdrLength = cell(1,size(positonData,2));
            p2BdrLength(:) = {1.0e21};
            for i = 1:size(obj.m_poreData,2)
                for j = 1:size(positonData,2)
                    len = sqrt...
                        (power(positonData{j}.first()...
                        -obj.m_poreData{i}.first().x, 2.0)+...
                        power(positonData{j}.second()...
                        -obj.m_poreData{i}.first().y, 2.0)+...
                        power(positonData{j}.third()...
                        -obj.m_poreData{i}.first().z, 2.0));
                    if len < p2BdrLength{j}
                        p2BdrLength{j} = len;
                        poreIndecies{j} = i+1;
                    end
                end
            end
            assignin('base','poreIndecies',poreIndecies);
            assignin('base','p2BdrLength',p2BdrLength);
        end
        
        %PoreStruct=struct('index',[],'x',[],'y',[]);
        
        % Returns error message when required keyword is missing
        function missingDataErr(obj,keyword)
            error('Error: %s is a required keyword.\r\n',keyword);
        end
        
        function [intFaceTen,watVisc,oilVisc,watResist,oilResist,watDens,oilDens]...
                = fluid(obj,intFaceTen,watVisc,oilVisc,watResist,...
                oilResist,watDens,oilDens)
            keyword = 'FLUID';
            data = [];
            if obj.getData(data, keyword)
                fprintf('Reading %s\r\n',keyword);
                data = evalin('base','data');
                datar = regexp(data,'\s+','split');
                datar(cellfun(@isempty,datar))=[];
                intFaceTen = datar{1};
                watVisc = datar{2};
                oilVisc = datar{3};
                watResist = datar{4};
                oilResist = datar{5};
                watDens = datar{6};
                oilDens = datar{7};
                if isempty(data)
                    obj.errorMsg(keyword);
                end
                obj.errorInDataCheck(data, keyword);
                intFaceTen =intFaceTen*1.0E-3;       % Get it into N/m
                watVisc =watVisc * 1.0E-3;           % Get it into Pa.s
                oilVisc =oilVisc * 1.0E-3;           % Get it into Pa.s
            else
                intFaceTen = 30.0E-3;
                watVisc = 1.0E-3;
                oilVisc = 1.0E-3;
                watResist = 1.0;
                oilResist = 1000.0;
                watDens = 1000.0;
                oilDens = 1000.0;
            end
        end
        
        function [minNumFillings,initStepSize,cutBack,maxIncrFact,stable]...
                =satConvergence(obj,minNumFillings,initStepSize,cutBack,...
                maxIncrFact,stable)
            data = [];
            keyword = 'SAT_COVERGENCE';
            stab = 'F';
            if obj.getData(data, keyword)
                fprintf('Reading %s\r\n',keyword);
                data = evalin('base','data');
                datar = regexp(data,'\s+','split');
                datar(cellfun(@isempty,datar))=[];
                minNumFillings = datar{1};
                initStepSize = datar{2};
                cutBack = datarr(3);
                maxIncrFact = datar{4};
                stab = datar{5};
                stable = stab == 'T' || stab == 't';
                if isempty(data)
                    obj.errorMsg(keyword);
                end
                obj.errorInDataCheck(data, keyword);
            else
                stable = false;
                minNumFillings = 10;
                initStepSize = 0.1;
                cutBack = 0.8;
                maxIncrFact = 2.0;
            end
        end
        
        % Filling weights:
        % Oren1/2 = 0.0, 0.5, 1.0, 5.0, 10.0, 50.0
        % Blunt2  = 0.0, 15000, 15000, 15000, 15000, 15000
        % Blunt1  = 0.0, 50E-6, 50E-6, 100E-6, 200E-6, 500E-6
        function weights = poreFillWgt(obj,weights)
            data = [];
            keyword = 'PORE_FILL_WGT';
            weights = cell(1,6);
            if obj.getData(data, keyword)
                fprintf('Reading %s\r\n',keyword);
                data = evalin('base','data');
                datar = regexp(data,'\s+','split');
                datar(cellfun(@isempty,datar))=[];
                weights{1}=datar{1};
                weights{2}=datar{2};
                weights{3}=datar{3};
                weights{4}=datar{4};
                weights{5}=datar{5};
                weights{6}=datar{6};
                if isempty(data)
                    obj.errorMsg(keyword);
                end
                obj.errorInDataCheck(data, keyword);
            else
                weights{1} = 0.0;
                weights{2} = 15000.0;
                weights{3} = 15000.0;
                weights{4} = 15000.0;
                weights{5} = 15000.0;
                weights{6} = 15000.0;
            end
        end
        
        function [eps,scaleFact,slvrOutput,verbose,condCutOff]=...
                solverTune(obj,eps,scaleFact,slvrOutput,verbose,condCutOff)
            data =[];
            verb = 'F';
            keyword = 'SOLVER_TUNE';
            if obj.getData(data, keyword)
                fprintf('Reading %s\r\n',keyword);
                data = evalin('base','data');
                datar = regexp(data,'\s+','split');
                datar(cellfun(@isempty,datar))=[];
                eps = datar{1};
                scaleFact = datar{2};
                slvrOutput = datar{3};
                verb = datar{4};
                condCutOff = datar{5};
                verbose = verb == 'T' || verb == 't';
                if isempty(data)
                    obj.errorMsg(keyword);
                end
                obj.errorInDataCheck(data, keyword);
            else
                eps = 1.0E-15;
                scaleFact = 5;
                slvrOutput = 0;
                condCutOff = 0.0;
                verbose = false;
            end
        end
        
        function clayEditFact = clayEdit(obj,clayEditFact)
            data = [];
            keyword = 'CLAY_EDIT';
            if obj.getData(data, keyword)
                fprintf('Reading %s\r\n',keyword);
                data = evalin('base','data');
                datar = regexp(data,'\s+','split');
                datar(cellfun(@isempty,datar))=[];
                clayEditFact = datar;
                if isempty(data)
                    obj.errorMsg(keyword);
                end
                obj.errorInDataCheck(data, keyword);
            else
                clayEditFact = 0.0;
            end
        end
        
        function algorithm = poreFillAlg(obj,algorithm)
            data =[];
            keyword = 'PORE_FILL_ALG';
            if obj.getData(data, keyword)
                fprintf('Reading %s\r\n',keyword);
                data = evalin('base','data');
                datar = regexp(data,'\s+','split');
                datar(cellfun(@isempty,datar))=[];
                algorithm = datar;
                if isempty(data)
                    obj.errorMsg(keyword);
                end
                obj.errorInDataCheck(data, keyword);
            else
                algorithm = 'blunt2';
            end
        end
        
        function [usePrsBdr,reportPrsBdr,numPlanes]=...
                prsBdrs(obj,usePrsBdr,reportPrsBdr,numPlanes)
            data = [];
            keyword = 'PRS_BDRS';
            if obj.getData(data, keyword)
                fprintf('Reading %s\r\n',keyword);
                data = evalin('base','data');
                datar = regexp(data,'\s+','split');
                datar(cellfun(@isempty,datar))=[];
                usePrs = datar{1};
                numPl = datar{2};
                numPlanes = datar{3};
                usePrsBdr = usePrs == 'T' || usePrs == 't';
                reportPrsBdr = numPl == 'T' || numPl == 't';
                if ~reportPrsBdr
                    numPlanes = 0;
                end
                if isempty(data)
                    obj.errorMsg(keyword);
                end
                obj.errorInDataCheck(data, keyword);
            else
                usePrsBdr = false;
                reportPrsBdr = false;
                numPlanes = 0;
            end
        end
        
        function reportMatBal = matBal(obj,reportMatBal)
            data = [];
            keyword = 'MAT_BAL';
            if obj.getData(data, keyword)
                fprintf('Reading %s\r\n',keyword);
                data = evalin('base','data');
                datar = regexp(data,'\s+','split');
                datar(cellfun(@isempty,datar))=[];
                mb = datar;
                reportMatBal = mb == 'T' || mb == 't';
                if isempty(data)
                    obj.errorMsg(keyword);
                end
                obj.errorInDataCheck(data, keyword);
            else
                reportMatBal = false;
            end
        end
        
        function [injEntry,injExit,drainEnds,circWatCondMultFact]=...
                trapping(obj,injEntry,injExit,drainEnds,circWatCondMultFact)
            data = [];
            keyword = 'TRAPPING';
            if obj.getData(data, keyword)
                fprintf('Reading %s\r\n',keyword);
                data = evalin('base','data');
                datar = regexp(data,'\s+','split');
                datar(cellfun(@isempty,datar))=[];
                fromEntry = datar{1};
                fromExit = datar{2};
                drnEnds = datar{3};
                circWatCondMultFact = datar{4};
                injEntry = fromEntry == 'T' || fromEntry == 't';
                injExit = fromExit == 'T' || fromExit == 't';
                drainEnds = drnEnds == 'T' || drnEnds == 't';
                if isempty(data)
                    obj.errorMsg(keyword);
                end
                obj.errorInDataCheck(data, keyword);
            else
                injEntry = true;
                injExit = false;
                drainEnds = true;
                circWatCondMultFact = 0.0;
            end
        end
        
        function doApexAnalysis=apexPrs(obj,doApexAnalysis)
            data = [];
            keyword = 'APEX_PRS';
            if obj.getData(data, keyword)
                fprintf('Reading %s\r\n',keyword);
                data = evalin('base','data');
                datar = regexp(data,'\s+','split');
                datar(cellfun(@isempty,datar))=[];
                apex = datar;
                doApexAnalysis = apex == 'T' || apex == 't';
                if isempty(data)
                    obj.errorMsg(keyword);
                end
                obj.errorInDataCheck(data, keyword);
            else
                doApexAnalysis = false;
            end
        end
        
        function [gravX,gravY,gravZ]=gravityConst(obj,gravX,gravY,gravZ)
            data =[];
            keyword = 'GRAV_CONST';
            if obj.getData(data, keyword)
                fprintf('Reading %s\r\n',keyword);
                data = evalin('base','data');
                datar = regexp(data,'\s+','split');
                datar(cellfun(@isempty,datar))=[];
                gravX=datar{1};
                gravY=datar{2};
                gravZ=datar{3};
                if isempty(data)
                    obj.errorMsg(keyword);
                end
                obj.errorInDataCheck(data, keyword);
            else
                gravX = 0.0;
                gravY = 0.0;
                gravZ = -9.81;
            end
        end
        
        function [flowRef,strictTrpCond]=relPermDef(obj,flowRef,strictTrpCond)
            data = [];
            keyword = 'RELPERM_DEF';
            if obj.getData(data, keyword)
                fprintf('Reading %s\r\n',keyword);
                data = evalin('base','data');
                datar = regexp(data,'\s+','split');
                datar(cellfun(@isempty,datar))=[];
                flowRef = datar{1};
                cond = datar{2};
                strictTrpCond = cond == 't' || cond == 'T';
                if isempty(data)
                    obj.errorMsg(keyword);
                end
                obj.errorInDataCheck(data, keyword);
            else
                flowRef = 'single';
                strictTrpCond = true;
            end
        end
        
        function shaveSetting = aCloseShave(obj,shaveSetting)
            data =[];
            keyword = 'A_CLOSE_SHAVE';
            if obj.getData(data, keyword)
                fprintf('Reading %s\r\n',keyword);
                data = evalin('base','data');
                datar = regexp(data,'\s+','split');
                datar(cellfun(@isempty,datar))=[];
                shaveSetting = datar;
                if isempty(data)
                    obj.errorMsg(keyword);
                end
                obj.errorInDataCheck(data, keyword);
            else
                shaveSetting = 1.0;
            end
        end
        
        function [watMat,oilMat,resMat,watVel,oilVel,resVel,fileName,...
                matlab,initOnly]=solverDebug(obj,watMat,oilMat,resMat,...
                watVel,oilVel,resVel,fileName,matlab,initOnly)
            data = [];
            keyword = 'SOLVER_DBG';
            if obj.getData(data, keyword)
                fprintf('Reading %s\r\n',keyword);
                data = evalin('base','data');
                datar = regexp(data,'\s+','split');
                datar(cellfun(@isempty,datar))=[];
                writeWat = datar{1};
                writeOil = datar{2};
                writeRes = datar{3};
                writeWatVel = datar{4};
                writeOilVel = datar{5};
                writeResVel = datar{6};
                fileName = datar{7};
                mat = datar{8};
                forInit = datar{9};
                watMat = (writeWat == 'T' || writeWat == 't');
                oilMat = (writeOil == 'T' || writeOil == 't');
                resMat = (writeRes == 'T' || writeRes == 't');
                watVel = (writeWatVel == 'T' || writeWatVel == 't');
                oilVel = (writeOilVel == 'T' || writeOilVel == 't');
                resVel = (writeResVel == 'T' || writeResVel == 't');
                matlab = (mat == 'T' || mat == 't');
                initOnly = (forInit == 'T' || forInit == 't');
                if isempty(data)
                    obj.errorMsg(keyword);
                end
                obj.errorInDataCheck(data, keyword);
            else
                watMat = false;
                oilMat = false;
                resMat = false;
                watVel = false;
                oilVel = false;
                resVel = false;
                matlab = false;
                initOnly = false;
                fileName = 'nothing';
            end
        end
        
        function [drainage,imbibition,location]=...
                fillingList(obj,drainage,imbibition,location)
            data = [];
            keyword = 'FILLING_LIST';
            if obj.getData(data, keyword)
                fprintf('Reading %s\r\n',keyword);
                data = evalin('base','data');
                datar = regexp(data,'\s+','split');
                datar(cellfun(@isempty,datar))=[];
                drain = datar{1};
                imb = datar{2};
                loc = datar{3};
                drainage = (drain == 'T' || drain == 't');
                imbibition = (imb == 'T' || imb == 't');
                location = (loc == 'T' || loc == 't');
                if isempty(data)
                    obj.errorMsg(keyword);
                end
                obj.errorInDataCheck(data, keyword);
            else
                drainage = false;
                imbibition = false;
                location = false;
            end
        end
        
        function [inletPrs,outletPrs,useGravInKr]=...
                prsDiff(obj,inletPrs, outletPrs,useGravInKr)
            data = [];
            keyword = 'PRS_DIFF';
            if obj.getData(data, keyword)
                fprintf('Reading %s\r\n',keyword);
                data = evalin('base','data');
                datar = regexp(data,'\s+','split');
                datar(cellfun(@isempty,datar))=[];
                inletPrs = datar{1};
                outletPrs = datar{2};
                grav = datar{3};
                useGravInKr = (grav == 'T' || grav == 't');
                if isempty(data)
                    obj.errorMsg(keyword);
                end
                obj.errorInDataCheck(data, keyword);
            else
                inletPrs = 1.0;
                outletPrs = 0.0;
                useGravInKr = false;
            end
        end
        
        function [wettClass,min,max,delta,eta,distModel,sepAng]=...
                equilConAng(obj,wettClass,min,max,delta,eta,distModel,sepAng)
            data = [];
            keyword = 'EQUIL_CON_ANG';
            if obj.getData(data, keyword)
                fprintf('Reading %s\r\n',keyword);
                data = evalin('base','data');
                datar = regexp(data,'\s+','split');
                datar(cellfun(@isempty,datar))=[];
                wettClass = datar{1};
                min = datar{2};
                max = datar{3};
                delta = datar{4};
                eta = datar{5};
                if isempty(data)
                    obj.errorMsg(keyword);
                end
                distModel = datar{6};
                if isempty(data)
                    distModel = 'rand';
                end
                sepAng = datar{7};
                if isempty(data)
                    sepAng = 25.2;
                end
                obj.errorInDataCheck(data, keyword);
                min =min* acos(-1.0) / 180.0;
                max =max * acos(-1.0) / 180.0;
                sepAng =sepAng * acos(-1.0) / 180.0;
            else
                missingDataErr = keyword;
            end
        end
        
        function sourceNode = sourceNode(obj,sourceNode)
            data = [];
            keyword = 'POINT_SOURCE';
            if obj.getData(data, keyword)
                fprintf('Reading %s\r\n',keyword);
                data = evalin('base','data');
                datar = regexp(data,'\s+','split');
                datar(cellfun(@isempty,datar))=[];
                sourceNode = datar;
                if isempty(data)
                    obj.errorMsg(keyword);
                end
                obj.errorInDataCheck(data, keyword);
            else
                sourceNode = 0;
            end
        end
        
        function getRadDist(obj,data,model,options)
            
        end
        
        function addData(obj,keyword,data)
            %METHOD1 此处显示有关此方法的摘要
            %   此处显示详细说明
            obj.m_parsedData{end+1}([keyword, data]);
        end
        
        function xPos = poreLocation(obj,idx,xPos)
            stdIdx = idx;
            numNetsInFront = 0;
            if idx > obj.m_origNumPores+1    % +1
                numNetsInFront = (idx-1)/(obj.m_origNumPores+1);  % +1
                stdIdx = idx - numNetsInFront*(obj.m_origNumPores+1);
            end
            % PoreStruct *poreProp = m_poreData[stdIdx-1].first();  c++
            % inputData.cpp  line:1133
            poreProp = obj.m_poreData{stdIdx-1}.m_first;  % 这是我调出来的2022.5.26
            xPos=poreProp.x+numNetsInFront*(obj.m_origXDim+obj.m_networkSeparation);
        end
        
        function [min,max,delta,eta]=initConAng(obj,min,max,delta,eta)
            data = [];
            keyword = 'INIT_CON_ANG';
            if obj.getData(data, keyword)
                fprintf('Reading %s\r\n',keyword);
                data = evalin('base','data');
                datar = regexp(data,'\s+','split');
                datar(cellfun(@isempty,datar))=[];
                % data = textscan(data,'%f');
                min = datar{1};
                max = datar{2};
                delta = datar{3};
                eta = datar{4};
                min = min * acos(-1.0) / 180.0;
                max = max * acos(-1.0) / 180.0;
                if isempty(data)
                    obj.errorMsg(keyword);
                end
                obj.errorInDataCheck(data, keyword);
            else
                min = 0.0;
                max = 0.0;
                delta = 0.2;
                eta = 3.0;
            end
        end
        
        function [pore1,pore2,vol,volCl,rad,shapeFact,lenPore1,lenPore2,...
                lenThroat,lenTot]=throatData(obj,idx,pore1,pore2,vol,volCl,...
                rad,shapeFact,lenPore1,lenPore2,lenThroat,lenTot)
            stdIdx = idx;
            numNetsInFront = 0;
            if idx > obj.m_origNumThroats+1   %+1
                numNetsInFront = 1+(idx-obj.m_origNumThroats-1)/...
                    (obj.m_origNumThroats-obj.m_connectionsRemoved);
                tmpIdx = idx - numNetsInFront*obj.m_origNumThroats + ...
                    (numNetsInFront-1)*obj.m_connectionsRemoved;
                stdIdx = obj.m_throatHash{tmpIdx-1};
            end
            pore1 = obj.m_throatData{stdIdx-1}.poreOne;
            pore2 = obj.m_throatData{stdIdx-1}.poreTwo;
            vol = obj.m_throatData{stdIdx-1}.volume;
            volCl = obj.m_throatData{stdIdx-1}.clayVol;
            rad = obj.m_throatData{stdIdx-1}.radius;
            shapeFact = obj.m_throatData{stdIdx-1}.shapeFact;
            lenPore1 = obj.m_throatData{stdIdx-1}.lenPoreOne;
            lenPore2 = obj.m_throatData{stdIdx-1}.lenPoreTwo;
            lenThroat = obj.m_throatData{stdIdx-1}.lenThroat;
            lenTot = obj.m_throatData{stdIdx-1}.lenTot;
            % Point to correct pores in the subsequent networks
            if idx > obj.m_origNumThroats+1   % +1
                if(pore1 ~= 0 && pore1 ~= -1)
                    pore1 = pore1+ numNetsInFront*obj.m_origNumPores;
                end
                if pore2 ~= 0 && pore2 ~= -1
                    pore2 = pore2+ numNetsInFront*obj.m_origNumPores;
                end
            end
            totalLength =[];
            mapPos_Index = containers.Map(0,0);
            inlet = false;
            good2go = false;
            
            if numNetsInFront ~= obj.m_numNetInSeries-1 &&...
                    obj.m_throatData{stdIdx-1}.poreOne == 0
                good2go = true;
                mo = obj.m_outletConnections;
                mt = obj.m_throatData{stdIdx-1}.poreTwo;
                % key = keys(mo);
                %                 if ~isempty(mo)
                %                     fprintf('mo is not empty');
                %                 end
                mapPos_Index = find(cellfun(@(x)isequaln(x,mt),keys(mo)));
                %                 try
                %                     mapPos = find(cellfun(@(x)isequaln(x,mt),keys(mo)));
                %                 catch
                %                     mapPos = [];
                %                 end
                moi = 'mo';
            elseif numNetsInFront ~= obj.m_numNetInSeries-1 &&...
                    obj.m_throatData{stdIdx-1}.poreTwo == 0
                good2go = true;
                mo = obj.m_outletConnections;
                mt = obj.m_throatData{stdIdx-1}.poreOne;
                %                 if ~isempty(mo)
                %                     fprintf('mo is not empty');
                %                 end
                mapPos_Index = find(cellfun(@(x)isequaln(x,mt),keys(mo)));
                %                 try
                %                     mapPos = find(cellfun(@(x)isequaln(x,mt),mo));
                %                 catch
                %                     mapPos = [];
                %                 end
                moi = 'mo';
            elseif numNetsInFront > 0 &&...
                    obj.m_throatData{stdIdx-1}.poreOne == -1
                good2go = true;
                inlet = true;
                mi = obj.m_inletConnections;
                mt = obj.m_throatData{stdIdx-1}.poreTwo;
                %                 if ~isempty(mo)
                %                     fprintf('mo is not empty');
                %                 end
                mapPos_Index = find(cellfun(@(x)isequaln(x,mt),keys(mi)));
                %                 try
                %                     mapPos = find(cellfun(@(x)isequaln(x,mt),mo));
                %                 catch
                %                     mapPos = [];
                %                 end
                moi = 'mi';
            elseif numNetsInFront > 0 &&...
                    obj.m_throatData{stdIdx-1}.poreTwo == -1
                good2go = true;
                inlet = true;
                mi = obj.m_inletConnections;
                mt = obj.m_throatData{stdIdx-1}.poreOne;
                %                 if ~isempty(mo)
                %                     fprintf('mo is not empty');
                %                 end
                mapPos_Index = find(cellfun(@(x)isequaln(x,mt),keys(mi)));
                %                 try
                %                     mapPos = find(cellfun(@(x)isequaln(x,mt),mo));
                %                 catch
                %                     mapPos = [];
                %                 end
                moi = 'mi';
            end
            moilength = length(mapPos_Index);
            if good2go
                if strcmp(moi,'mo')
                    for i = 1:moilength
                        moi_select{i} = obj.m_outletConnections{mapPos_Index(i)};
                    end
                else
                    for i = 1:moilength
                        moi_select{i} = obj.m_inletConnections{mapPos_Index(i)};
                    end
                end
                
                % poreProp = obj.m_poreData{stdIdx-1}.m_first;  % 这是我调出来的
                i = 1;
                while ~isequal(moi_select{i},moi_select{i+1})
                    moi_selectivalues = moi_select{i}.values;
                    if(moi_selectivalues.first()==stdIdx)
                        poreIdx = moi_selectivalues.second();
                    end
                    if inlet
                        poreIdx =poreIdx+(numNetsInFront-1)*obj.m_origNumPores;
                    else
                        poreIdx =poreIdx+(numNetsInFront+1)*obj.m_origNumPores;
                    end
                    totalLength = moi_selectivalues.third();
                    if obj.m_throatData{stdIdx-1}.poreOne == 0 ||...
                            obj.m_throatData{stdIdx-1}.poreOne == -1
                        pore1 = poreIdx;
                        lenPore1 = lenPore2;
                    else
                        pore2 = poreIdx;
                        lenPore2 = lenPore1;
                    end
                    i = i+1;
                end
                if obj.m_useAvrXOverThroatLen
                    lenThroat = obj.m_averageThroatLength;
                    lenTot = 2.0*lenPore2 + lenThroat;
                elseif totalLength > 2.0*lenPore2
                    lenTot = totalLength;
                    lenThroat = totalLength - 2.0*lenPore2;
                else
                    lenPore1 = 1.0E-8;
                    lenPore2 = 1.0E-8;
                    lenThroat = 1.0E-8;
                    lenTot = 3.0E-8;
                end
                % Oren networks have 0 volume for in/outlet throats
                % Assign volume based on a tube
                xSectArea = power(rad, 2.0) / (4.0*shapeFact);
                vol = lenThroat*xSectArea;
            end
        end
        
        function [xPos,yPos,zPos,connNum,connThroats,connPores,vol,volCl,...
                rad,shapeFact]=poreData(obj,idx,xPos,yPos,zPos,connNum,...
                connThroats,connPores,vol,volCl,rad,shapeFact)
            stdIdx = idx;
            numNetsInFront = 0;
            if idx > obj.m_origNumPores+1  % +1
                numNetsInFront = (idx-1)/(obj.m_origNumPores+1);
                stdIdx = idx - numNetsInFront*(obj.m_origNumPores+1);
            end
            poreProp = obj.m_poreData{stdIdx-1}.m_first();
            xPos = poreProp.x + ...
                numNetsInFront*(obj.m_origXDim+obj.m_networkSeparation);
            yPos = poreProp.y;
            zPos = poreProp.z;
            connNum = poreProp.connNum;
            vol = poreProp.volume;
            volCl = poreProp.clayVol;
            rad = poreProp.radius;
            shapeFact = poreProp.shapeFact;
            connThroats = cell(1,connNum);
            connPores = cell(1,connNum);
            outletPore = false;
            inletPore = false;
            temp1 = obj.m_poreData{stdIdx-1}.m_second;
            temp2 = obj.m_poreData{stdIdx-1}.m_third();
            for i = 0+1:connNum  % +1                
                connPores{i} = temp1{i};                
                connThroats{i} = temp2{i};
                if connPores{i} ~=0 && connPores{i}~=-1 && numNetsInFront>0
                    connPores{i}=connPores{i}+numNetsInFront*obj.m_origNumPores;
                    throatStdIdx = obj.m_reverseThroatHash{connThroats{i}-1};
                    connThroats{i} = throatStdIdx + numNetsInFront*...
                        obj.m_origNumThroats - (numNetsInFront-1)*...
                        obj.m_connectionsRemoved;
                elseif connPores{i} == 0
                    outletPore = true;
                elseif connPores{i} == -1
                    inletPore = true;
                end
            end
            if obj.m_numNetInSeries > 1 && (outletPore || inletPore)
                numInst = 0;
                numHookedUp = 0;
                mapConns = [];
                
                mi = obj.m_inletConnections;
                mo = obj.m_outletConnections;
                if outletPore
                    mapConns=find(cellfun(@(x)isequaln(x,stdIdx),keys(mo)));
                    numInst = length(mapConns);
                    for i = 1:numInst
                        moi_select{i}=obj.m_outletConnections{mapConns(i)};
                    end
                else
                    mapConns = find(cellfun(@(x)isequaln(x,stdIdx),keys(mi)));
                    numInst = length(mapConns);
                    for i = 1:numInst
                        moi_select{i}=obj.m_inletConnections{mapConns(i)};
                    end
                end
                i = 1;
                for j = 0+1:connNum  % +1
                    if numNetsInFront < ...
                            obj.m_numNetInSeries-1 && connPores{j} == 0
                        assert(~isequal(moi_select{i},moi_select{i+1}));
                        [connThroats{j},connPores{j}] =obj.getOutletData...
                            (moi_select{i},numNetsInFront,connThroats{j},connPores{j});
                        numHookedUp = numHookedUp+1;
                        i = i+1;
                    elseif numNetsInFront > 0 && connPores{j} == -1
                        assert(~isequal(moi_select{i},moi_select{i+1}));
                        [connThroats{j}, connPores{j}] =obj.getInletData...
                            (moi_select{i},numNetsInFront,connThroats{j},connPores{j});
                        numHookedUp = numHookedUp+1;
                        i = i+1;
                    elseif numNetsInFront > 0 && connPores{j} == 0
                        throatStdIdx = obj.m_reverseThroatHash{connThroats{j}-1};
                        connThroats{j} = throatStdIdx + numNetsInFront*...
                            obj.m_origNumThroats - (numNetsInFront-1)*...
                            obj.m_connectionsRemoved;
                    end
                end
                while ~isequal(moi_select{i},moi_select{i+1})
                    poreIdx = obj.DUMMY_INDEX;
                    throatIdx = obj.DUMMY_INDEX;%%%%%%%%%%%%%%%%%%%%%%%
                    if numNetsInFront<obj.m_numNetInSeries-1 && outletPore
                        [throatIdx,poreIdx]=obj.getOutletData...
                            (moi_select{i},numNetsInFront,throatIdx,poreIdx);
                    elseif numNetsInFront > 0 && inletPore
                        [throatIdx,poreIdx]=obj.getInletData...
                            (moi_select{i},numNetsInFront,throatIdx,poreIdx);
                    end
                    if poreIdx ~= obj.DUMMY_INDEX
                        connPores{end+1} = poreIdx;
                        connThroats{end+1} = throatIdx;
                        connNum = connNum+1;
                    end
                    i = i+1;
                    numHookedUp = numHookedUp+1;
                end
            end
        end
        
        function [throatIdx,thatIdx] = getOutletData...
                (obj,itr,numNetsInFront,throatIdx,thatIdx)
            value = values(itr);
            entry = value{1};
            thatIdx = entry.second()+obj.m_origNumPores*(numNetsInFront+1);
            throatToOutlet = obj.outletThroat(entry.first());
            throatToInlet = obj.inletThroat(entry.first());
            hashedIdx = entry.first();
            if numNetsInFront > 0 && throatToOutlet
                hashedIdx = obj.m_reverseThroatHash{hashedIdx-1} + ...
                    numNetsInFront*obj.m_origNumThroats - ...
                    (numNetsInFront-1)*obj.m_connectionsRemoved;
            elseif throatToInlet
                assert(obj.m_reverseThroatHash{hashedIdx-1}~=obj.DUMMY_INDEX);
                hashedIdx = obj.m_reverseThroatHash{hashedIdx-1} + ...
                    (numNetsInFront+1)*obj.m_origNumThroats - ...
                    numNetsInFront*obj.m_connectionsRemoved;
            end
            throatIdx = hashedIdx;
        end
        
        function [throatIdx,thatIdx]=getInletData...
                (obj,itr,numNetsInFront,throatIdx,thatIdx)
            value = values(itr);
            entry = value{1};
            thatIdx = entry.second()+obj.m_origNumPores*(numNetsInFront-1);
            throatToOutlet = obj.outletThroat(entry.first());
            throatToInlet = obj.inletThroat(entry.first());
            hashedIdx = entry.first();
            if numNetsInFront > 1 && throatToOutlet
                hashedIdx = obj.m_reverseThroatHash{hashedIdx-1}+...
                    (numNetsInFront-1)*obj.m_origNumThroats - ...
                    (numNetsInFront-2)*obj.m_connectionsRemoved;
            elseif throatToInlet
                hashedIdx = obj.m_reverseThroatHash{hashedIdx-1} + ...
                    numNetsInFront*obj.m_origNumThroats - ...
                    (numNetsInFront-1)*obj.m_connectionsRemoved;
            end
            throatIdx = hashedIdx;
        end
        
        function outletThroat = outletThroat(obj,throatIdx)
            throat = obj.m_throatData{throatIdx-1};
            outletThroat = throat.poreOne == 0 || throat.poreTwo == 0;
        end
        
        function inletThroat = inletThroat(obj,throatIdx)
            throat = obj.m_throatData{throatIdx-1};
            inletThroat = throat.poreOne == -1 || throat.poreTwo == -1;
        end
        
        % There is a lot of memory assosiated with storing all network data.
        % Best to clean up after ourself before proceeding
        function finishedLoadingNetwork(obj)
            for i = 1:size(obj.m_poreData,2)+1
                obj.m_poreData{i}.m_second = [];
                obj.m_poreData{i}.m_third = [];
                obj.m_poreData{i}.m_first = [];
            end
            for j = 1:size(obj.m_throatData,2)+1
                obj.m_throatData{j}= [];
            end
            clear obj.m_poreData;
            clear obj.m_throatData;
            clear obj.m_inletPores;
            clear obj.m_outletPores;
            clear obj.m_outletConnections;
            clear obj.m_inletConnections;
            clear obj.m_throatHash;
            clear obj.m_reverseThroatHash;
        end
    end
end

