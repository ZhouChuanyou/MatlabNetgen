classdef Throat<handle & RockElem
    %UNTITLED6 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        m_pores;
        m_index;
        m_pbcThroat = true;
    end
    
    methods
        
        % Setting the index (required when writing to file) is delayed until connection
        % number has been reduced.
        function obj = Throat(Pore1,Pore2,shapeFactor,radius,length,...
                clayProp,pbcThroat)
            %UNTITLED6 构造此类的实例
            %   此处显示详细说明
            obj = obj@RockElem(shapeFactor);
            %             rock = RockElem(shapeFactor);
            %             obj.m_shapeFactor = rock.m_shapeFactor;
            obj.m_pbcThroat = pbcThroat;
            obj.m_radius = radius;
            obj.m_length = length;
            obj.m_pores{end+1} = Pore1;
            obj.m_pores{end+1} = Pore2;
            obj.m_index = 0+1; % +1
            
            area = power(obj.m_radius,2.0)/(4.0 * obj.m_shapeFactor);
            obj.m_volume = area * obj.m_length;
            if Pore1.node().isInOrOutlet() || Pore2.node().isInOrOutlet()
                obj.m_volume = 0.0;
            end
            obj.m_clayVolume = (clayProp * obj.m_volume)/(1.0 - clayProp);
        end
        
        function connectingPore = connectingPore(obj,conn)
            %METHOD1 此处显示有关此方法的摘要
            %   此处显示详细说明
            connectingPore = obj.m_pores{conn+1};
        end
        
        function pbcThroat = pbcThroat(obj)
            pbcThroat = obj.m_pbcThroat;
        end
        
        function setIndex(obj,index)
            obj.m_index = index;
        end
        
        function checkState(obj)
            for i = 1:size(obj.m_pores,2)  % 这里是throat的m_pores
                if isempty(obj.m_pores{i})
                    error...
                        ('Error: Pores are not initialized in throat:%d'...
                        ,obj.m_index);
                end
                if ~obj.m_pores{i}.containsThroat(obj)
                    error...
                        ('Error: Pores are not initialized in throat:%d'...
                        ,obj.m_index);
                end
            end
            if size(obj.m_pores,2) ~= 2
                error...
                    ('Error: Porees are not initialized in throat:%d',...
                    obj.m_index);
            end
        end
        
        function connectionNum = connectionNum(obj)
            connectionNum = size(obj.m_pores,2);
        end
        
        function nextPore = nextPore(obj,callingPore)
            if obj.m_pores{1} == callingPore % +1
                nextPore = obj.m_pores{2};
            else
                nextPore = obj.m_pores{1};
            end
        end
        
        function index = index(obj)
            index = obj.m_index;
        end
        
        % The throat data is written to file in following format:
        % *_link1.dat (outOne):
        % index, pore 1 index, pore 2 index, radius, shape factor, total length (pore center to pore center)
        % *_link2.dat (outTwo):
        % index, pore 1 index, pore 2 index, length pore 1, length pore 2, length throat, volume, clay volume
        function writeData(obj,fid1,fid2)
            lenPore1 = obj.m_pores{0+1}.halfLength();  % +1
            lenPore2 = obj.m_pores{1+1}.halfLength();  % +1
            lenTot = lenPore1+lenPore2+obj.m_length;
            % -1  +1
            fprintf(fid1,'%d\t%d\t%d\t%d\t%d\t%d\r\n',obj.m_index-1,...
                obj.m_pores{0+1}.node().indexOren(),...
                obj.m_pores{1+1}.node().indexOren(),...
                obj.m_radius,obj.m_shapeFactor,lenTot);
            
            fprintf(fid2,'%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\r\n',...
                obj.m_index-1,obj.m_pores{0+1}.node().indexOren(),...
                obj.m_pores{1+1}.node().indexOren(),lenPore1,lenPore2,...
                obj.m_length,obj.m_volume,obj.m_clayVolume);
        end
        
    end
end

