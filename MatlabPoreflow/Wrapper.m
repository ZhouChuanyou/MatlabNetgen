classdef Wrapper
    
    properties(Constant=true)
        dataStruct='s';
    end
    
    methods
        function data = Wrapper()   
            %do something with object
        end
    end
        
    methods(Static=true)
        function platPosition = getPlatPosition()
            % Wrapper.dataStruct = 'ss';
            platPosition = Wrapper.dataStruct;
            
        end
    end
end