classdef Square<handle&Polygon
    %UNTITLED17 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        
    end
    
    methods
        function obj = Square(parent,common,oil,water,radius,initConAng,...
                connNum)
            %UNTITLED17 构造此类的实例
            %   此处显示详细说明
            if nargin==7
                obj = Polygon(parent,common,oil,water,radius,0.0625,...
                    initConAng,4,connNum);
                obj.m_commonData.addSquare();
                obj.m_cornerHalfAngles = cell(1,obj.m_numCorners);
                obj.m_cornerHalfAngles(:) = {pi/4};
                obj.m_conductanceOil = 0.0;
                dataEntry = containers.Map(0,obj.centerConductance...
                    (obj.m_areaWater,obj.m_water.viscosity()));
                obj.m_conductanceWater{end+1} = dataEntry;
            else  % radius实际上表示shapeCp，这里是Square的第二个构造函数
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

