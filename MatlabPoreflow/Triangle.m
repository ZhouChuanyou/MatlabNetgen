classdef Triangle<handle & Polygon
    %UNTITLED14 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        
    end
    
    methods
        function obj = Triangle(parent,common,oil,water,radius,...
                shapeFactor,initConAng,connNum)
            %UNTITLED14 构造此类的实例
            %   此处显示详细说明
            if nargin==8
                obj= Polygon(parent,common,oil,water,radius,shapeFactor,...
                    initConAng, 3, connNum);
                obj.m_commonData.addTriangle();    
                obj.m_cornerHalfAngles = cell(obj.m_numCorners);
                obj.getHalfAngles();

                obj.m_conductanceOil = 0.0;
                dataEntry = containers.Map(0,centerConductance(...
                    obj.m_areaWater,obj.m_water.viscosity()));
                obj.m_conductanceWater{end+1} = dataEntry;
            else % radius实际上是shapeCp，这是Triangle的第二个构造函数
                obj = Polygon(parent, common, oil, water, radius);
            end
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 此处显示有关此方法的摘要
            %   此处显示详细说明
            outputArg = obj.Property1 + inputArg;
        end
    end
end

