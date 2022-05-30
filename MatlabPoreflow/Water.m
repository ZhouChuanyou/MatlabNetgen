classdef Water<handle&Fluid
    %UNTITLED8 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        
    end
    
    methods
        function obj = Water(viscosity,interPhaseTen, resistivity, density)
            %UNTITLED8 构造此类的实例
            %   此处显示详细说明
            obj = obj@Fluid(viscosity,interPhaseTen, resistivity, density);
%             if (nargin==4)
%                 obj = Fluid(viscosity,interPhaseTen,resistivity,density);
%             else  % viscosity实际上water，这是第二个构造函数
%                 obj = Fluid(viscosity);
%             end
        end
    end
end

