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
            obj= obj@Polygon(parent,common,oil,water,radius,shapeFactor,...
                    initConAng, 3, connNum);
            if nargin==8
%                 obj= Polygon(parent,common,oil,water,radius,shapeFactor,...
%                     initConAng, 3, connNum);
                obj.m_commonData.addTriangle();    
                obj.m_cornerHalfAngles = cell(obj.m_numCorners);
                obj.getHalfAngles();

                obj.m_conductanceOil = 0.0;
                dataEntry = containers.Map(0,obj.centerConductance...
                    (obj.m_areaWater,obj.m_water.viscosity()));
                obj.m_conductanceWater{end+1} = dataEntry;
            else % radius实际上是shapeCp，这是Triangle的第二个构造函数
                obj = Polygon(parent, common, oil, water, radius);
            end
        end
        
        %This function evaluates the three half angles that make up the 
        %triangular pore. The routine follows the outline that was described by Patzek. 
        function getHalfAngles(obj)
            %METHOD1 此处显示有关此方法的摘要
            %   此处显示详细说明
            beta_2_min = atan((2.0/sqrt(3.0))*...
                cos(acos(-12.0*sqrt(3.0)*obj.m_shapeFactor)/3.0+4.0*pi/3.0));
            beta_2_max = atan((2.0/sqrt(3.0))*...
                cos(acos(-12.0*sqrt(3.0)*obj.m_shapeFactor)/3.0));
            randNum = rand();
            % +1
            obj.m_cornerHalfAngles{1+1} = beta_2_min + ...
                (beta_2_max - beta_2_min)*randNum;
            obj.m_cornerHalfAngles{0+1} = -0.5*obj.m_cornerHalfAngles{1+1}...
                + 0.5*asin((tan(obj.m_cornerHalfAngles{1+1})+...
                4.0*obj.m_shapeFactor)*sin(obj.m_cornerHalfAngles{1+1}) /...
                (tan(obj.m_cornerHalfAngles{1+1})-4.0*obj.m_shapeFactor));
            obj.m_cornerHalfAngles{2+1} =pi/2.0-obj.m_cornerHalfAngles{1+1}...
                - obj.m_cornerHalfAngles{0+1};
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
            % 1 2
            % centerConductance=3.0*obj.m_radius*obj.m_radius*area/(20.0 * visc);
            centerConductance=3.0*area*area*obj.m_shapeFactor/(5.0 * visc);
        end
    end
end

