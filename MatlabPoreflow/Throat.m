classdef Throat<handle & RockElem
    %UNTITLED19 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        m_latticeIndex;
        m_originalPoreLengths;
        m_poreLength;
        m_length;
    end
    
    methods
        function obj = Throat(common,oil,water,radius,volume,volumeClay,...
                shapeFactor,initConAng,length,lengthPore1,lengthPore2,index)
            %UNTITLED19 构造此类的实例
            %   此处显示详细说明
            if nargin==12
                obj = RockElem(common,oil,water,radius,volume,...
                volumeClay,shapeFactor,initConAng,2,false);
            
                obj.m_latticeIndex = index;
                obj.m_length = length;
                obj.m_poreLength{end+1} = lengthPore1;
                obj.m_poreLength{end+1} = lengthPore2;
                obj.m_originalPoreLengths = 0;
            else  % 这里radius代表的是throat，这是Throat的第二个构造函数
                obj = RockElem(common,oil,water,radius);
                obj.m_latticeIndex = radius.m_latticeIndex;
                obj.m_connectedToEntryOrExit = radius.m_connectedToEntryOrExit;
                obj.m_poreLength = radius.m_poreLength;
                obj.m_length = radius.m_length;
            end
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 此处显示有关此方法的摘要
            %   此处显示详细说明
            outputArg = obj.Property1 + inputArg;
        end
    end
end

