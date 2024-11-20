function EEGs = process_clean_data(properties,EEGs)



clean_art_params    = properties.preproc_params.clean_data.clean_artifacts;
decompose_ica       = clean_art_params.decompose_ica;
args                = clean_art_params.arguments;
chan_action         = clean_art_params.rej_or_interp_chan;

for i=1:length(EEGs)
    EEG     = EEGs(i);
    try
        chanlocs = EEG.chanlocs;
        EEG     = clean_artifacts(EEG, ...
            'FlatlineCriterion',args.FlatlineCriterion,...
            'ChannelCriterion',args.ChannelCriterion,...
            'LineNoiseCriterion',args.LineNoiseCriterion,...
            'Highpass',args.Highpass,...
            'BurstCriterion',args.BurstCriterion,...
            'WindowCriterion',args.WindowCriterion,...
            'BurstRejection',args.BurstRejection,...
            'Distance',args.Distance,...
            'WindowCriterionTolerances',args.WindowCriterionTolerances);

        %% Step 11: Interpolate all the removed channels.
        if(isequal(lower(chan_action.action),'interpolate'))
            EEG     = pop_interp(EEG, chanlocs, 'spherical');
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

        end
        [EEG,changes] = eeg_checkset(EEG);
        EEGs(i) = EEG;
    catch
        continue;
    end
end

end