function [trials_info, settings] = get_condition_times(trials_info, settings)

    switch settings.patient 
        case 'ArM01'
            trials_info.trial_times_button_press = []; trials_info.key_was_pressed_after = [];
            %% read paradigm logs
            fid = fopen(fullfile(settings.path2data, settings.run_type_file), 'r');
            all_trials =textscan(fid, '%s %s');
            fclose(fid);
            trial_times = all_trials{1};
            trial_labels = all_trials{2};
            % Omit prefix, e.g., 'word', 'nonword', and keep only serial number
            trial_labels = cellfun(@(x) x((strfind(x, '_')+1):end), trial_labels, 'UniformOutput', false);

            if isempty(settings.conditions)
                last_trial_found = false; i = 0;
                while ~last_trial_found
                    last_trial_found =  ~isnan(str2double(trial_labels(end-i)));
                    i = i + 1;
                end
                last_trial = str2double(trial_labels(end-i-1));
                trial_numbers_per_condition = {1:last_trial};
            end
            %% get trial timing for each condition
                    for cnd = 1:length(trial_numbers_per_condition)
                        curr_condition_trials = trial_numbers_per_condition{cnd};
                        trial_times_of_curr_condition = [];
                        for token = 1:length(curr_condition_trials)
                            curr_token_number = curr_condition_trials(token);
                            if ~isempty(strfind(settings.block_name, 'sentences'))
                                curr_token_number = 2*curr_token_number - 1; % First word (1-180 to 1-360)
                            end
                            IX = strcmp(num2str(curr_token_number), trial_labels);
                            if sum(IX)~=1
                                error('No match between token numbers and paradigm log file')
                            else
                                trial_times_of_curr_condition(token) = str2double(trial_times{IX});
                            end
                        end
                        % Add found trial timings to output cell array
                        trials_info.trial_times_per_condition{cnd} = trial_times_of_curr_condition;
                    end

        case {'En_01', 'En_02', 'patient_479'}
                load(fullfile('..', '..', 'Data', settings.hospital, settings.patient, sprintf('sentences_start_%s.mat', settings.patient)));
                fid = fopen(fullfile(settings.path2data, settings.run_type_file), 'r');
    %             aa = dlmread(fullfile(settings.path2data, settings.run_type_file), ' ');
                trial = 1;trial_button_press = 1;consec = false;
                trials_info.trial_times_button_press = [];trials_info.key_was_pressed_after = [];
                while ~feof(fid)
                        curr_line = fgets(fid);
                        curr_fields = strsplit(curr_line);

                        if settings.generate_key_press_rasters
                            if strcmp(curr_fields{2}, 'KEY_PRESS')  && strcmp(curr_fields{3}, 'l')
                                if ~consec
                                        trials_info.trial_times_button_press(trial_button_press) = str2double(curr_fields{1});
                                        switch settings.block_name
                                            case  'sentences'
                                                    trials_info.key_was_pressed_after.trial(trial_button_press) = str2double(trial_labels{trial-1});
                                                    trials_info.key_was_pressed_after.sentence(trial_button_press) = find((str2double(trial_labels{trial-1})-sentences_start)>0, 1, 'last');
                                            case 'words_press'
                                                    trials_info.key_was_pressed_after.trial{trial_button_press} = trial_labels{trial-1};
                                        end
                                        trial_button_press = trial_button_press + 1;
                                end
                                consec = true;
                            else
                                consec = false;
                            end
                        end
                        if (strcmp(curr_fields{2}, 'DISPLAY_PICTURE') || strcmp(curr_fields{2}, 'DISPLAY_TEXT')) && ~strcmp(curr_fields{3}, 'OFF')
                            trial_times{trial} = curr_fields{1};
                            trial_labels{trial} = curr_fields{3};
                            trial = trial + 1;
                        elseif strcmp(curr_fields{2}, 'AUDIO_PLAYBACK_ONSET') % Audio block
                            trial_times{trial} = curr_fields{1};
                            trial_labels{trial} = curr_fields{3};
                            trial = trial + 1;
%                             wav_filename =  curr_fields{4};
%                             IX_wav = strfind(wav_filename, '.wav');
%                             num_file = wav_filename(1:IX_wav-1);
%                             trial_times{trial} = curr_fields{1};
%                             trial_labels{trial} = num_file;
%                             trial = trial + 1;
                        end
                end
                fclose(fid);

                 if isempty(settings.conditions)
                    trials_info.trial_numbers_per_condition{1} =cellfun (@str2double, trial_labels);
                    if strcmp(settings.block_name, 'sentences')
                        switch settings.patient
                            case 'En_01'
                                trials_info.trial_numbers_per_condition{1} = 1:200;
                            case 'En_02'
                                trials_info.trial_numbers_per_condition{1} = 1:152;
                        end
                    end
                 end

                if settings.generate_condition_rasters
                    for cnd = 1:length(trials_info.trial_numbers_per_condition)
                            curr_condition_trials = trials_info.trial_numbers_per_condition{cnd};
                            trial_times_of_curr_condition = [];
                            for token = 1:length(curr_condition_trials)
                                curr_trial_number = curr_condition_trials(token);
                                if strcmp(settings.block_name, 'sentences')
                                    switch settings.lock_to_word
                                        case 'first' %Sentences have varying lengths - take the FIRST word.
                                                curr_token_number = sentences_start(curr_trial_number); 
                                        case 'last' %Sentences have varying lengths - take the LAST word.
                                                switch settings.patient
                                                    case 'En_01'
                                                        last_sentence = 200;
                                                        last_token = 702;
                                                    case {'En_02', 'patient_479'}
                                                        last_sentence = 152;
                                                        last_token = 508;
                                                end
                                                if curr_trial_number ~= last_sentence
                                                    curr_token_number = sentences_start(curr_trial_number+1)-1; 
                                                else
                                                    curr_token_number = last_token;
                                                end
                                        case 'subject'
                                            curr_token_number = sentences_start(curr_trial_number) + trials_info.category_position(curr_trial_number, 1) - 1; 
                                        case 'verb'
                                            curr_token_number = sentences_start(curr_trial_number) + trials_info.category_position(curr_trial_number, 2) - 1; 
                                        case 'object'
                                            curr_token_number = sentences_start(curr_trial_number) + trials_info.category_position(curr_trial_number, 3) - 1; 
                                        case 'audio'
                                            curr_token_number = curr_trial_number; 
                                    end
                                else
                                    curr_token_number = curr_trial_number;
                                end
                                IX = strcmp(num2str(curr_token_number), trial_labels);
                                if sum(IX)~=1
                                    error('No match between token numbers and paradigm log file')
                                else
                                    trial_times_of_curr_condition(token) = str2double(trial_times{IX});
                                end
                            end
                            % Add found trial timings to output cell array
                            trials_info.trial_times_per_condition{cnd} = trial_times_of_curr_condition;
                    end
                else
                    trials_info.trial_times_per_condition = [];
                end
    end

end