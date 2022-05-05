classdef Pore<handle & RockElem
    %UNTITLED4 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        m_node;
    	m_connectionNumber;
    	m_throats;
    end
    
    methods
        
        % Most of the poreinitialisation is delayed until connecting throats are 
        % created. This is because their radius is dependant on all connecting throats.
        function obj = Pore(Node,shapefactorP,connectionNum)
            %UNTITLED4 构造此类的实例
            %   此处显示详细说明
            obj = obj@RockElem(shapefactorP);
%             rock = RockElem(shapefactorP);
%             obj.m_shapeFactor = rock.m_shapeFactor;
            obj.m_node = Node;
            obj.m_throats = cell(1,connectionNum);
            obj.m_connectionNumber = connectionNum;
        end
        
        function node = node(obj)
            %METHOD1 此处显示有关此方法的摘要
            %   此处显示详细说明
            node = obj.m_node;
        end
        
        function connectingThroat = connectingThroat(obj,conn)
            connectingThroat = obj.m_throats{conn+1}; % obj.m_throats{conn}好像没有预定义
        end
        
        function addThroat(obj,conn,throat)
            obj.m_throats{conn+1} = throat; % +1
        end
        
        % The pores are finally initialized when the connecting throats are known. The 
        % radius of the pore is calculated using the same procedure that Daryl used, 
        % ie. the average throat radius multiplied by an aspect ratio (as long as this
        % value is larger than the max throat radius). Pore length is taken to be twice
        % the radius.
        function finaliseInit(obj,aspectRatio,clayProp)
            throatRadiusSum=0.0;
            maxThroatRadius=0.0;
            numConn=0;
            
            for i = 1:size(obj.m_throats,2)
                if ~isempty(obj.m_throats{i})
                    throatRadiusSum = throatRadiusSum + ...
                        obj.m_throats{i}.radius();
                    maxThroatRadius = max(maxThroatRadius, ...
                        obj.m_throats{i}.radius());
                    numConn = numConn+1;
                end
            end
            
            obj.m_radius = max(aspectRatio *(throatRadiusSum / numConn),...
                maxThroatRadius);
            obj.m_length = 2.0 * obj.m_radius;
            
            area = power(obj.m_radius, 2.0) / (4.0 * obj.m_shapeFactor);
            obj.m_volume = area * obj.m_length;
            obj.m_clayVolume = (clayProp * obj.m_volume) /(1.0 - clayProp);
        end
        
        % When reducing the connection number it becomes necissary to remove the 
        % references to these throats in the pores.
        function removeThroat(obj,throat)
            iter = find(cellfun(@(t)isequaln(t , throat), obj.m_throats));
            if iter<= size(obj.m_throats,2)
                obj.m_throats(iter)=[]; % []
            else
                fprintf('whoa...\n');
                exit;
            end
            obj.m_connectionNumber = size(obj.m_throats,2);
        end
        
        % When calculating average connection number we do not want to include connections
        % to in/outlet.
        function connectionNum = connectionNum(obj)
            if obj.m_node.isInOrOutlet()
                connectionNum = 0;
            else 
                connectionNum = obj.m_connectionNumber;
            end
        end
        
        function containsThroat = containsThroat(obj,throat)
            for i = 1:size(obj.m_throats,2)
                if obj.m_throats{i} == throat
                    containsThroat = true;
                    return;
                end
            end
            containsThroat = false;
        end
        
        % Rigerous error checking is done to verify that the state of the network is correct
        function checkState(obj)
            if ~obj.m_node.isInOrOutlet() &&...
                    (size(obj.m_throats,2) > 6 || size(obj.m_throats,2) <1)
                error('Error: Throats are not initialized in pore:%d',...
                    obj.m_node.index());
            end
            if obj.m_connectionNumber ~= size(obj.m_throats,2)
                error('Error: Throats are not initialized in pore:%d',...
                    obj.m_node.index());
            end
            for i = 1:size(obj.m_throats,2)
                if isempty(obj.m_throats{i})
                    error...
                        ('Error: Throats are not initialized in pore:%d'...
                        ,obj.m_node.index());
                end
                if ~obj.m_node.isInOrOutlet() && ...
                        obj.m_throats{i}.connectionNum() ~= 2
                    error...
                        ('Error: Throats are not initialized in pore:%d'...
                        ,obj.m_node.index());
                end
                if obj.m_throats{i}.radius() > obj.m_radius
                    error...
                        ('Error: Throat radius gerater than pore radius in:%d'...
                        ,obj.m_node.index());
                end
            end
        end
        
        % The pore data is written to file in following format:
        % *_node1.dat (outOne):
        % index, x_pos, y_pos, z_pos, connection num, connecting nodes..., at inlet?, at outlet?, connecting links...
        % *_node2.dat (outTwo):
        % index, volume, radius, shape factor, clay volume
        function writeData(obj,fid1,fid2)
            fprintf(fid1,'%d\t%u\t%u\t%u\t%d\t',obj.m_node.m_index-1,...  % 这个-1完全是为了和作者node结构形式保持一致，其实这个在MATLAB中是不能-1的
                obj.m_node.m_xLoc,obj.m_node.m_yLoc,obj.m_node.m_zLoc,...
                obj.m_connectionNumber);
            for i = 1:size(obj.m_throats,2)
                fprintf(fid1,'%d\t',...   %Connecting nodes
                    obj.m_throats{i}.nextPore(obj).node().indexOren());
            end
            fprintf(fid1,'%d\t%d\t',...  % In and outlet?
                obj.m_node.isAtInlet(),obj.m_node.isAtOutlet());
            for i = 1:size(obj.m_throats,2)   % Connecting throats
                fprintf(fid1,'%d\t',obj.m_throats{i}.index()-1);   % 这个-1完全是为了和作者node结构形式保持一致，其实这个在MATLAB中是不能-1的
            end
            fprintf(fid1,'\r\n');
            fprintf(fid2,'%d\t%d\t%d\t%d\t%d\r\n',obj.m_node.index()-1,...
                obj.m_volume,obj.m_radius,obj.m_shapeFactor,obj.m_clayVolume);            
        end
        
        function halfLength = halfLength(obj)
            halfLength = obj.m_length/2.0;
        end
        
    end
end

