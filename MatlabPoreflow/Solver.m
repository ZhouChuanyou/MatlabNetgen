classdef Solver<handle
    %UNTITLED 此处显示有关此类的摘要
    %   此处显示详细说明
    properties
        SCALE_FACTOR = 1.0;
        MAT_MEM_SCALE = 3;
        INITIALISED = false;
        USE_GRAVITY = false;
        SYMMETRIC_MAT = 22;
        SLVR_OUTPUT = 10;
        VERBOSE_SLVR = 11111;
        TOLERANCE = 1.0E-15;
        
        m_network;
        m_inletPores;
        m_outletPores;
        m_outletIdx;
        m_maxNonZeros;
        m_matrixFileName;
        m_matlabFormat;
        m_probSize;
        m_matElemFactor;
        m_matSizeFactor;
        
        m_networkOutlets;
        m_networkInlets;
        m_throatConductances;
        m_petscErr;
        m_matrixSize;
        m_nonZeroElems;
        m_rowPtr;
        m_colIndex;
        m_someIdxBuffer;
        m_colHash;
        m_finalRowPointer;
        
        m_matElems;
        m_rhsVecBuffer;
        m_solVecBuffer;
        
        m_poreHash;
    end
    
    methods
        % This is the constructor for the solver class. Given the network it allocates memory
        % for various C type arrays. These are set to the maximum length possible which is when
        % all pores contain the fluid for which the flowrate is going to be obtained.
        function obj = Solver(network,inlet,outlet,outletIdx,...
                maxNonZeros,matFileName,matlabFormat)
            % UNTITLED 构造此类的实例
            % 此处显示详细说明
            if nargin==0
                return;
            elseif nargin==7
                obj.m_network = network;
                obj.m_inletPores = inlet;
                obj.m_outletPores = outlet;
                obj.m_outletIdx = outletIdx;
                obj.m_maxNonZeros = maxNonZeros;
                obj.m_matrixFileName = matFileName;
                obj.m_matlabFormat = matlabFormat;
                obj.m_probSize = outletIdx-1;
                obj.m_matElemFactor = 3;
                obj.m_matSizeFactor = 5;
                maxNdaFactor = obj.m_matElemFactor*obj.m_maxNonZeros+...
                    obj.m_probSize*(obj.m_matSizeFactor*obj.MAT_MEM_SCALE);
                % These are all set to maximum number of non zero elements, ie
                % the number it would be if all rock elements were invaded with
                obj.m_matElems = cell(1,maxNdaFactor);
                obj.m_colIndex = cell(1,maxNdaFactor);
                obj.m_rowPtr = cell(1,3*obj.m_probSize+1);
                obj.m_solVecBuffer = cell(1,3*obj.m_probSize);
                % fluid to be solved for. This will be the case for water but not
                obj.m_rhsVecBuffer = cell(1,3*obj.m_probSize);
                obj.m_someIdxBuffer = cell(1,12*obj.m_probSize);
                
                % oil which never invades the smallest throats/pores.
                obj.m_colHash = cell(1,obj.m_probSize);
                obj.m_poreHash = cell(1,obj.m_probSize);
            else
                % 这里的network实际上是solver，这是Solver的第二个构造函数
                solver = network;
                obj.m_network = solver.m_network;
                obj.m_inletPores = solver.m_inletPores;
                obj.m_outletPores = solver.m_outletPores;
                obj.m_outletIdx = solver.m_outletIdx;
                obj.m_maxNonZeros = solver.m_maxNonZeros;
                obj.m_matrixFileName = solver.m_matrixFileName;
                obj.m_matlabFormat =solver.m_matlabFormat;
                obj.m_probSize = solver.m_probSize;
                obj.m_matElemFactor = solver.m_matElemFactor;
                obj.m_matSizeFactor= solver.m_matSizeFactor;
                maxNdaFactor = obj.m_matElemFactor*obj.m_maxNonZeros+...
                    obj.m_probSize(obj.m_matSizeFactor*obj.MAT_MEM_SCALE);
                obj.m_matElems = cell(1,maxNdaFactor);
                obj.m_colIndex = cell(1,maxNdaFactor);
                obj.m_rowPtr = cell(1,3*obj.m_probSize+1);
                obj.m_solVecBuffer = cell(1,3*obj.m_probSize);
                obj.m_rhsVecBuffer = cell(1,3*obj.m_probSize);
                obj.m_someIdxBuffer = cell(1,12*obj.m_probSize);
                obj.m_colHash = cell(1,obj.m_probSize);
                obj.m_poreHash = cell(1,obj.m_probSize);
            end
        end
    end
    methods(Static)
        function [INITIALISED,USE_GRAVITY,SYMMETRIC_MAT,VERBOSE_SLVR,...
                MAT_MEM_SCALE,TOLERANCE,SLVR_OUTPUT]=initSolver...
                (eps,scaleFact,slvrOutput,verboseSlvr,useGrav)
            %METHOD1 此处显示有关此方法的摘要
            %   此处显示详细说明
            obj = Solver;
%             persistent SCALE_FACTOR;            
%             persistent MAT_MEM_SCALE;
%             persistent INITIALISED;
%             persistent USE_GRAVITY;
%             persistent SYMMETRIC_MAT;
%             persistent SLVR_OUTPUT;
%             persistent VERBOSE_SLVR;
%             persistent TOLERANCE;
            if ~obj.INITIALISED
                % Clen the solver dump....
                fid = fopen('fort.11','w');
                fclose(fid);
                
                INITIALISED = true;
                USE_GRAVITY = useGrav;
                SYMMETRIC_MAT = 12; % Set to 22 if matrix is not symmetric
                if verboseSlvr
                    VERBOSE_SLVR = 10606;
                else
                    VERBOSE_SLVR = 11111;
                end
                MAT_MEM_SCALE = scaleFact;
                TOLERANCE = eps;
                SLVR_OUTPUT = 10 + slvrOutput;
            end
        end
    end
end

