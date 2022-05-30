classdef FourSome < handle
    % A little storage class for four eleemnts
    %UNTITLED2 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        m_first;
        m_second;
        m_third;
        m_fourth;
    end
    
    methods
        function obj = FourSome(one,two,three,four)
            %UNTITLED2 构造此类的实例
            %   此处显示详细说明
            obj.m_first = one;
            obj.m_second = two;
            obj.m_third = three;
            obj.m_fourth = four;
        end
        
        function first(obj,entry)
            %METHOD1 此处显示有关此方法的摘要
            %   此处显示详细说明
            obj.m_first = entry;
        end
        
        function second(obj,entry)
            %METHOD1 此处显示有关此方法的摘要
            %   此处显示详细说明
            obj.m_second = entry;
        end
        
        function third(obj,entry)
            %METHOD1 此处显示有关此方法的摘要
            %   此处显示详细说明
            obj.m_third = entry;
        end
        
        function fourth(obj,entry)
            %METHOD1 此处显示有关此方法的摘要
            %   此处显示详细说明
            obj.m_fourth = entry;
        end
    end
end

