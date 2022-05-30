classdef Oil <handle&Fluid
    %UNTITLED6 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        
    end
    
    methods
        function obj = Oil(viscosity,interPhaseTen,resistivity,density)
            %UNTITLED6 构造此类的实例
            %   此处显示详细说明
            obj = obj@Fluid(viscosity,interPhaseTen,resistivity,density);
%             if (nargin==4)
%                 obj = Fluid(viscosity,interPhaseTen,resistivity,density);
%             else  % viscosity实际上oil，这是第二个构造函数
%                 obj = Fluid(viscosity);
%             end
        end
    end
end

