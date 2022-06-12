classdef Netsim<handle
    %UNTITLED5 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        MAX_FLOW_ERR=0.02;
        DUMMY_IDX = -99;
        m_randSeed;
        
        m_commonData;
        m_drainageEvents;
        m_layerCollapseEvents;
        m_imbibitionEvents;
        m_layerReformEvents;
        
        m_oil;
        m_water;
        
        m_rockLattice;
        m_krInletBoundary;
        m_krOutletBoundary;
        m_waterSatHistory;
        m_prtOut;
        m_drainResultsOut;
        m_imbResultsOut;
        m_results;
        m_watPrsProfiles;
        m_oilPrsProfiles;
        m_usbmDataDrainage;
        m_usbmDataImbibition;
        m_amottDataDrainage;
        m_amottDataImbibition;
        
        m_resultWaterFlowRate;
        m_resultOilFlowRate;
        m_resultWaterSat;
        m_resultCappPress;
        m_resultBoundingPc;
        m_resultResistivityIdx;
        m_resultWaterMass;
        m_resultOilMass;
        
        m_maxNonZeros;
        m_numPores;
        m_numThroats;
        m_numIsolatedElems;
        m_numPressurePlanes;
        m_minNumFillings;
        m_totNumFillings;
        m_wettingClass;
        m_sourceNode;
        
        m_shavingFraction;
        m_modelTwoSepAng;
        m_amottOilIdx;
        m_amottWaterIdx;
        m_currentPc;
        m_cpuTimeTotal;
        m_cpuTimeCoal;
        m_cpuTimeKrw;
        m_cpuTimeKro;
        m_cpuTimeResIdx;
        m_cpuTimeTrapping;
        m_inletSolverPrs;
        m_outletSolverPrs;
        m_clayAdjust;
        m_maxOilFlowErr;
        m_maxWatFlowErr;
        m_maxResIdxErr;
        m_wettingFraction;
        m_singlePhaseWaterQ;
        m_singlePhaseOilQ;
        m_singlePhaseDprs;
        m_singlePhaseDvolt;
        m_singlePhaseCurrent;
        m_oilFlowRate;
        m_watFlowRate;
        m_current;
        m_formationFactor;
        m_medianLenToRadRatio;
        m_absPermeability;
        m_satBoxStart;
        m_satBoxEnd;
        m_solverBoxStart;
        m_solverBoxEnd;
        m_netVolume;
        m_clayVolume;
        m_rockVolume;
        m_maxCappPress;
        m_minCappPress;
        m_satWater;
        m_relPermWater;
        m_relPermOil;
        m_resistivityIdx;
        m_cappPress;
        m_boundPress;
        m_xSize;
        m_ySize;
        m_zSize;
        m_initStepSize;
        m_extrapCutBack;
        m_maxFillIncrease;
        m_deltaPo;
        m_deltaPw;
        
        m_apexPrsReported;
        m_includeGravityInRelPerm;
        m_stableFilling;
        m_matlabFormat;
        m_reportMaterialBal;
        m_excelFormat;
        m_useAvrPrsAsBdr;
        m_prtPressureProfile;
        m_calcRelPerm;
        m_calcResIdx;
        m_injAtEntryRes;
        m_injAtExitRes;
        m_writeWatMatrix;
        m_writeOilMatrix;
        m_writeResMatrix;
        m_writeWatVelocity;
        m_writeOilVelocity;
        m_writeResVelocity;
        m_writeSlvMatrixAsMatlab;
        m_createDrainList;
        m_createImbList;
        
        m_matrixFileName;
        m_angDistScheme;
        m_relPermDef;
        m_solver;
        
        m_trappingCriteria;
        m_pressurePlanesLoc;
        m_pressurePlanes;
        
        m_drainListOut;
        m_imbListOut;
    end
    
    methods
        % Netsim constructor
        function obj = Netsim(Par,flag)
            % flag = 1,执行seed;flag~=1,执行netsim
            %UNTITLED5 构造此类的实例
            %   此处显示详细说明
            if flag ==1
                obj.m_randSeed = Par;
                obj.m_inletSolverPrs = 1.0;
                obj.m_outletSolverPrs = 0.0;
                obj.m_minCappPress = 0.0;
                obj.m_maxCappPress = 0.0;
                obj.m_satWater = 1.0;
                obj.m_cappPress = 0.0;
                obj.m_clayAdjust = 0.0;
                obj.m_netVolume = 0.0;
                obj.m_clayVolume = 0.0;
                obj.m_relPermWater = 1.0;
                obj.m_relPermOil = 0.0;
                obj.m_resistivityIdx = 1.0;
                obj.m_maxNonZeros = 0;
                obj.m_maxOilFlowErr = 0.0;
                obj.m_maxWatFlowErr = 0.0;
                obj.m_maxResIdxErr = 0.0;
                obj.m_numIsolatedElems = 0;
                obj.m_modelTwoSepAng = 0.0;
                obj.m_wettingClass = 1;
                obj.m_totNumFillings = 0;
                obj.m_wettingFraction = 0.0;
                obj.m_shavingFraction = 1.0;
                obj.m_currentPc = 0.0;
                obj.m_calcRelPerm = true;
                obj.m_calcResIdx = true;
                obj.m_matlabFormat = false;
                obj.m_excelFormat = false;
                obj.m_stableFilling = true;
                obj.m_injAtEntryRes = false;
                obj.m_injAtExitRes = false;
                obj.m_reportMaterialBal = false;
                obj.m_includeGravityInRelPerm = false;
                obj.m_solver = [];
                obj.m_solverBoxStart = 0.0;
                obj.m_boundPress = 0.0;
                obj.m_amottOilIdx = 0.0;
                obj.m_amottWaterIdx = 1.0;
                obj.m_solverBoxEnd = 1.0;
                obj.m_singlePhaseDprs = 1.0;
                obj.m_singlePhaseDvolt = 1.0;
                obj.m_numPressurePlanes = 0;
                obj.m_oilFlowRate = 0.0;
                obj.m_watFlowRate = 0.0;
                obj.m_current = 0.0;
                obj.m_medianLenToRadRatio = 0.0;
                obj.m_writeWatMatrix = false;
                obj.m_writeOilMatrix = false;
                obj.m_writeResMatrix = false;
                obj.m_writeWatVelocity = false;
                obj.m_apexPrsReported = false;
                obj.m_writeOilVelocity = false;
                obj.m_writeResVelocity = false;
                obj.m_writeSlvMatrixAsMatlab = false;
                obj.m_amottDataDrainage = cell(1,3);
                obj.m_amottDataImbibition = cell(1,3);
                obj.m_deltaPo = 0.0;
                obj.m_deltaPw = 0.0;
                obj.m_relPermDef = "single";
            else
                % Copy constructor takes a copy of another netsim instance. This might be useful in
                % say simulations where one would use multiple instances of the network model in
                % different blocks.
                obj.m_randSeed = Par.m_randSeed;
                obj.m_oil = Oil(Par.m_oil);
                obj.m_water = Water(Par.m_water);
                obj.m_commonData = CommonData(Par.m_commonData);
                
                obj.m_numPores = Par.m_numPores;
                obj.m_numThroats = Par.m_numThroats;
                obj.m_injAtEntryRes = Par.m_injAtEntryRes;
                obj.m_injAtExitRes = Par.m_injAtExitRes;
                obj.m_angDistScheme = Par.m_angDistScheme;
                
                numElem = obj.m_numPores + obj.m_numThroats + 2;
                
                obj.m_rockLattice=cell(1,numElem);
                % +1
                obj.m_rockLattice{0+1} = EndPore(obj.m_commonData, ...
                    obj.m_oil, obj.m_water,Par.m_rockLattice{0+1});
                obj.m_rockLattice{m_numPores+1+1} = EndPore...
                    (obj.m_commonData,obj.m_oil,obj.m_water,...
                    Par.m_rockLattice{m_numPores+1+1});
                for i = 1+1:m_numPores+1
                    obj.m_rockLattice{i} = Pore(obj.m_commonData,...
                        obj.m_oil,obj.m_water, Par.m_rockLattice{i});
                end
                for j = m_numPores+2+1:numElem
                    obj.m_rockLattice{j} = Throat(obj.m_commonData,...
                        obj.m_oil,obj.m_water,Par.m_rockLattice{j});
                end
                % RockElements can't be copy constructed directly since they
                % contain pointers to neighbouring elements. First create all
                % elemnts, then set up inter connecting pointers
                for k = 1:numElem
                    for conn = 0:Par.m_rockLattice{k}.connectionNum()
                        index = Par.m_rockLattice{k}.connection(conn).latticeIndex();
                        connections{end+1} = obj.m_rockLattice{index};
                    end
                    obj.m_rockLattice{k}.finalizeCopyConstruct(connections);
                end
                for inEl = 0+1:size(Par.m_krInletBoundary,2)  % +1
                    index = Par.m_krInletBoundary{inEl}.latticeIndex();
                    obj.m_krInletBoundary{end+1} =obj.m_rockLattice{index};
                end
                for outEl = 0+1:size(Par.m_krOutletBoundary,2)  % +1
                    index = Par.m_krOutletBoundary{outEl}.latticeIndex();
                    obj.m_krOutletBoundary{end+1} =obj.m_rockLattice{index};
                end
                obj.m_numPressurePlanes = Par.m_numPressurePlanes;
                obj.m_pressurePlanesLoc =  Par.m_pressurePlanesLoc;
                obj.m_pressurePlanes = cell(1,m_numPressurePlanes);
                for pl = 0+1:obj.m_numPressurePlanes  % +1
                    numElems = size(Par.m_pressurePlanes{pl},2);
                    for el = 0+1:numElems  % +1
                        index = Par.m_pressurePlanes{pl}{el}.latticeIndex();
                        obj.m_pressurePlanes{pl}{end+1} = obj.m_rockLattice{index};
                    end
                end
                for dEl = 0+1:size(obj.m_drainageEvents,2)  % +1
                    index =  Par.m_drainageEvents.at(dEl).latticeIndex();
                    obj.m_drainageEvents.quickInsert(obj.m_rockLattice{index});
                end
                for iEl = 0+1:size(obj.m_imbibitionEvents,2)  % +1
                    index =  Par.m_imbibitionEvents.at(iEl).latticeIndex();
                    obj.m_imbibitionEvents.quickInsert(obj.m_rockLattice{index});
                end
                for cEl = 0+1:size(obj.m_layerCollapseEvents,2)  % +1
                    temp = Par.m_layerCollapseEvents.at(cEl);
                    index = keys(temp).parent().latticeIndex();
                    polyShape = obj.m_rockLattice{index}.shape();
                    assert(polyShape);
                    elem = containers.Map(polyShape,values(temp));
                    obj.m_layerCollapseEvents.quickInsert(elem);
                end
                for rEl = 0+1:size(obj.m_layerReformEvents,2)  % +1
                    temp = Par.m_layerReformEvents.at(rEl);
                    index =  keys(temp).parent().latticeIndex();
                    polyShape = obj.m_rockLattice{index}.shape();
                    assert(polyShape);
                    elem = containers.Map(polyShape,values(temp));
                    obj.m_layerReformEvents.quickInsert(elem);
                end
                obj.m_maxNonZeros = Par.m_maxNonZeros; % Memory for solver is not assigned until we actually need it. Hence
                if ~isempty(Par.m_solver) % we need to check wheter is has been constructred or not.
                    obj.m_solver = Solver(obj.m_rockLattice,...
                        obj.m_krInletBoundary,...
                        obj.m_krOutletBoundary,...
                        obj.m_numPores+1, obj.m_maxNonZeros, "nothing", true);
                else
                    obj.m_solver = [];
                end
                obj.m_commonData.finalizeCopyConstruct(Par.m_commonData,...
                    obj.m_rockLattice);   % Needed to finalize all pointers to trapped elems
                obj.m_waterSatHistory = Par.m_waterSatHistory;
                obj.m_cpuTimeTotal = Par.m_cpuTimeTotal;
                obj.m_cpuTimeKrw = Par.m_cpuTimeKrw;
                obj.m_cpuTimeKro = Par.m_cpuTimeKro;
                obj.m_cpuTimeTrapping = Par.m_cpuTimeTrapping;
                % The various output streams that have been assigned are just
                % directly copied. Perhaps a bit messy (especially prt output)
                obj.m_prtOut = Par.m_prtOut;
                obj.m_drainResultsOut = Par.m_drainResultsOut;
                obj.m_imbResultsOut = Par.m_imbResultsOut;
                obj.m_results = Par.m_results;
                
                obj.m_numIsolatedElems = Par.m_numIsolatedElems;
                obj.m_minNumFillings = Par.m_minNumFillings;
                obj.m_totNumFillings = Par.m_totNumFillings;
                
                obj.m_apexPrsReported = Par.m_apexPrsReported;
                obj.m_currentPc = Par.m_currentPc;
                obj.m_clayAdjust = Par.m_clayAdjust;
                obj.m_maxOilFlowErr = Par.m_maxOilFlowErr;
                obj.m_maxWatFlowErr = Par.m_maxWatFlowErr;
                obj.m_maxResIdxErr = Par.m_maxResIdxErr;
                obj.m_singlePhaseWaterQ = Par.m_singlePhaseWaterQ;
                obj.m_singlePhaseOilQ = Par.m_singlePhaseOilQ;
                obj.m_singlePhaseDprs = Par.m_singlePhaseDprs;
                obj.m_singlePhaseDvolt = Par.m_singlePhaseDvolt;
                obj.m_singlePhaseCurrent = Par.m_singlePhaseCurrent;
                obj.m_formationFactor = Par.m_formationFactor;
                obj.m_absPermeability = Par.m_absPermeability;
                obj.m_satBoxStart = Par.m_satBoxStart;
                obj.m_shavingFraction = Par.m_shavingFraction;
                obj.m_satBoxEnd = Par.m_satBoxEnd;
                obj.m_solverBoxStart = Par.m_solverBoxStart;
                obj.m_solverBoxEnd = Par.m_solverBoxEnd;
                obj.m_modelTwoSepAng = Par.m_modelTwoSepAng;
                obj.m_reportMaterialBal = Par.m_reportMaterialBal;
                obj.m_netVolume = Par.m_netVolume;
                obj.m_clayVolume = Par.m_clayVolume;
                obj.m_includeGravityInRelPerm = Par.m_includeGravityInRelPerm;
                obj.m_rockVolume = Par.m_rockVolume;
                obj.m_maxCappPress = Par.m_maxCappPress;
                obj.m_satWater = Par.m_satWater;
                obj.m_amottWaterIdx = Par.m_amottWaterIdx;
                obj.m_amottOilIdx = Par.m_amottOilIdx;
                obj.m_relPermWater = Par.m_relPermWater;
                obj.m_relPermOil = Par.m_relPermOil;
                obj.m_resistivityIdx = Par.m_resistivityIdx;
                obj.m_cappPress = Par.m_cappPress;
                obj.m_xSize = Par.m_xSize;
                obj.m_ySize = Par.m_ySize;
                obj.m_zSize = Par.m_zSize;
                obj.m_wettingClass = Par.m_wettingClass;
                obj.m_initStepSize = Par.m_initStepSize;
                obj.m_extrapCutBack = Par.m_extrapCutBack;
                obj.m_maxFillIncrease = Par.m_maxFillIncrease;
                obj.m_cpuTimeResIdx = Par.m_cpuTimeResIdx;
                obj.m_inletSolverPrs = Par.m_inletSolverPrs;
                obj.m_outletSolverPrs = Par.m_outletSolverPrs;
                obj.m_wettingFraction = Par.m_wettingFraction;
                
                obj.m_calcRelPerm = Par.m_calcRelPerm;
                obj.m_calcResIdx = Par.m_calcResIdx;
                obj.m_trappingCriteria = Par.m_trappingCriteria;
                obj.m_oilFlowRate = Par.m_oilFlowRate;
                obj.m_watFlowRate = Par.m_watFlowRate;
                obj.m_current = Par.m_current;
                obj.m_matlabFormat = Par.m_matlabFormat;
                obj.m_excelFormat = Par.m_excelFormat;
                obj.m_stableFilling = Par.m_stableFilling;
                obj.m_medianLenToRadRatio = Par.m_medianLenToRadRatio;
                obj.m_relPermDef = Par.m_relPermDef;
                obj.m_writeWatMatrix = false;
                obj.m_writeOilMatrix = false;
                obj.m_writeResMatrix = false;
                obj.m_writeWatVelocity = false;
                obj.m_writeOilVelocity = false;
                obj.m_writeResVelocity = false;
                obj.m_writeSlvMatrixAsMatlab = false;
                obj.m_createDrainList = false;
                obj.m_createImbList = false;
            end
        end
        
        function addOStreamForPrt(obj,out)
            %METHOD1 此处显示有关此方法的摘要
            %   此处显示详细说明
            obj.m_prtOut{end+1} = out;
        end
        
        % The network is created and initialized by reading in the connection files that also contains
        % all other relevant information about the pores/throats. Pointers to all elements are contained
        % in a vector. Element 0 and (n_pores + 1) are inlet/outlet. Throats follows after the pores.
        % Since all rock elements contain pointers to connecting elements rather than vector indicies,
        % initialization has to be in correct order: throats, pores, in/outlet and finally finishing the
        % throats. A single phase solve is also conducted to have flowrates to scale relperms against.
        function init(obj,input)
            interfacTen = [];
            watVisc = [];
            oilVisc = [];
            watResist = [];
            oilResist = [];
            circWatCondMultFact = [];
            fillWeights = [];
            solverOptions = [];
            condCutOff = 0.0;
            minEqConAng = 0.0;
            maxEqConAng = 0.0;
            watDens = 1000.0;
            oilDens = 1000.0;
            gravX = 0.0;
            gravY = 0.0;
            gravZ = -9.81;
            wettDelta=[];
            wettEta=[];
            eps=[];
            scaleFact=[];
            slvrOutput=[];
            poreFillAlgoritm=[];
            modPoroOptions=[];
            createLocData = false;
            writeMatInitOnly = [];
            drainSinglets = true;
            verboseSlvr = [];
            strictTrpCond = true;
            
            [obj.m_satBoxStart, obj.m_satBoxEnd]=input.calcBox...
                (obj.m_satBoxStart, obj.m_satBoxEnd);
            [obj.m_numPores,obj.m_numThroats,obj.m_xSize,obj.m_ySize,obj.m_zSize]...
                = input.network(obj.m_numPores, obj.m_numThroats, ...
                obj.m_xSize, obj.m_ySize, obj.m_zSize);
            
            [interfacTen,watVisc,oilVisc,watResist,oilResist,...
                watDens,oilDens] = input.fluid(interfacTen,watVisc,...
                oilVisc,watResist,oilResist,watDens,oilDens);
            
            [obj.m_minNumFillings,obj.m_initStepSize,obj.m_extrapCutBack,...
                obj.m_maxFillIncrease,obj.m_stableFilling] = ...
                input.satConvergence(obj.m_minNumFillings,...
                obj.m_initStepSize,obj.m_extrapCutBack,...
                obj.m_maxFillIncrease,obj.m_stableFilling);
            fillWeights = input.poreFillWgt(fillWeights);
            [eps,scaleFact,slvrOutput,verboseSlvr,condCutOff]=...
                input.solverTune(eps,scaleFact,slvrOutput,verboseSlvr,condCutOff);
            obj.m_clayAdjust = input.clayEdit(obj.m_clayAdjust);
            [obj.m_matlabFormat, obj.m_excelFormat] = ...
                input.resFormat(obj.m_matlabFormat, obj.m_excelFormat);
            poreFillAlgoritm = input.poreFillAlg(poreFillAlgoritm);
            [obj.m_useAvrPrsAsBdr,obj.m_prtPressureProfile,obj.m_numPressurePlanes]...
                =input.prsBdrs(obj.m_useAvrPrsAsBdr,...
                obj.m_prtPressureProfile,obj.m_numPressurePlanes);
            obj.m_reportMaterialBal = input.matBal(obj.m_reportMaterialBal);
            [obj.m_injAtEntryRes, obj.m_injAtExitRes, drainSinglets, ...
                circWatCondMultFact]=input.trapping(obj.m_injAtEntryRes,...
                obj.m_injAtExitRes, drainSinglets, circWatCondMultFact);
            obj.m_apexPrsReported = input.apexPrs(obj.m_apexPrsReported);
            [gravX, gravY, gravZ]=input.gravityConst(gravX, gravY, gravZ);
            [obj.m_relPermDef, strictTrpCond] =...
                input.relPermDef(obj.m_relPermDef, strictTrpCond);
            obj.m_shavingFraction = input.aCloseShave(obj.m_shavingFraction);
            if obj.m_injAtEntryRes && obj.m_injAtExitRes
                obj.m_trappingCriteria = TrappingCriteria.escapeToEither;
            elseif strictTrpCond
                obj.m_trappingCriteria = TrappingCriteria.escapeToBoth;
            elseif obj.m_injAtEntryRes
                obj.m_trappingCriteria = TrappingCriteria.escapeToOutlet;
            else
                obj.m_trappingCriteria = TrappingCriteria.escapeToInlet;
            end
            [obj.m_writeWatMatrix, obj.m_writeOilMatrix, ...
                obj.m_writeResMatrix, obj.m_writeWatVelocity,...
                obj.m_writeOilVelocity,obj.m_writeResVelocity,...
                obj.m_matrixFileName, obj.m_writeSlvMatrixAsMatlab,...
                writeMatInitOnly]=input.solverDebug(obj.m_writeWatMatrix,...
                obj.m_writeOilMatrix, obj.m_writeResMatrix, ...
                obj.m_writeWatVelocity, obj.m_writeOilVelocity,...
                obj.m_writeResVelocity, obj.m_matrixFileName, ...
                obj.m_writeSlvMatrixAsMatlab, writeMatInitOnly);
            [obj.m_createDrainList, obj.m_createImbList, createLocData]=...
                input.fillingList(obj.m_createDrainList, ...
                obj.m_createImbList, createLocData);
            [obj.m_inletSolverPrs, obj.m_outletSolverPrs, ...
                obj.m_includeGravityInRelPerm]=...
                input.prsDiff(obj.m_inletSolverPrs, ...
                obj.m_outletSolverPrs, obj.m_includeGravityInRelPerm);
            obj.m_deltaPo = obj.m_inletSolverPrs-obj.m_outletSolverPrs;
            obj.m_deltaPw = obj.m_deltaPo;
            [obj.m_wettingClass, minEqConAng, maxEqConAng, wettDelta,...
                wettEta, obj.m_angDistScheme, obj.m_modelTwoSepAng]=...
                input.equilConAng(obj.m_wettingClass, minEqConAng, ...
                maxEqConAng, wettDelta, wettEta, obj.m_angDistScheme,...
                obj.m_modelTwoSepAng);
            obj.m_sourceNode = input.sourceNode(obj.m_sourceNode);
            if obj.m_sourceNode ~= 0
                if obj.m_sourceNode > obj.m_numPores
                    error...
                        ('Source pore (%d) needs to be\r\nless than the total number of pores (%d).\r\n',...
                        obj.m_sourceNode,obj.m_numPores);
                end
                obj.m_trappingCriteria = TrappingCriteria.escapeToBoth;
                obj.m_injAtEntryRes = false;
                obj.m_injAtExitRes = false;
            end
            
            [INITIALISED,USE_GRAVITY,SYMMETRIC_MAT,VERBOSE_SLVR,...
                MAT_MEM_SCALE,TOLERANCE,SLVR_OUTPUT]=Solver.initSolver...
                (eps,scaleFact,slvrOutput,verboseSlvr,obj.m_includeGravityInRelPerm);
            
            % rockElem = RockElem([],[],[],[],[],[],[],[],[],[]);
            % global USE_GRAV_IN_KR;
            USE_GRAV_IN_KR = RockElem.useGravInKr(obj.m_includeGravityInRelPerm);
            COND_CUT_OFF = RockElem.conductanceCutOff(condCutOff);
            obj.m_commonData = CommonData(fillWeights, poreFillAlgoritm,...
                circWatCondMultFact, input, gravX, gravY, gravZ);
            obj.m_water = Water(watVisc, interfacTen, watResist, watDens);
            obj.m_oil = Oil(oilVisc, interfacTen, oilResist, oilDens);
            
            % If we don't average pressures to obtain
            % rel perm (ie we're moving the boundary)
            % then the lattice we pass to the solver
            % will be the same as that we compute sat across
            if ~obj.m_useAvrPrsAsBdr
                obj.m_solverBoxStart = obj.m_satBoxStart;
                obj.m_solverBoxEnd = obj.m_satBoxEnd;
            end
            [numSingletsRemoved,input] = obj.initNetwork(input, drainSinglets);
        end
        
        % Creates all the pores and throats
        function [numSingletsRemoved,input] = initNetwork(obj,input,drainSinglets)
            poreHash = cell(1,obj.m_numPores);
            throatHash = cell(1,obj.m_numThroats);
            throatHash(:)= {obj.DUMMY_IDX};
            [newNumPores,input,poreHash] = obj.setupPoreHashing(input, poreHash);
            obj.m_rockLattice = cell(1,newNumPores + 2);
            connectingPores = cell(1,obj.m_numThroats);
            co = containers.Map(0,0);
            %             connectingPores(:)=co;
            for i = 1:length(connectingPores)
                connectingPores{i} = co;
            end
            % All throats connected to the in/outlet are
            % recorded while crating the throats
            throatsToInlet = [];
            throatsToOutlet = [];
            [newNumThroats,input,connectingPores,throatsToInlet,...
                throatsToOutlet,poreHash,throatHash] = ...
                obj.readAndCreateThroats(input,connectingPores,...
                throatsToInlet,throatsToOutlet,poreHash,throatHash,newNumPores);
            [input,connectingPores,poreHash,throatHash] = ...
                obj.readAndCreatePores(input, connectingPores, poreHash,...
                throatHash, newNumPores);
            input.finishedLoadingNetwork();
            obj.m_xSize = obj.m_xSize*obj.m_shavingFraction;
            obj.m_numPores = newNumPores;
            obj.m_rockVolume = obj.m_xSize * obj.m_ySize * obj.m_zSize *...
                (obj.m_satBoxEnd - obj.m_satBoxStart);
            yMid = obj.m_ySize/2.0;
            zMid = obj.m_zSize/2.0;
            % +1 
            throatsToInlet=obj.createInAndOutletPore...
                (0+1,-1.0E-15,yMid,zMid,throatsToInlet);
            % +1
            throatsToOutlet = obj.createInAndOutletPore(obj.m_numPores+1+1,...
                obj.m_xSize+1.0E-15,yMid,zMid,throatsToOutlet);
            lenToRadRatio = newNumThroats;
            runIdx = 0+1;  % +1
            % Adding the pore pointers to the throats had
            % to be delayed until after having created
            % the pores. The network should now be properly initialized. 
            % P = parpool(6);
            parfor i = 1:obj.m_numThroats
                key = keys(connectingPores{i});
                value = values(connectingPores{i});
                poreIndex1 = obj.checkPoreIndex(key{1});
                poreIndex2 = obj.checkPoreIndex(value{1}); 
                if poreIndex1 >= 0+1 && poreIndex2 >= 0+1  % +1
                    % +1
                    assert(poreIndex1<obj.m_numPores+2+1 && poreIndex2<obj.m_numPores+2+1);
                    pore1 = obj.m_rockLattice{poreIndex1};  
                    pore2 = obj.m_rockLattice{poreIndex2};
                    assert(~isempty(pore1) && ~isempty(pore2));
                    obj.m_rockLattice{obj.m_numPores+2+runIdx}.addConnections...
                        (pore1, pore2, obj.m_xSize*obj.m_solverBoxStart,...
                        obj.m_xSize*obj.m_solverBoxEnd,~obj.m_useAvrPrsAsBdr);
                end
            end
            % delete(P);
        end
        
        % We're using different indicies for out and inlet. Paal-Eric uses -1 and 0 
        % wheras we use 0 and (numPores+1), hence we need to renumber these. 
        % The reason for this is that -1 is not a good index when storing the element 
        % pointers in a vector.
        function index = checkPoreIndex(obj,index)
            if index == -1
                index = 0+1;  % +1
            elseif index == 0
                index = obj.m_numPores + 1+1; % +1
            else
                index = index+1;  % add this line by Zhou, 2022.6.10
            end
        end
        
        % In and outlet only need to know what throats are connected to it.
        % Their indicies are 0 and (n_pores + 1)
        function connThroats=createInAndOutletPore(obj,index,xPos,yPos,zPos,connThroats)
            if xPos > 0.0 && xPos < obj.m_xSize
                fprintf('\r\nError: Entry and exit reservoirs cannot be\r\n');
                fprintf('within the network model area.\r\n');
                exit;
            end
            currNode = Node(index,obj.m_numPores,xPos,yPos,zPos,obj.m_xSize);
            pore=EndPore(obj.m_commonData,currNode,obj.m_oil,obj.m_water,connThroats);
            obj.m_rockLattice{currNode.index()} = pore;
        end
        
        % The data for the throats are read from the link files. Since the pores are not yet created their
        % indicies are stored in a temporary vector and the pointers will be initialized later. Since
        % in/outlet does not have separete entries in the data files, we keep track of connecting throats.
        % The strucure of the link files are as follows:
        % *_link1.dat:
        % index, pore 1 index, pore 2 index, radius, shape factor, total length (pore center to pore center)
        % *_link2.dat:
        % index, pore 1 index, pore 2 index, length pore 1, length pore 2, length throat, volume, clay volume
        function [newNumThroats,input,connectingPores,throatsToInlet,...
                throatsToOutlet,poreHash,throatHash] = ...
                readAndCreateThroats(obj,input,connectingPores,...
                throatsToInlet,throatsToOutlet,poreHash,throatHash,newNumPores)
            
            minConAng = 0.0;
            maxConAng = 0.0;
            delta= [];
            eta=[];
            [minConAng, maxConAng, delta, eta]=input.initConAng(minConAng,...
                maxConAng, delta, eta);
            numLengthErrors = 0;
            newNumThroats = 0;
            for index = 1+1:obj.m_numThroats+1  % +1
                poreOneIdx = [];
                poreTwoIdx = [];
                radius = [];
                shapeFactor = [];
                lenTot= [];
                lenPore1= [];
                lenPore2 = [];
                lenThroat = [];
                volume = [];
                clayVolume = [];
                [poreOneIdx,poreTwoIdx,volume,clayVolume,radius,...
                    shapeFactor,lenPore1, lenPore2,lenThroat,lenTot]=...
                    input.throatData(index,poreOneIdx,poreTwoIdx,volume,...
                    clayVolume,radius,shapeFactor,lenPore1, lenPore2,lenThroat,lenTot);
                if poreOneIdx > 0
                    temp =containers.Map(keys(poreHash{poreOneIdx-1+1}),...
                        values(connectingPores{index-1}));
                    connectingPores{index-1} = temp;
                    %                     temp = poreHash{poreOneIdx-1+1};    % +1
                    %                     key = keys(temp);
                    %                     value = values(connectingPores{index-1});
                    %                     temp(key{1}) = ...
                    %                         value{1};
                    %                     connectingPores{index-1} = temp;
                else
                    temp =containers.Map({poreOneIdx},values(connectingPores{index-1}));
                    connectingPores{index-1} = temp;
                    %                     temp = connectingPores{index-1};
                    %                     remove(temp, keys(connectingPores{index-1}));
                    %                     temp(poreOneIdx) = values(connectingPores{index-1});
                end
                if poreTwoIdx > 0
                    temp =containers.Map(keys(connectingPores{index-1}),...
                        keys(poreHash{poreTwoIdx-1+1}));
                    connectingPores{index-1} = temp;
                    %                     temp = connectingPores{index-1};
                    %                     temp(keys(connectingPores{index-1})) = ...
                    %                         keys(poreHash{poreTwoIdx-1});
                    %                     connectingPores{index-1} = temp;
                else
                    temp =containers.Map(keys(connectingPores{index-1}),poreTwoIdx);
                    connectingPores{index-1} = temp;
                    %                     temp = connectingPores{index-1};
                    %                     temp(keys(connectingPores{index-1})) = poreTwoIdx;
                    %                     connectingPores{index-1} = temp;
                end
                key = keys(connectingPores{index - 1});
                value = values(connectingPores{index - 1});
                
                if key{1}> 0 ||value{1} > 0
                    newNumThroats = newNumThroats+1;
                    throatHash{index-1} = newNumThroats;
                    if key{1} == obj.DUMMY_IDX
                        value2 = values(poreHash{poreOneIdx-1+1});  % +1
                        value3 = values(poreHash{poreTwoIdx-1+1});  % +1
                        if value2{1} < obj.m_xSize/2.0
                            temp = containers.Map(-1,value);
                            connectingPores{index - 1} = temp;
                        else
                            temp = containers.Map(0,value);
                            connectingPores{index - 1} = temp;
                            %                             temp = connectingPores{index-1};
                            %                             remove(temp, keys(connectingPores{index-1}));
                            %                             temp(0) = values(connectingPores{index-1});
                            %                             connectingPores{index - 1} = temp;
                        end
                    elseif value{1}==obj.DUMMY_IDX
                        if value3{1} < obj.m_xSize/2.0
                            temp = containers.Map(key, -1);
                            connectingPores{index - 1} = temp;
                        else
                            temp = containers.Map(key, 0);
                            connectingPores{index - 1} = temp;
                        end
                    end
                    initConAng = obj.weibull(minConAng, maxConAng, delta, eta);
                    adjustingVol = obj.m_clayAdjust*(volume+clayVolume);
                    adjustingVol = min(adjustingVol, volume);
                    adjustingVol = -min(-adjustingVol, clayVolume);
                    volume = volume - adjustingVol;
                    clayVolume = clayVolume + adjustingVol;
                    if abs(lenPore1+lenPore2+lenThroat-lenTot)/lenTot>0.01
                        numLengthErrors = numLengthErrors+1;
                    end
                    throat = Throat(obj.m_commonData,obj.m_oil,obj.m_water,...
                        radius,volume,clayVolume,shapeFactor,initConAng,...
                        lenThroat,lenPore1,lenPore2,newNumPores + 1 + newNumThroats);
                    obj.m_rockLattice{end+1}= throat;
                    key = keys(connectingPores{index - 1});
                    value = values(connectingPores{index - 1});
                    if key{1} == -1 || value{1} == -1
                        throatsToInlet{end+1} = throat;
                    elseif key{1} == 0 || value{1} == 0
                        throatsToOutlet{end+1} = throat;
                    end
                end
            end
            if numLengthErrors > 0
                fprintf('\r\nWarning: For %d throats the lengths of the\r\n',numLengthErrors);
                fprintf('pore-throat-pore did not match the total length.\r\n');
                fprintf('This is generally only an artifact of the network\r\n');
                fprintf('reconstruction process, and is not serious.\r\n');
                fid = fopen('PrtData','w');
                for i = 1:length(obj.m_prtOut)
                    fprintf('——————————————');
                    fprintf(fid,'%s\r\n',obj.m_prtOut{i});
                    fprintf('\r\nWarning: For %d throats the lengths of the\r\n',numLengthErrors);
                    fprintf('pore-throat-pore did not match the total length.\r\n');
                    fprintf('This is generally only an artifact of the network\r\n');
                    fprintf('reconstruction process, and is not serious.\r\n');
                    fprintf('——————————————');
                end
                fclose(fid);
            end
        end
        
        function weib = weibull(obj,min,max,delta,eta)
            randNum = rand();
            if delta < 0.0 && eta < 0.0  % Uniform Distribution
                weib = min + (max-min)*randNum;
            else  % Weibull Distribution
                weib = (max - min) * power(-delta*log(randNum*(1.0-exp...
                    (-1.0/delta))+exp(-1.0/delta)), 1.0/eta) + min;
            end
        end
        
        function [numPores,input,poreHash] = setupPoreHashing(obj,input,poreHash)
            numPores = 0;
            for index = 1+1:obj.m_numPores+1  % +1
                entry = containers.Map(obj.DUMMY_IDX, 0.0);
                value = values(entry);
                key = keys(entry);
                value{1} = input.poreLocation(index,value{1});
                if value{1}>=obj.m_xSize*(1.0-obj.m_shavingFraction)/2.0...
                        && value{1}<=obj.m_xSize-obj.m_xSize*(1.0-obj.m_shavingFraction)/2.0
                    remove(entry,key{1});
                    numPores = numPores+1;
                    entry(numPores) = value{1};
                end
                poreHash{index-1} = entry;
            end
        end
        
        % The pore data is read from the node files. At this point the throats are already created and the pointers
        % can be set. The strucure of the node files are as follows:
        % *_node1.dat:
        % index, x_pos, y_pos, z_pos, connection num, connecting nodes..., at inlet?, at outlet?, connecting links...
        % *_node2.dat:
        % index, volume, radius, shape factor, clay volume
        function [input,connectingPores,poreHash,throatHash] = ...
                readAndCreatePores(obj,input,connectingPores,poreHash,...
                throatHash,newNumPores)
            minConAng = 0.0;
            maxConAng = 0.0;
            delta = [];
            eta = [];
            shaveOff = obj.m_xSize*(1.0-obj.m_shavingFraction)/2.0;
            [minConAng,maxConAng,delta,eta]=input.initConAng...
                (minConAng,maxConAng,delta,eta);
            newIndex = 0;  
            for index = 1+1:obj.m_numPores+1  % +1
                connNumber = [];
                xPos = [];
                yPos = [];
                zPos = [];
                volume = [];
                radius = [];
                shapeFactor =[];
                clayVolume = [];
                connThroats = [];
                connPores = [];
                connectingThroats = [];
                [xPos,yPos,zPos,connNumber,connThroats,connPores,volume,...
                    clayVolume,radius,shapeFactor]=input.poreData...
                    (index,xPos,yPos,zPos,connNumber,connThroats,...
                    connPores,volume,clayVolume,radius,shapeFactor);
                if xPos >= shaveOff && xPos <= obj.m_xSize-shaveOff
                    newIndex = newIndex+1;
                    initConAng=obj.weibull(minConAng,maxConAng,delta,eta);
                    adjustingVol = obj.m_clayAdjust*(volume+clayVolume);
                    adjustingVol = min(adjustingVol, volume);
                    adjustingVol = -min(-adjustingVol, clayVolume);
                    volume =volume - adjustingVol;
                    clayVolume = clayVolume+adjustingVol;
                    connectingThroats =cell(1,connNumber);
                    for j =0+1:connNumber  %+1
                        hashedThroatIdx= throatHash{connThroats{j}-1+1};%+1
                        hashedPoreIdx = connPores{j};
                        try
                            key = keys(poreHash{connPores{j}-1+1}); %+1
                            value = values(poreHash{connPores{j}-1+1});
                        catch
                            key = -1000000;  % connPores{j}=-1时
                            value = -1000000;
                        end
                        if hashedPoreIdx>0+1 && key{1}~=obj.DUMMY_IDX  % +1
                            hashedPoreIdx = key{1}; %+1
                        elseif hashedPoreIdx > 0+1 && value{1}<obj.m_xSize/2.0  % +1
                            hashedPoreIdx = -1;   % +1
                        elseif hashedPoreIdx > 0+1 && value{1}>obj.m_xSize/2.0  % +1
                            hashedPoreIdx = 0;  % +1
                        end
                        try
                            key = keys(connectingPores{connThroats{j}-1+1}); %+1
                            value = values(connectingPores{connThroats{j}-1+1});
                        catch
                            key = -1000000;
                            value = -1000000;
                        end
                        
                        assert(newIndex==key{1} || newIndex == value{1});
                        assert(hashedPoreIdx==key{1} || hashedPoreIdx==value{1}); %+1
                        connectingThroats{j} = obj.m_rockLattice...
                            {newNumPores + 1 + hashedThroatIdx+1};  
                    end
                    initSolvPrs = (obj.m_outletSolverPrs + obj.m_inletSolverPrs)/2.0;
                    currNode = Node(newIndex,newNumPores,...
                        xPos-shaveOff,yPos,zPos,obj.m_xSize*obj.m_shavingFraction);
                    insideSlvrBox = currNode.isInsideBox...
                        (obj.m_solverBoxStart,obj.m_solverBoxEnd);
                    insideSatBox = currNode.isInsideBox...
                        (obj.m_satBoxStart,obj.m_satBoxEnd);
                    pore = Pore(obj.m_commonData,currNode,obj.m_oil,...
                        obj.m_water,radius,volume,clayVolume,shapeFactor,...
                        initConAng,insideSlvrBox,insideSatBox,initSolvPrs,connectingThroats);
                    obj.m_rockLattice{newIndex +1} = pore;  % +1
                end
            end
        end
    end
end

