classdef Pore<handle&RockElem
    %UNTITLED11 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        m_node; 
        m_oilSolverPrs;
        m_watSolverPrs;
        m_oilSolverVolt;
        m_watSolverVolt;
    end
    
    methods
        function obj = Pore(common,node,oil,water,radius,volume,...
                volumeClay,shapeFactor,initConAng,insideSlvBox,...
                insideSatBox,initSolverPrs,connThroats)
            %UNTITLED11 构造此类的实例
            %   此处显示详细说明
            obj = obj@RockElem(common,oil,water,radius,volume,volumeClay,...
                    shapeFactor,initConAng,size(connThroats,2),true);
            if nargin==13                
                obj.m_node = node;
                obj.m_isInsideSatBox = insideSatBox;
                obj.m_isInsideSolverBox = insideSlvBox;
                obj.m_connections = connThroats;
                obj.m_oilSolverPrs = initSolverPrs;
                obj.m_watSolverPrs = initSolverPrs;
                obj.m_watSolverVolt = initSolverPrs;
                obj.m_oilSolverVolt = initSolverPrs;
   
                obj.m_elemShape.setGravityCorrection(obj.m_node);
                
                minRad = 100;
                maxRad = 0.0;
                radSum = 0.0;
                for i = 1:size(obj.m_connections,2)
                    rad = obj.m_connections{i}.shape().radius();
                    minRad = min(minRad, rad);
                    maxRad = max(minRad, rad);
                    radSum = radSum+rad;
                end
                obj.m_averageAspectRatio = obj.m_elemShape.radius()*...
                    size(obj.m_connections,2)/radSum;
                obj.m_maxAspectRatio = obj.m_elemShape.radius()/maxRad;
                obj.m_minAspectRatio = obj.m_elemShape.radius()/minRad;
            else % 这是Pore的第二个构造函数，radius代表Pore& pore
                % obj = RockElem(common,oil,water,radius);
                obj.m_oilSolverPrs = radius.m_oilSolverPrs;
                obj.m_watSolverPrs = radius.m_watSolverPrs;
                obj.m_oilSolverVolt = radius.m_oilSolverVolt;
                obj.m_watSolverVolt = radius.m_watSolverVolt;

                obj.m_node = Node(radius.m_node);
                
            end
        end
        
        % All connecting throats for a pore should already have been set 
        % in the pore constructor.
        function addConnections(obj,first,second,inBdr,outBdr,moveBdr)
            fprintf('Illegal operation\r\n');
            exit;
        end
        
        function node = node(obj)
            node = obj.m_node;
        end
    end
end

