classdef Netgen<handle
    %UNTITLED2 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        MAX_CONN_NUM
        m_porosity
        m_xDim
        m_yDim
        m_zDim
        m_outFileNameBase
        m_nX
        m_nY
        m_nZ
        m_numPores
        m_pores
        m_throats
        m_periodicBC
        m_averageThroatLength
        m_averConnectionNum
        m_actualConnectionNumber
        m_clayProportion
        m_throatRadWeibull
        m_throatLenWeibull
        m_aspectRatioWeibull
        m_triangleGWeibull
        m_throatShapeProp
        m_poreShapeProp
    end
    
    methods
        function obj = Netgen(fileName)
            %UNTITLED2 构造此类的实例
            %   此处显示详细说明
            netgendat = readcell(fileName);
            obj.MAX_CONN_NUM = 6;
            obj.m_outFileNameBase = netgendat{1,1};
            obj.m_nX = netgendat{2,1};
            obj.m_nY = netgendat{2,2};
            obj.m_nZ = netgendat{2,3};
            obj.m_periodicBC =netgendat{11,1}=='t' || netgendat{11,1}=='T';
            obj.m_averConnectionNum = netgendat{10,1};
            obj.m_clayProportion = netgendat{9,1};
            obj.m_throatRadWeibull = netgendat(3,:);
            obj.m_throatRadWeibull{1}=obj.m_throatRadWeibull{1}*1e-6;
            obj.m_throatRadWeibull{2}=obj.m_throatRadWeibull{2}*1e-6;

            obj.m_throatLenWeibull = netgendat(4,:);
            obj.m_throatLenWeibull{1}=obj.m_throatLenWeibull{1}*1e-6;
            obj.m_throatLenWeibull{2}=obj.m_throatLenWeibull{2}*1e-6;

            obj.m_aspectRatioWeibull = netgendat(5,:);
            obj.m_triangleGWeibull = netgendat(6,:);
            obj.m_poreShapeProp = netgendat(7,:);
            obj.m_throatShapeProp = netgendat(8,:);
            % obj.m_numPores = obj.m_nX * obj.m_nY * obj.m_nZ;
            obj.initNetworkModel();  % 需要加上obj.
        end
        
        % First pores are created. These are then connected by throats in a cubic lattice. The 
        % initialisation of the pores is then completed. 
        % 
        % Then the size of the network model is calculated, the connection number reduced and the
        % model is checked for possible errors.
        function initNetworkModel(obj)
            %METHOD1 此处显示有关此方法的摘要
            %   此处显示详细说明
            obj.m_numPores = obj.m_nX * obj.m_nY * obj.m_nZ;
            obj.createPores(); % 鉴定正确
            obj.connectPoresWithThroats(); % 鉴定正确
            for elem = 1:size(obj.m_pores,2)-1
                assert(~isempty(obj.m_pores{elem}));
                aspectRatio = obj.weibull(obj.m_aspectRatioWeibull{1},...
                    obj.m_aspectRatioWeibull{2},...
                    obj.m_aspectRatioWeibull{3},...
                    obj.m_aspectRatioWeibull{4});
                obj.m_pores{elem}.finaliseInit(aspectRatio, ...
                    obj.m_clayProportion);
            end
            
            obj.findNetworkModelSize();  % 鉴定正确
            obj.reduceConnectionNumber();
            obj.assignThroatIndex();
            obj.setPoreLocation();
            obj.checkNetworkIntegrity();
            fprintf('\n');
            fprintf('== Finished generating cubic network ==\n');
            fprintf('Number of pores:%d\n',obj.m_numPores);
            fprintf('Average connection number:%d\n',...
                obj.m_actualConnectionNumber);
            fprintf('Porosity:%f\n',obj.m_porosity);
        end
        
        % In and outlet pores have been given indicies 0 and numPores + 1. This is because the 
        % pores are stored in a vector. Only when writing the data to file their indicies are
        % changed to -1 and 0.
        function createPores(obj)  % 鉴定为正确
            obj.m_pores=cell(1,obj.m_numPores+3);
            for k=1:obj.m_nZ
                for j = 1:obj.m_nY
                    for i = 1:obj.m_nX
                        shapeF = obj.evalShapeFactor...
                            (obj.m_triangleGWeibull, obj.m_poreShapeProp);
                        currNode = Node(i,j,k,obj.m_nX,obj.m_nY,obj.m_nZ);
                        pore = Pore(currNode,shapeF,obj.MAX_CONN_NUM);
                        obj.m_pores{currNode.index()}=pore;
                    end
                end
            end
            
            inletNode = Node(0, 1, 1, obj.m_nX, obj.m_nY, obj.m_nZ);
            inlet = Pore(inletNode,0.04811,obj.m_nY*obj.m_nZ);% 0.04811??
            obj.m_pores{inletNode.index()} = inlet;
            
            outletNode = Node(obj.m_nX+1,1, 1, obj.m_nX,obj.m_nY,obj.m_nZ);
            outlet = Pore(outletNode, 0.04811, obj.m_nY*obj.m_nZ);
            obj.m_pores{outletNode.index()} = outlet;
        end
        
        % wheter a pore/throat is square, circle or triangular is again determined by drawing a 
        % random number between 0 and 1
        function shapeFactor = evalShapeFactor(obj,propG,proportion)
            randNum = rand();
            if randNum<proportion{1}
                shapeFactor = 1.0/16.0;
            elseif randNum< proportion{1} + proportion{2}
                shapeFactor = 1.0/(4.0*pi); 
            else
                shapeFactor = obj.weibull(propG{1}, propG{2}, propG{3},...
                    propG{4});
            end
        end
        
        % Returns a value within the truncated weibull distribution as used by Robin and Fenwick
        function weib = weibull(obj,min,max,delta,eta)
            randNum = rand();
            weib = (max - min) * power(-delta*log(randNum*(1.0-exp...
                (-1.0/delta))+exp(-1.0/delta)), 1.0/eta) + min;
        end
        
        function connectPoresWithThroats(obj)
            throatLenSum = 0.0;
            h = 0;
            for poreIdx=1+1:obj.m_numPores+1 % m_i=1:10，Idx从2开始
                for conn = 0:obj.MAX_CONN_NUM-1  % 
                    currNode = obj.m_pores{poreIdx}.node();
                    pbcThroat = false;
                    nextPoreIdx = currNode.nextIndex(conn, pbcThroat);
                    pbcThroat = evalin('base','pbcConn');
                    if nextPoreIdx >= 0+1 &&isempty(obj.m_pores{poreIdx}...
                            .connectingThroat(conn))
                        assert(~isempty(obj.m_pores{nextPoreIdx}) &&...
                            nextPoreIdx < obj.m_numPores + 2+1);  % +1
                        nextPore = obj.m_pores{nextPoreIdx};
                        radius = obj.weibull(obj.m_throatRadWeibull{1},...
                            obj.m_throatRadWeibull{2},...
                            obj.m_throatRadWeibull{3},...
                            obj.m_throatRadWeibull{4});
                        length = obj.weibull(obj.m_throatLenWeibull{1},...
                            obj.m_throatLenWeibull{2},...
                            obj.m_throatLenWeibull{3},...
                            obj.m_throatLenWeibull{4});
                        shapeFactor = obj.evalShapeFactor...
                            (obj.m_triangleGWeibull,obj.m_throatShapeProp);
                        throatLenSum = throatLenSum+length;
                        
                        throat = Throat(nextPore, obj.m_pores{poreIdx},...
                            shapeFactor, radius, length,...
                            obj.m_clayProportion, pbcThroat);
                        obj.m_throats{end+1}=throat;
                        obj.m_pores{poreIdx}.addThroat(conn, throat);
                        if nextPore.node().isInOrOutlet()
                            nextConn = (currNode.mk()-1) * obj.m_nY +...
                                currNode.mj() - 1;
                        else
                            nextConn = rem((conn +(obj.MAX_CONN_NUM/2)),...
                                obj.MAX_CONN_NUM);                            
                        end
                        
                        nextPore.addThroat(nextConn, throat);
                    end
                end
            end
            obj.m_averageThroatLength=throatLenSum/(size(obj.m_throats,2));
        end
        
        %The size of the model is taken to be the average distance betwen pores at 
        %the boundaries.
        function findNetworkModelSize(obj)
            numXFace = obj.m_nY*obj.m_nZ;
            numYFace = obj.m_nX*obj.m_nZ;
            numZFace = obj.m_nY* obj.m_nX;
            lengthSum = 0;
            for i = 1+1:size(obj.m_pores,2)-1-1 % +1
                lengthSum = lengthSum + obj.m_pores{i}.Length();
                lengthSum = lengthSum + obj.m_pores{i}...
                    .connectingThroat(0).Length();
            end
            obj.m_xDim = lengthSum / numXFace;
            
            lengthSum = 0;
            for i = 1+1:size(obj.m_pores,2)-1-1 % +1
                lengthSum = lengthSum + obj.m_pores{i}.Length();
                lengthSum = lengthSum + obj.m_pores{i}...
                    .connectingThroat(1).Length();
            end
            obj.m_yDim = lengthSum / numYFace;
            
            lengthSum = 0;
            for i = 1+1:size(obj.m_pores,2)-1-1 % +1
                lengthSum = lengthSum + obj.m_pores{i}.Length();
                lengthSum = lengthSum + obj.m_pores{i}...
                    .connectingThroat(2).Length();
            end
            obj.m_zDim = lengthSum / numZFace;
        end
        
        % A random number between 0 and 1 is drawn. If the number is less than the
        % probability for deletion, the throat is deleted. Hence we will only achive 
        % the requested connection number if the number of pores is very large.
        function reduceConnectionNumber(obj)
            numThroats = size(obj.m_throats,2);
            numDeletions = round(numThroats * ((obj.MAX_CONN_NUM-...
                obj.m_averConnectionNum)/obj.MAX_CONN_NUM));
            deletionProb = numDeletions/numThroats;
            
            iter = 1;            
            while iter <= size(obj.m_throats,2)                
                poreOne = obj.m_throats{iter}.connectingPore(0);
                poreTwo = obj.m_throats{iter}.connectingPore(1);
                
                if ~obj.m_periodicBC && obj.m_throats{iter}.pbcThroat()
                    poreOne.removeThroat(obj.m_throats{iter});
                    poreTwo.removeThroat(obj.m_throats{iter});
                    obj.m_throats(iter) = []; % []
                    % iter = iter+1;
                else
                    iter = iter+1;
                end                          
            end
            
            iter = 1;            
            while iter <= size(obj.m_throats,2)
                randNum = rand();
                poreOne = obj.m_throats{iter}.connectingPore(0);
                poreTwo = obj.m_throats{iter}.connectingPore(1);
                
                if poreOne.connectionNum() > 1 &&...
                        poreTwo.connectionNum() > 1 &&...
                        randNum < deletionProb
                    poreOne.removeThroat(obj.m_throats{iter});
                    poreTwo.removeThroat(obj.m_throats{iter});
                    obj.m_throats(iter) = []; % []
                else
                    iter = iter+1;
                end
            end
        end
        
        % When writing the pore/throat data to file we need to reference the throats
        % by an index. The index is set after the connection number has been reduced
        % so that they become consecutive.
        function assignThroatIndex(obj)
            index = 0+1; % +1
            throatVol = 0;
            
            iter = 1;
            while iter <= size(obj.m_throats,2)
                index = index + 1;
                obj.m_throats{iter}.setIndex(index);    % 这里把m_throats的索引增加了1            
                throatVol = throatVol + obj.m_throats{iter}.totVolume();
                iter = iter+1;
            end
            
            poreVolume = 0;
            for i = 1+1:obj.m_numPores+1 % +1
                poreVolume = poreVolume + obj.m_pores{i}.totVolume();
            end
            
            obj.m_porosity = (throatVol + poreVolume) / ...
                (obj.m_xDim * obj.m_yDim * obj.m_zDim);
            
        end
        
        % The pore location is set on a regular grid.
        function setPoreLocation(obj)
            numThroats = 0;
            for i = 1:size(obj.m_pores,2)-1
                obj.m_pores{i}.node().setLocation(obj.m_xDim,...
                    obj.m_yDim, obj.m_zDim, obj.m_averageThroatLength);
                numThroats = numThroats + obj.m_pores{i}.connectionNum();
            end
            obj.m_actualConnectionNumber = numThroats / obj.m_numPores;
        end
        
        % The state of both pores and throats are checked.
        function checkNetworkIntegrity(obj)
            for iter = 1:size(obj.m_throats,2)
               obj.m_throats{iter}.checkState();
            end
            for i = 1:size(obj.m_pores,2)-1 % 前+1 后-1
                obj.m_pores{i}.checkState();
            end
        end
        
        % The network data is written to file in the same format as used by Paal-Eric Oeren. The data is contained
        % in four files: *_node1.dat, *_node2.dat, *_link1.dat and *_link2.dat.
        function writeData(obj)
            pOut1FileName = [obj.m_outFileNameBase '_node1.dat'];
            pOut2FileName = [obj.m_outFileNameBase '_node2.dat'];
            fid1 = fopen(pOut1FileName,'w');
            fid2 = fopen(pOut2FileName,'w');
            fprintf(fid1,'%d\t%u\t%u\t%u\r\n',obj.m_numPores,...
                obj.m_xDim,obj.m_yDim,obj.m_zDim);
            for i = 1+1:obj.m_numPores+1
                obj.m_pores{i}.writeData(fid1, fid2);
            end
            fclose(fid1);
            fclose(fid2);
            
            tOut1FileName = [obj.m_outFileNameBase '_link1.dat'];
            pOut2FileName = [obj.m_outFileNameBase '_link2.dat'];
            fid3 = fopen(tOut1FileName,'w');
            fid4 = fopen(pOut2FileName,'w');
            fprintf(fid3,'%d\n',size(obj.m_throats,2));
            for iter = 1:size(obj.m_throats,2)
                obj.m_throats{iter}.writeData(fid3,fid4);
            end
            fclose(fid3);
            fclose(fid4);
        end
        
    end
end
