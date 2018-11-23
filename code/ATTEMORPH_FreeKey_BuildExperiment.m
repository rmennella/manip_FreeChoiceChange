function [stimulus] = ATTEMORPH_FreeKey_BuildExperiment(sid)
%  ATTEMORPH_BuildExperiment  Build experiment
%  Build all stims for the experiment
%  Conditions : 
%       => always a normal trial after a reverse trial
%       => 6 blocs of 60 stims
%
%  Input argument:
%       => sid - subject identifier
%  Output argument:
%       => stimulus for the participant divide in blocs

% if nargin < 1
%     error('missing subject identifier!');
% end

addpath('Toolbox/Rand');

sOrient = {'L_cent','R_cent'}; % pour acteurs présentés au centre
folder = 'center';


if ~exist(strcat('../stim_',folder),'dir')
    error('stim folder not found!');
end

% letters use to find the actors images for the stim 
sEmot = {'A','F','N'};  %emotions letters : A => Anger, F => Fear, N => Neutral
sSide = {'L','R','N'};  %letters for the emotion side in the scene : L => left, R => right, N => no emotion

nbPair = 5;             %number of pairs by gender
nbActor = 2;            %number of actors by pair
nbGender = 2;           %number of gender
nbOrientation = 2;      %number of organisation possible for actors

nbBlocs = 6;                        %number of blocs of stims
nbStimsTotal = 360;                 %number total of stims
nbStims = nbStimsTotal/nbBlocs;     %number of stims by bloc

stimulus = nan(nbBlocs,nbStims,[]); %matrix to fill with a random order of the stims

%to find easier actors, creation of a matrix with all combinaisons possible

%men actors
mactone = {'M02' 'M03' 'M04' 'M06' 'M14'};
macttwo = {'M16' 'M10' 'M15' 'M11' 'M18'};

%women actors
factone = {'F01' 'F04' 'F06' 'F10' 'F14'};
facttwo = {'F02' 'F12' 'F09' 'F13' 'F15'};

actors = cell(nbActor,nbPair,nbGender,nbOrientation); %actors(nbactor, pair, gender, orientation)

actors(1,:,1,1) = mactone;
actors(2,:,1,1) = macttwo;
actors(1,:,2,1) = factone;
actors(2,:,2,1) = facttwo;
actors(1,:,1,2) = macttwo;
actors(2,:,1,2) = mactone;
actors(1,:,2,2) = facttwo;
actors(2,:,2,2) = factone;

%CREATION OF ALL POSSIBILITIES OF STIM
stimAll = zeros(7, 360);
stimAll(1,:) = repmat(kron(1:3, ones(1,120)), 1);                                       %emotions (1:Anger 2:Fear 3:Neutral)
stimAll(2,:) = repmat(kron(1:2, ones(1,60)), [1,3]);                                    %gender (1:Male 2:Female)
stimAll(3,:) = repmat(kron(1:5, ones(1,12)), [1,6]);                                    %pair (1 to 5)
stimAll(4,:) = repmat(kron(1:2, ones(1,6)), [1,30]);                                    %orientation (1: actor1-actor2 2:actor2-actor1)
stimAll(5,:) = [repmat(kron(1:2, ones(1,3)), [1,40]) repmat(kron(3, ones(1,120)), 1)];  %side (1:left, 2:right 3:neutral)
stimAll(6,:) = [repmat(kron(7, ones(1,240)), 1) repmat(kron(0, ones(1,120)), 1)];       %intensity (0:neutral 7:high anger or fear)
stimAll(7,:) = repmat(kron(1:3, ones(1)), [1,120]);                                     %trial (1:reverse 2/3:normal)

%in stimAll(7,:), change 2 and 3 in 0
for i = 1:length(stimAll)
    if (stimAll(7, i) == 2 || stimAll(7, i) == 3)
        stimAll(7, i) = 0;
    end
end

%shuffle the cols to randomize until there is less than 20 time two once or more consecutively
stimAll = randpermcol(stimAll);

compte = NumConsecutiveValues(stimAll, 7, 1);
while compte > 21
    stimAll = randpermcol(stimAll);
    compte = NumConsecutiveValues(stimAll, 7, 1);
end

%separate the stims in blocs
for ibloc = 1:nbBlocs
    fprintf('generating bloc %d... ',ibloc);
    for istim = 1:nbStims
        
        indice = (ibloc-1)*nbStims + istim;
        
        stimulus(ibloc,istim).emotion = sEmot{stimAll(1, indice)};
        stimulus(ibloc,istim).trial = stimAll(7, indice);
        
        stimulus(ibloc,istim).gender = stimAll(2, indice);
        stimulus(ibloc,istim).pair = stimAll(3, indice);
        
        stimulus(ibloc,istim).side = sSide{stimAll(5, indice)};
        stimulus(ibloc,istim).orient = stimAll(4, indice);
        stimulus(ibloc,istim).intensity = stimAll(6, indice);
        
        stimulus(ibloc,istim).actor1 = actors{1,stimulus(ibloc,istim).pair,stimAll(2, indice),stimulus(ibloc,istim).orient};
        stimulus(ibloc,istim).actor2 = actors{2,stimulus(ibloc,istim).pair,stimAll(2, indice),stimulus(ibloc,istim).orient};
        
        left = [];
        right = [];
        if stimAll(5, indice) == 1
            left.emo = stimAll(1, indice);
            right.emo = 3;
        elseif stimAll(5, indice) == 2
            left.emo = 3;
            right.emo = stimAll(1, indice);
        else
            left.emo = 3;
            right.emo = 3;
        end
        
        if right.emo == 3
            right.intensity = 0;
        else
            right.intensity = 7;
        end
        
        if left.emo == 3
            left.intensity = 0;
        else
            left.intensity = 7;
        end
        
        if stimulus(ibloc,istim).orient == 1
            left.orient = 1;
            right.orient = 2;
        else
            left.orient = 2;
            right.orient = 1;
        end
        
        stimulus(ibloc,istim).file{1} = sprintf(strcat('../stim_',folder,'/%s_D_%c_%d_',sOrient{1},'.jpg'), ... %formate les noms de fichiers
            actors{1,stimulus(ibloc,istim).pair,stimAll(2, indice),stimulus(ibloc,istim).orient}, ...
            sEmot{left.emo}, ...
            left.intensity);
        
        stimulus(ibloc,istim).file{2} = sprintf(strcat('../stim_',folder,'/%s_D_%c_%d_',sOrient{2},'.jpg'), ... %formate les noms de fichiers
            actors{2,stimulus(ibloc,istim).pair,stimAll(2, indice),stimulus(ibloc,istim).orient}, ...
            sEmot{right.emo}, ...
            right.intensity) ;
    end
    
    compte1 = 0;
    for i = 1 : (nbStims/2)-1
        if (stimulus(ibloc,i).trial == 1) && (stimulus(ibloc,i+1).trial == 1)
            compte1 = compte1+1;
        end
    end
    while compte1 > 0
        stimulus(ibloc,1:(nbStims/2)) = randbloc(stimulus(ibloc,1:(nbStims/2)));
        compte1 = 0;
        for i = 1:(nbStims/2)-1
            if (stimulus(ibloc,i).trial == 1) && (stimulus(ibloc,i+1).trial == 1)
                compte1 = compte1+1;
            end
        end
    end
    
    compte2 = 0;
    for i = (nbStims/2):nbStims-1
        if (stimulus(ibloc,i).trial == 1) && (stimulus(ibloc,i+1).trial == 1)
            compte2 = compte2+1;
        end
    end
    while compte2 > 0
        stimulus(ibloc,(nbStims/2):nbStims) = randbloc(stimulus(ibloc,(nbStims/2):nbStims));
        compte2 = 0;
        for i = (nbStims/2):nbStims-1
            if (stimulus(ibloc,i).trial == 1) && (stimulus(ibloc,i+1).trial == 1)
                compte2 = compte2+1;
            end
        end
    end
    fprintf('done!\n');
end
save('stimulus');
end

