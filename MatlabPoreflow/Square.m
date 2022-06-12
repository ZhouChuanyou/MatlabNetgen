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
        
        % Computed the conductance of a fluid occupying the center of the element
        % There are some choices when it comes to compute the conducance of the 
        % centre of an element. 
        % g_p(A) = 3r^2A / 20mju   (1)     or      g_p(A) = 3A^2G / 5mju   (2)
        % g = g_p(A_t) * S_p       (A)     or      g = g_p(A_p)            (B)
        % Most combinations seem to give similar results (with the exception of
        % 2B). Lets run with 2A....
        
        % Computed the conductance of a fluid occupying the center of the element
        function centerConductance = centerConductance(obj,area,visc)
            %METHOD1 此处显示有关此方法的摘要
            %   此处显示详细说明
            % 1 2
            % centerConductance=(obj.m_radius * obj.m_radius * area) / (7.1136 * visc);
            centerConductance=(0.5623*area*area*obj.m_shapeFactor) / visc;
        end
    end
end

