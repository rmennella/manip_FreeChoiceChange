% BEFORE RUNNING THE SCRIPT FOR THE FIRST TIME FOR EACH SUBJECT BE SURE THAT YOU CLEAR ALL

% initialise random number generator
seed = sum(100*clock);
rand('twister',seed);
randn('state',seed);


% If it's the first run, get all the info
if ~exist('participant', 'var')
    %% SETUP
    clear('all');
    close('all');
    clc;
    
    % get participant information
    argindlg = inputdlg({'Identifier (S##)','Gender (M/F)','Age (y)','Handedness (L/R)', 'MRI (0,1)', 'eyetracker (0,1)', 'Training (0) or Task (1)'},'',1);
    if isempty(argindlg)
        error('Experiment cancelled!');
    end
    
    participant            = [];
    participant.identifier = argindlg{1};
    participant.gender     = argindlg{2};
    participant.age        = argindlg{3};
    participant.handedness = argindlg{4};
    participant.date       = datestr(now,'yyyymmdd-HHMM');
    task = str2double(argindlg{7});
    
    % check subject identifier
    sid = sscanf(participant.identifier,'S%d');
    if isempty(sid)
        error('Invalid subject identifier!');
    end
    
    % set eyetracker code as the pre_definite in case of missing input argument
    if isempty(argindlg{6})
            eyetracker = 1;
    else
        eyetracker = str2double(argindlg{6});
    end

    
    
    % set MRI code as the pre_definite in case of missing input argument
    if isempty(argindlg{5})
        isIRM = 1;
    else
        isIRM = str2double(argindlg{5});
    end
    
else % otherwise just ask if training or task is wanted
    
    task = str2double(inputdlg({'Training (0) or Task (1)'},'',1));
    
    % Training again or true task?
    if isempty(task)
        error('Specify if you want to launch training or task');
    end
    
end

% load proper randomisation (if not previously done)
if ~exist('stimulus', 'var')
    %NO NEED TO BUILD IT, WE ALREADY BUILT THEM IN ADVANCE. LOAD THEM
    %stimulus = ATTEMORPH_FreeKey_BuildExperiment(sid);
    load(sprintf('../randomisation_procedure/selectedRandomisations/S%02d/stimulus.mat', sid))
end

if ~task
    %% TRAINING CENTER
    %build training
    stimulustraining = ATTEMORPH_FreeKey_BuildTraining();
    
    % run training
    for tr_bloc = 1:size(stimulustraining,1)
        %[stimulustraining,responsetraining,cresponsetraining,tstimchecktraining] = ATTEMORPH_FreeKey_RunTraining(sid,stimulustraining,2);
        [~,~,~,~, ~, ~, aborted] = ATTEMORPH_FreeKey_RunExperiment(sid,stimulustraining,0 , 0, tr_bloc, 0);
        if aborted
            break
        end
    end
    
else
    %% EXPERIMENT MANIP CENTER
    % in this version of the code we run bloc separately in order to be sure
    % that if something happens we can still restart from the block that we want
    
    % If something goes wrong and you want to restart from the last block, just clear all,
    % reload the last good block, and run. Otherwise, you can simply click again Run and it will continue
    % from the next one
    
    %--------------------------------- DO YOU WANT TO SIMULATE A PARTICIPANT?------------------------------%
    % THIS WORKS ONLY FOR IRM
    isRobot = 1;
    %------------------------------------------------------------------------------------------------------%
    
    %  let's keep track of the fact that there are or not already executed blocs
    if exist('doneBlocks', 'var')
        ibloc = doneBlocks + 1;
    else
        ibloc = 1;
    end
    
    
    % print inform on block about to run
    fprintf('Running Block %d', ibloc)
    
    % run experiment
    [stimulus,response,cresponse,tstimcheck,T0,simulate_respCheck] = ATTEMORPH_FreeKey_RunExperiment(sid,stimulus, isIRM, eyetracker, ibloc, isRobot);
    
    % after the block has been executed let's update doneBlocks
    doneBlocks = ibloc;
    
    % save data at each block, including present block number)
    filename = sprintf('../data/ATTEMORPH_FreeKey_%s_%s_block%d.mat',participant.identifier,participant.date,ibloc);
    
    save(filename,'participant','stimulus','response','cresponse','ibloc','doneBlocks','sid', 'isIRM','tstimcheck','T0', 'simulate_respCheck');
    
    % print out executed block
    fprintf('Last block executed was Block %d', ibloc)
    
    % plot time diagnostics
    checkTiming
    
end