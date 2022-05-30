classdef Polygon<handle & Shape
    %UNTITLED15 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        m_cornerHalfAngles;
        m_waterInCorner;
        m_oilInCorner;
        m_snapOffPrs;
        m_numLayers;
        m_numCorners;
    end
    
    methods
        function obj = Polygon(parent, common, oil, water,radius,...
                shapeFactor, initConAng, numCorners, connNum)
            %UNTITLED15 构造此类的实例
            %   此处显示详细说明
            if nargin==9
                obj = Shape(parent, common, oil, water, radius,...
                    shapeFactor,initConAng, connNum);
                obj.m_numCorners = numCorners;
                obj.m_numLayers = 0;
                obj.m_maxConAngSpont = pi; 
                for i = 1:obj.m_numCorners
                    corner = CornerApex(initConAng, obj);
                    layer = LayerApex(corner, obj);
                    obj.m_waterInCorner{end+1}(corner);
                    obj.m_oilInCorner{end+1}(layer);
                end
            else  % radius实际上是shapeCp的意思，这是Polygon的第二个构造函数
                obj = Shape(parent, common, oil, water, radius);
                obj.m_cornerHalfAngles = radius.m_cornerHalfAngles;
                obj.m_snapOffPrs = radius.m_snapOffPrs;
                obj.m_numCorners = radius.m_numCorners;
                for i = 1:obj.m_numCorners
                    corner = CornerApex(radius.m_waterInCorner{i}, obj);
        	        layer = LayerApex(corner, radius.m_oilInCorner{i},obj);
                    obj.m_waterInCorner{end+1}(corner);
                    obj.m_oilInCorner{end+1}(layer);
                end
            end
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 此处显示有关此方法的摘要
            %   此处显示详细说明
            outputArg = obj.Property1 + inputArg;
        end
    end
end

