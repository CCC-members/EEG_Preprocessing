function OutEEGs = process_clean_data(properties,EEGs)

clean_asr           = properties.clean_params.clean_asr;
chan_action         = clean_asr.rej_or_interp_chan;
decompose_ica       = properties.clean_params.decompose_ica;
cleanline           = properties.clean_params.cleanline;
reference           = properties.clean_params.reference;
band_cut            = properties.clean_params.band_cut;
downsample          = properties.clean_params.downsample;



for i=1:length(EEGs)
    EEG     = EEGs(i);

    % Downsalmpling data
    if(downsample.run && EEG.srate > downsample.srate)        
            EEG = pop_resample(EEG,downsample.srate);        
    end

    % Apply average reference
    if(reference.average_ref)
        EEG           = pop_reref(EEG,[]);
        [EEG,changes] = eeg_checkset(EEG);
    end

    % Filtering data
    if(band_cut.run)
        EEG             = pop_eegfiltnew(EEG, 'locutoff', band_cut.min_freq, 'hicutoff',band_cut.max_freq, 'filtorder', 3300);
        [EEG,changes]   = eeg_checkset(EEG);
    end

    % This will run cleanline on all channels, scanning for lines +/- 1 Hz around the 50 Hz frequencies.
    % Each epoch will be cleaned individually and epochs containing lines that are significantly sinusoidal at
    % the p<=0.01 level will be cleaned.
    if(cleanline.run)        
        EEG   = pop_cleanline(EEG, 'Bandwidth', ...
            cleanline.Bandwidth, ...
            'ChanCompIndices',[1:EEG.nbchan] , ...
            'SignalType','Channels', ...
            'ComputeSpectralPower',cleanline.ComputeSpectralPower, ...
            'LineFrequencies',[cleanline.LineFrequencies] , ...
            'NormalizeSpectrum',cleanline.NormalizeSpectrum, ...
            'LineAlpha',cleanline.LineAlpha, ...
            'PaddingFactor',cleanline.PaddingFactor, ...
            'PlotFigures',cleanline.PlotFigures, ...
            'ScanForLines',cleanline.ScanForLines, ...
            'SmoothingFactor',cleanline.SmoothingFactor, ...
            'VerbosityLevel',cleanline.VerbosityLevel, ...
            'SlidingWinLength',EEG.pnts/EEG.srate, ...
            'SlidingWinStep',EEG.pnts/EEG.srate);
    end

    % try
    chanlocs = EEG.chanlocs;
    if(clean_asr.run)
        EEG     = clean_artifacts(EEG, ...
            'FlatlineCriterion',clean_asr.FlatlineCriterion,...
            'ChannelCriterion',clean_asr.ChannelCriterion,...
            'LineNoiseCriterion',clean_asr.LineNoiseCriterion,...
            'Highpass',clean_asr.Highpass,...
            'BurstCriterion',clean_asr.BurstCriterion,...
            'WindowCriterion',clean_asr.WindowCriterion,...
            'BurstRejection',clean_asr.BurstRejection,...
            'Distance',clean_asr.Distance,...
            'WindowCriterionTolerances',clean_asr.WindowCriterionTolerances);

        %% Step 11: Interpolate all the removed channels.
        if(isequal(lower(chan_action.action),'interpolate'))
            EEG     = pop_interp(EEG, chanlocs, 'spherical');
        end
    end    

    %% Running ICA
    if(decompose_ica.run)
        %   Run an ICA decomposition of an EEG dataset
        icatype         = decompose_ica.icatype.value;
        extended        = decompose_ica.extended;
        reorder         = decompose_ica.reorder;
        concatenate     = decompose_ica.concatenate;
        concatcond      = decompose_ica.concatcond;
        EEG             = pop_runica( EEG, 'icatype', icatype, 'options', {'extended', extended}, 'reorder', reorder, 'concatenate', concatenate, 'concatcond', concatcond, 'chanind', []);
        %   Label independent components using ICLabel.
        [EEG]           = pop_iclabel(EEG, 'default');
        thresh          = struct2array(decompose_ica.remove_comp.thresh)';
        %   pop_icflag - Flag components as atifacts
        [EEG]           = pop_icflag(EEG, thresh);
        components      = find(EEG.reject.gcompreject == 1);
        plotag          = 0;
        keepcomp        = 0;
        %   pop_subcomp() - remove specified components from an EEG dataset.
        [EEG]           = pop_subcomp(EEG,components, plotag, keepcomp);
        [EEG,changes] = eeg_checkset(EEG);
    end
    
    OutEEGs(i) = EEG;
    % catch Ex
    %     disp('--------------------------------------------------------------------------');
    %     disp("-->> ERROR");
    %     disp(Ex.message);
    %     disp('--------------------------------------------------------------------------');
    %     continue;
    % end
end

end