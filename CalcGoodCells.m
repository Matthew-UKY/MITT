function Config = CalcGoodCells(Config,Data,GUIControl)
% assesses quality of sampled cells based on various flexible criteria
% called from ClassifyArrayGUI, ClassifyArrayAuto
% calls various ClassifyCor, Classifyxcorr, Classifyw1w2xcorr, ClassifyNoise, ClassifySpike, ClassifyPoly
% NoiseHurtherLemmin, ConvMulti2Struct 
% Note: criteria can be controlled from launch window for automatic
% analysis or from interactive array plot

faQCname = fieldnames(Config.faQC);
xvar = {'Vel','Despiked','Filtered'};
yvar = {'zZ'};
% if it is empty, no filter has yet been run, or if you want to reset
if isempty(faQCname)||GUIControl.resetFilter
    % set faQC from C structure array
    if isfield(GUIControl,'faQC')
        faQC = GUIControl.faQC;
    else
        faQC = DefaultfaQC;
    end

    ncomptot = length(Config.comp);
    goodCellsi = true(Config.nCells,ncomptot);
    goodCellsii = true(Config.nCells,ncomptot);
    
    % create matrix to store
    nQtot = ncomptot+1+faQC.Range+faQC.w1w2xcorr+ncomptot*(faQC.Correlation+faQC.xcorr+faQC.Spikes+faQC.InertialSlope+faQC.PolyFilt);
    Qdat = zeros(Config.nCells,nQtot);
    Qcnames = cell(1,nQtot);
    Qi = ncomptot+1;
    
    % filter by position in the water column
    outofwater = Config.zZ<=0 | Config.zZ>=1;
    goodCellsi(outofwater,:) = false;
    Qcnames{Qi} = 'z/Z';
    Qdat(:,Qi) = Config.zZ;
    Qi = Qi+1;
    
    % filter by lateral position
%     yY = Config.ypos/Config.Y;
%     outofwater = yY<0 | yY>1;
%     goodCellsi(outofwater,:) = 0;
    
    %% filtering subprograms
    % filter by range
    if faQC.Range
        if ~isempty(faQC.nigood)||faQC.nigood>1
            if faQC.nigood > Config.nCells
                goodCellsi(:,:) = false;
            else 
                goodCellsi(1:faQC.nigood-1,:) = false;
            end
        end
        if ~isempty(faQC.negood)||faQC.negood<Config.nCells
            goodCellsi(faQC.negood+1:end,:) = false;
        end
    end
    % filter by signal correlation
    if faQC.Correlation && isfield(Data,'Cor')
        for ncomp = 1:ncomptot
            compi = Config.comp{ncomp};
            [goodCellsii(:,ncomp),QCor] = ClassifyCor(compi,Data.Cor,faQC.Corthreshold);
            Qcnames{Qi} = ['CORBeam',num2str(ncomp)];
            Qdat(:,Qi) = QCor(:,ncomp);
            Qi = Qi+1;
        
        end
        goodCellsi = goodCellsi & goodCellsii;

    end

    % filter by percent mode
    if faQC.pctmodecheck
        for ncomp = 1:ncomptot
            compi = Config.comp{ncomp};
            xdata = Data.(GUIControl.Xvar).(compi);
            [goodCellsii(:,ncomp),Modepct] = ClassifyMode(xdata,faQC.pctmode/100);
            Qcnames{Qi} = ['Mode',compi,' (%)'];
            Qdat(:,Qi) = Modepct;
            Qi = Qi+1;
        
        end
        goodCellsi = goodCellsi & goodCellsii;

    end
    % filter by correlation between adjacent cells
    if faQC.xcorr
        % for each component
        for ncomp = 1:ncomptot
            compi = Config.comp{ncomp};
            xdata = Data.(GUIControl.Xvar).(compi);
            [goodCellsii(:,ncomp),Qxcorr] = Classifyxcorr(xdata,faQC.xcorrthreshold);
            Qcnames{Qi} = ['X corr ',compi,' (%)'];
            Qdat(:,Qi) = Qxcorr;
            Qi = Qi+1;
        end
        goodCellsi = goodCellsi & goodCellsii;

    end
    % filter by Hurther Lemmin w1 w2 
    if faQC.w1w2xcorr
        if isfield(Data.Vel,'w2')
            xdata = Data.(GUIControl.Xvar);
            [goodCellsii,QNRW] = ClassifyNoiseRatio(xdata,faQC.w1w2xcorrthreshold,Config.transformationMatrix);
            Qdat(:,Qi) = QNRW;
            for ncomp = 1:ncomptot
                goodCellsi(:,ncomp) = goodCellsi(:,ncomp) & goodCellsii;
            end
        else
            Qdat(:,Qi) = NaN;
            
        end
        Qcnames{Qi} = 'Noise Ratio (%)';
        Qi = Qi+1;

    end
    % filter by spike numbers
    if faQC.Spikes
        if isfield(Data,'SpikeY')
            % for each component
            for ncomp = 1:ncomptot
                compi = Config.comp{ncomp};
                SpikeY = diff(Data.Vel.(compi)-Data.Despiked.(compi))>0.001;

                SpikeYi = Data.SpikeY.(compi);
                [goodCellsii(:,ncomp),QSpike] = ClassifySpike(SpikeY,faQC.SpikeThreshold);
                Qcnames{Qi} = ['Spikes ',compi,'(%)'];
                Qdat(:,Qi) = QSpike;
                Qi = Qi+1;
            end
            goodCellsi = goodCellsi & goodCellsii;
        else
            Qdat(:,Qi) = NaN;
            
        end
        
    end
    % filter by -5/3 slope in inertial range
    if faQC.InertialSlope
        % don't use filtered because it changes the slope
        if isfield(Data,'Despike')
            xdata = Data.Despike;
        else
            xdata = Data.Vel;
        end
        for ncomp = 1:ncomptot
            compi = Config.comp{ncomp};
            %xdata = Data.(C.Xvar).(compi);
            xdatai = xdata.(compi);
            [goodCellsii(:,ncomp),QSis] = ClassifyNoiseFloor(xdatai,faQC.InertialSlopeThreshold,Config.Hz,Config.zpos,Config.samplingVolume);
            Qcnames{Qi} = ['S Inertial ',compi];
            Qdat(:,Qi) = QSis;
            Qi = Qi+1;
        end

        goodCellsi = goodCellsi & goodCellsii;
    end
    % filter by a 3rd order polynomial to the mean, std, and skewness of profile
    if faQC.PolyFilt
        ydata = Config.(GUIControl.Yvar);

        % for each component
        for ncomp = 1:ncomptot
            compi = Config.comp{ncomp};
            xdata = Data.(GUIControl.Xvar).(compi);
            goodCellsii(:,ncomp) = ClassifyPoly(ydata,xdata,goodCellsi(:,ncomp),faQC.zscore);
            Qcnames{Qi} = ['Poly fit ',compi];
            Qdat(:,Qi) = goodCellsii(:,ncomp);
            Qi = Qi+1;
        end
        goodCellsi = goodCellsi & goodCellsii;
    end
    % classify with ARMA model results 
% % moved it to after cleaned models
% if user_corrupt
%     goodCellsii = ARMA_corrupt(velnomean_seg,goodCellsi,ARMA,ARMAopts,start_end);
%     goodCellsii=goodCellsi.*goodCellsii;
% else
%     goodCellsii = goodCellsi;
% end

    for ncomp=1:ncomptot
        compi = Config.comp{ncomp};
        Config.goodCells.(compi) = goodCellsi(:,ncomp);
    end
    
    %% output to table
    % add in goodCells
    for ncomp=1:ncomptot
        compi = Config.comp{ncomp};
        Qcnames{ncomp} = ['goodCells ',compi];
        Qdat(:,ncomp) = goodCellsi(:,ncomp);
    end
    
    %% save data
    Config.faQC = faQC;
    Config.Qcnames = Qcnames;
    Config.Qdat = Qdat;
end

end

%%%%%




%%%%%
