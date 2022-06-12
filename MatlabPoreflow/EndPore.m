classdef EndPore<handle&Pore
    %UNTITLED10 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        
    end
    
    methods
        % Endpores are assumed to be triangular and have zero volume and contact angles. 
        % Radius and interfacial tension is set to some arbitrary value to prevent any 
        % divison by zero that may occur. They are further assumed to be triangular so that 
        % they wont suddenly not contain water. 
        function obj = EndPore(common,node,oil,water,connThroats)
            %UNTITLED10 构造此类的实例
            %   此处显示详细说明
            obj = obj@Pore(common,node,oil,water,1.0E-5, 0.0, 0.0,...
                    sqrt(3.0)/36.0, 0.0, false, false, 0.0, connThroats);
            if nargin==5                
                obj.m_isInOilFloodVec = true;
                obj.m_isInWatFloodVec = true;
                polyShape = obj.m_elemShape;
                for i = 1:polyShape.numCorners()
                    polyShape.oilInCorner(i).isInCollapseVec(true);
                    polyShape.oilInCorner(i).isInReformVec(true);
                end
                obj.m_waterSaturation = 0.5;
                if node.isExitRes()
                    obj.m_isExitRes = true;
                else
                    obj.m_isEntryRes = true;
                end
                obj.m_isTrappingExit = obj.m_isExitRes;
                obj.m_isTrappingEntry = obj.m_isEntryRes;
            else % node代表的是oil,oil代表的是water,water代表的是endP,这是EndPore的第二个构造函数
                obj = Pore(common, node, oil, water);
            end
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 此处显示有关此方法的摘要
            %   此处显示详细说明
            outputArg = obj.Property1 + inputArg;
        end
    end
end

