
function [stimulustraining,responsetraining,cresponsetraining,tstimcheck] = ATTEMORPH_FreeKey_RunTraining(sid,stimulustraining,manip) %%sid= subject identifier

% eyetrack = true;

addpath('./Toolbox/IO');
addpath('./Toolbox/Draw');

[nblocs, nstims] = size(stimulustraining);

responsetraining = nan(3,12,[]);

KbName('UnifyKeyNames');
%key used for the experiment
keywait = KbName('space');
keyquit = KbName('ESCAPE');
lKeyhand = KbName('S');
rKeyhand = KbName('L');

%dot's size
dotSize = 25;
%coefficients for the speed
coeffm = 1;
coeffs = 35;

try
    HideCursor;
    FlushEvents;
    
    ListenChar(2);
    Screen('Preference','VisualDebuglevel',3);
    Screen('Preference','SkipSyncTests',2);
    PsychImaging('PrepareConfiguration');
    PsychImaging('AddTask','General','UseFastOffscreenWindows');
    PsychImaging('AddTask','General','NormalizedHighresColorRange');
    video = struct;
    video.h = PsychImaging('OpenWindow',0,0);
    [video.x,video.y] = Screen('WindowSize',video.h);
    video.ifi = Screen('GetFlipInterval',video.h,100,50e-6,10);
    Screen('BlendFunction',video.h,GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
    LoadIdentityClut(video.h);
    Screen('ColorRange',video.h,1);
    Screen('TextFont',video.h,'Arial');
    Screen('TextSize',video.h,28);
    Screen('TextStyle',video.h,0);
    Priority(MaxPriority(video.h));
    
    Screen('FillRect',video.h,0);
    t = Screen('Flip',video.h);
    
    
    %     if eyetrack
    %         if EyelinkInit() ~= 1
    %             error('Could not initialize EyeLink connection!');
    %         end
    %         el = EyelinkInitDefaults(video.h);
    %     end
    
    roundfr = @(dt)(round(dt/video.ifi)-0.5)*video.ifi;
    aborted = false;
    
    for ibloc = 1:nblocs
                
        tstimcheck(ibloc).greyscreen = nan(1,nstims); %%%quand écran gris apparait
        tstimcheck(ibloc).scene = nan(1,nstims);%%%%quand scene+cross apparait
        tstimcheck(ibloc).repscreen = nan(1,nstims); %%%%quand écran de réponse apparait
        tstimcheck(ibloc).timescene = nan(1,nstims); %temps stim visible
        
        cresponsetraining(ibloc).firstChoice = zeros(1,nstims); % 1:left 2:right 0: no rep
        cresponsetraining(ibloc).timeFirstChoice = zeros(1,nstims); % 0: no rep
        cresponsetraining(ibloc).secondChoice = zeros(1,nstims); % 1:left 2:right 0: no final rep
        cresponsetraining(ibloc).timeSecondChoice = zeros(1,nstims); % 0:no final rep
        cresponsetraining(ibloc).timeBetweenAnswers = zeros(1,nstims); %time between first choice press and second choice press
        cresponsetraining(ibloc).timeGreyCross = zeros(1,nstims); %time fixation screen
        cresponsetraining(ibloc).dot = zeros(3, 2, nstims); %last coord of the dot when you push Q, when you push M and when you don't push any key
        cresponsetraining(ibloc).nbHesitations = zeros(1, nstims); %nb d'hesitations pour une seule direction
        cresponsetraining(ibloc).nbChoices = zeros(1, nstims); %nb de choix (max = 2)
        cresponsetraining(ibloc).timeRelease = zeros(1,nstims); %time button for first choice is release
        cresponsetraining(ibloc).timeReleasePress = zeros(1,nstims); %time between first choice release and second choice press
        cresponsetraining(ibloc).iscor = nan(1, nstims); % correct answer if resp is 1 or 2
        cresponsetraining(ibloc).resp = nan(1, nstims); %final answer
        
        %         if ibloc==1 || ibloc ==4 || ibloc==7
        %             if eyetrack
        %                 EyelinkDoTrackerSetup(el);
        %                 Screen('FillRect',video.h,0);
        %                 t = Screen('Flip',video.h);
        %             end
        %         end
        
        %instruction text
        %page 1
        labeltxt = strcat('Instructions :');
        labelrec = CenterRectOnPoint(Screen('TextBounds',video.h,labeltxt),video.x/2,video.y/2-300);
        Screen('DrawText',video.h,labeltxt,labelrec(1),labelrec(2),1);
        
        labeltxt = strcat('Une scène va apparaître, vous êtes dans une salle d''attente et vous devez choisir à quelle place vous souhaitez vous asseoir.');
        labelrec = CenterRectOnPoint(Screen('TextBounds',video.h,labeltxt),video.x/2,video.y/2-150);
        Screen('DrawText',video.h,labeltxt,labelrec(1),labelrec(2),1);
        
        labeltxt = strcat('Si vous souhaitez choisir le siège de gauche, appuyez sur S et si vous souhaitez choisir le siège de droite, appuyez sur L.');
        labelrec = CenterRectOnPoint(Screen('TextBounds',video.h,labeltxt),video.x/2,video.y/2-100);
        Screen('DrawText',video.h,labeltxt,labelrec(1),labelrec(2),1);
        
        labeltxt = strcat('Restez bien appuyé sur la touche JUSQU''A ce que votre photo apparaisse.');
        labelrec = CenterRectOnPoint(Screen('TextBounds',video.h,labeltxt),video.x/2,video.y/2);
        Screen('DrawText',video.h,labeltxt,labelrec(1),labelrec(2),1);
        
        labeltxt = strcat('A tout moment vous pouvez changer la direction du curseur en changeant de touche.');
        labelrec = CenterRectOnPoint(Screen('TextBounds',video.h,labeltxt),video.x/2,video.y/2+50);
        Screen('DrawText',video.h,labeltxt,labelrec(1),labelrec(2),1);
        
        labeltxt = strcat('Dans certains essais, les touches sont inversées, S amène votre curseur à droite et L à gauche. Restez attentifs !');
        labelrec = CenterRectOnPoint(Screen('TextBounds',video.h,labeltxt),video.x/2,video.y/2+150);
        Screen('DrawText',video.h,labeltxt,labelrec(1),labelrec(2),1);
        
        labeltxt = strcat('Merci d''appuyer sur espace pour afficher la suite des instructions');
        labelrec = CenterRectOnPoint(Screen('TextBounds',video.h,labeltxt),video.x/2,video.y/2+250);
        Screen('DrawText',video.h,labeltxt,labelrec(1),labelrec(2),1);
        
        Screen('DrawingFinished',video.h);
        Screen('Flip',video.h,t+roundfr(1.000+0.250*rand));
        
        WaitKeyPress(keywait);
        
        %page 2
        labeltxt = strcat('Avant chaque scène, un écran gris avec une croix de fixation va apparaître.');
        labelrec = CenterRectOnPoint(Screen('TextBounds',video.h,labeltxt),video.x/2,video.y/2-100);
        Screen('DrawText',video.h,labeltxt,labelrec(1),labelrec(2),1);
        
        labeltxt = strcat('Vous devrez fixer la croix TOUT AU LONG de l''essai.');
        labelrec = CenterRectOnPoint(Screen('TextBounds',video.h,labeltxt),video.x/2,video.y/2-50);
        Screen('DrawText',video.h,labeltxt,labelrec(1),labelrec(2),1);
        
        labeltxt = strcat('Vous n''avez le droit de changer de direction qu''UNE SEULE FOIS pour chaque scène.');
        labelrec = CenterRectOnPoint(Screen('TextBounds',video.h,labeltxt),video.x/2,video.y/2+50);
        Screen('DrawText',video.h,labeltxt,labelrec(1),labelrec(2),1);
        
        labeltxt = strcat('Merci d''appuyer sur espace pour lancer le bloc d''entrainement n°',num2str(ibloc),'/3');
        labelrec = CenterRectOnPoint(Screen('TextBounds',video.h,labeltxt),video.x/2,video.y/2+250);
        Screen('DrawText',video.h,labeltxt,labelrec(1),labelrec(2),1);
        
        Screen('DrawingFinished',video.h);
        Screen('Flip',video.h,t+roundfr(1.000+0.250*rand));
        %end instructions text
        
        WaitKeyPress(keywait);
        
        labeltxt = 'Préparez-vous !';
        labelrec = CenterRectOnPoint(Screen('TextBounds',video.h,labeltxt),video.x/2,video.y/2-100);
        Screen('DrawText',video.h,labeltxt,labelrec(1),labelrec(2),1);
        Screen('DrawingFinished',video.h);
        t = Screen('Flip',video.h);
        t = Screen('Flip',video.h,t+roundfr(1.000)); % flip after 1s
        
        %         if eyetrack
        %             Eyelink('OpenFile','ATTEM'); %open EDF file
        %             Eyelink('StartRecording');
        %         end
        
        for istim = 1:nstims
            
            responsetraining(ibloc, istim).firstChoice = 0;         % 1:left 2:right 0: no rep
            responsetraining(ibloc, istim).timeFirstChoice = 0;     % 0: no rep
            responsetraining(ibloc, istim).secondChoice = 0;        % 1:left 2:right 0: no final rep
            responsetraining(ibloc, istim).timeSecondChoice = 0;    % 0:no final rep
            responsetraining(ibloc, istim).timeBetweenAnswers = 0;  %time between first choice press and second choice press
            responsetraining(ibloc, istim).timeGreyCross = 0;       %time fixation screen
            responsetraining(ibloc, istim).dot = zeros(3, 2);       %last coord of the dot when you push Q, when you push M and when you don't push any key
            responsetraining(ibloc, istim).nbHesitations = 0;       %nb d'hesitations pour une seule direction
            responsetraining(ibloc, istim).nbChoices = 0;           %nb de choix (max = 2)
            responsetraining(ibloc, istim).timeRelease = 0;         %time button for first choice is release
            responsetraining(ibloc, istim).timeReleasePress = 0;    %time between first choice release and second choice press
            responsetraining(ibloc, istim).iscor = 0;               % correct answer if resp is 1 or 2
            responsetraining(ibloc, istim).resp = 0;                %final answer
            
            %dot coord for free choice
            dot = [960 950];
            
            %true if the subject can go in the two directions, false if not
            leftAutorization = true;
            rightAutorization = true;
            
            %the cursor target
            target = [];
            target.left = [365 505];
            target.right = [1555 505];
            
            %save if the previous choice : left(1), right(2), nothing(0)
            previousChoice = 0;
            %save if you're hesiting (=true) or doing a choice (=false)
            hesitation = false;
            
            %boolean to know if this item is reverse for the key directions
            reverse = stimulustraining(ibloc,istim).trial;
            
            %define a random time between 500ms and 750ms for greyscreen with cross
            timeCrossGrey = 0.500 + (randi(251)-1)/1000;
            
            %time with the scene
            timeStim = 1.500;
            
            %save the time for greyscreen with cross
            tstimcheck(ibloc).greyscreen(istim) = timeCrossGrey;
            
            tpreptotal = 0;
            
            if CheckKeyPress(keyquit)
                aborted = true;
                break;
            end
            
            [cross map alpha] = imread('CROSS3.png');
            cross(:,:,4) = alpha(:,:);
            
            img_greyscreen = double(imread('Greyscreen.jpg'))/255;
            img_greyscreen = img_greyscreen(:,:,1);
            
            img = double(imread(stimulustraining(ibloc, istim).file{1}))/255;
            img = img(:,:,1);
            
            img2 = double(imread(stimulustraining(ibloc, istim).file{2}))/255;
            img2 = img2(:,:,1);
            
            
            
            
            
            %PHOTO
            part = double(imread(['S' num2str(sid) '.jpg']))/255;
            part = part(:,:,1);
            
%            [part map alpha] = imread('test.jpg'); % a faire pour chaque sujet
%             part(:,:,4) = alpha(:,:); % a faire pour chaque sujet
            %
            %normalise average luminance and contrast
            x = img(:);
            x2 = img2(:);
            lumi_img = mean([x;x2]);
            cont_img = std([x;x2]);
            img = (img-lumi_img)/cont_img;
            img2 = (img2-lumi_img)/cont_img;
            
            img = 0.4284+img*0.2022;
            img2 = 0.4284+img2*0.2022;
            
            %grey screen without cross first
            patchtex = Screen('MakeTexture',video.h,img_greyscreen,[],[],1);
            patchrct = CenterRectOnPoint(Screen('Rect',patchtex),video.x/2,video.y/2);
            Screen('DrawTexture',video.h,patchtex,[],patchrct);
            
            tstimcheck(ibloc).greyscreen(istim) = Screen('Flip',video.h);
            
            %grey screen
            patchtex = Screen('MakeTexture',video.h,img_greyscreen,[],[],1);
            patchrct = CenterRectOnPoint(Screen('Rect',patchtex),video.x/2,video.y/2);
            Screen('DrawTexture',video.h,patchtex,[],patchrct);
            
            %cross
            patchtex = Screen('MakeTexture',video.h,cross,[],[],[]);
            patchrct = CenterRectOnPoint(Screen('Rect',patchtex),video.x/2,video.y/2-390);
            Screen('DrawTexture',video.h,patchtex,[],patchrct);
            
            WaitSecs(0.500);
            
            %wait no key press to continue
            keyRelease = true;
            while keyRelease
                [iskeydown,t,keys] = KbCheck(-1);
                keyRelease = any(keys(1:256) > 0);
            end
            
            t0 = Screen('Flip',video.h); %affichage grey+cross
            
            WaitSecs(timeCrossGrey - (GetSecs-t0));
            
            tstim2 = GetSecs;
            while ( (t0 - tstim2) < (timeStim + tpreptotal) && dot(2) > target.left(2) )
                tprep = GetSecs;
                if stimulustraining(ibloc, istim).gender == 1
                    %1st actor male
                    patchtex = Screen('MakeTexture',video.h,img,[],[],1);
                    patchrct = CenterRectOnPoint(Screen('Rect',patchtex),video.x/2-400,video.y/2); %376
                    Screen('DrawTexture',video.h,patchtex,[],patchrct);
                    
                    %2nd actor male
                    patchtex = Screen('MakeTexture',video.h,img2,[],[],1);
                    patchrct = CenterRectOnPoint(Screen('Rect',patchtex),video.x/2+400,video.y/2);
                    Screen('DrawTexture',video.h,patchtex,[],patchrct);
                else
                    %1st actor female
                    patchtex = Screen('MakeTexture',video.h,img,[],[],1);
                    patchrct = CenterRectOnPoint(Screen('Rect',patchtex),video.x/2-394,video.y/2); %370
                    Screen('DrawTexture',video.h,patchtex,[],patchrct);
                    
                    %2nd actor female
                    patchtex = Screen('MakeTexture',video.h,img2,[],[],1);
                    patchrct = CenterRectOnPoint(Screen('Rect',patchtex),video.x/2+394,video.y/2);
                    Screen('DrawTexture',video.h,patchtex,[],patchrct);
                end
                
                %cross
                patchtex = Screen('MakeTexture',video.h,cross,[],[],[]);
                patchrct = CenterRectOnPoint(Screen('Rect',patchtex),video.x/2,video.y/2-390);
                Screen('DrawTexture',video.h,patchtex,[],patchrct);
                
                %show the target points ONLY IN TRAINING
                Screen('DrawDots', video.h, target.left, dotSize, [0 0 0 1]);
                Screen('DrawDots', video.h, target.right, dotSize, [0 0 0 1]);
                
                %save answer
                answerTime = GetSecs - tstim2 - tpreptotal;
                time = timeStim - answerTime;
                % (if 'Q' is down and not 'M' and this is NOT a reverse item ) OR (if 'M' is down and not 'Q' and this is a reverse item)...

                if ((CheckKeyPress(lKeyhand) && ~CheckKeyPress(rKeyhand) && ~reverse) || (CheckKeyPress(rKeyhand) && ~CheckKeyPress(lKeyhand) && reverse)) && leftAutorization
                    %define the speed inf function of distance 
                    if hesitation || previousChoice ~= 1
                        distance = sqrt((dot(1)-target.left(1)).^2 + (dot(2)-target.left(2)).^2);
                        drawSpeed = (coeffm*distance) / (coeffs*time);
                    end
                    
                    %save the choice and incremente the number of choice
                    if previousChoice ~= 1
                        responsetraining(ibloc, istim).nbChoices = 1 + responsetraining(ibloc, istim).nbChoices;
                        previousChoice = 1;
                    elseif hesitation && previousChoice == 1 && responsetraining(ibloc, istim).firstChoice ~= 0
                        responsetraining(ibloc, istim).nbHesitations = responsetraining(ibloc, istim).nbHesitations + 1;
                    end
                    hesitation = false;

                    if responsetraining(ibloc, istim).nbChoices == 1
                        responsetraining(ibloc, istim).timeRelease = answerTime;
                    end

                    % save the time and the choice for the answer
                    if responsetraining(ibloc, istim).firstChoice == 0

                        responsetraining(ibloc, istim).timeFirstChoice = answerTime;
                        if reverse
                            responsetraining(ibloc, istim).firstChoice = 2;
                        else
                            responsetraining(ibloc, istim).firstChoice = 1;
                        end

                    elseif (responsetraining(ibloc, istim).secondChoice == 0) && (responsetraining(ibloc, istim).nbChoices == 2)

                        responsetraining(ibloc, istim).timeSecondChoice = answerTime;
                        if reverse
                            responsetraining(ibloc, istim).secondChoice = 2;
                        else
                            responsetraining(ibloc, istim).secondChoice = 1;
                        end
                        responsetraining(ibloc, istim).timeBetweenAnswers = answerTime - responsetraining(ibloc, istim).timeFirstChoice;
                        responsetraining(ibloc, istim).timeReleasePress = answerTime - responsetraining(ibloc, istim).timeRelease;
                    end

                    %save dot position
                    responsetraining(ibloc, istim).dot(1, 1) = dot(1);
                    responsetraining(ibloc, istim).dot(1, 2) = dot(2);

                    %...draw a dot towards left
                    Screen('DrawDots', video.h, dot, dotSize, [255 0 0 1]);

                    %update dot coord
                    dot = nextpoint(dot, target.left, dot(1)-drawSpeed);
                    %indicate the last choice is left

                    if responsetraining(ibloc, istim).nbChoices > 1
                        rightAutorization = false;
                    end

                    responsetraining(ibloc, istim).resp = 1;

                    % else (if 'M' is down and not 'Q' and this is NOT a reverse item ) OR (if 'Q' is down and not 'M' and this is a reverse item)...
                elseif ((CheckKeyPress(rKeyhand) && ~CheckKeyPress(lKeyhand) && ~reverse) || (CheckKeyPress(lKeyhand) && ~CheckKeyPress(rKeyhand) && reverse)) && rightAutorization
                    if hesitation || previousChoice ~= 2
                        distance = sqrt((dot(1)-target.right(1)).^2 + (dot(2)-target.right(2)).^2);
                        drawSpeed = (coeffm*distance) / (coeffs*time);
                    end

                    %if the last choice wasn't this way
                    if previousChoice ~= 2
                        responsetraining(ibloc, istim).nbChoices = 1 + responsetraining(ibloc, istim).nbChoices;
                        previousChoice = 2;
                    %else if the last choice is this way but the key was release
                    elseif hesitation && previousChoice == 2 && responsetraining(ibloc, istim).firstChoice ~= 0
                        responsetraining(ibloc, istim).nbHesitations = responsetraining(ibloc, istim).nbHesitations + 1;
                    end
                    hesitation = false;

                    if responsetraining(ibloc, istim).nbChoices == 1
                        responsetraining(ibloc, istim).timeRelease = answerTime;
                    end

                    %if it's the first choice
                    if responsetraining(ibloc, istim).firstChoice == 0

                        responsetraining(ibloc, istim).timeFirstChoice = answerTime;

                        if reverse
                            responsetraining(ibloc, istim).firstChoice = 1;
                        else
                            responsetraining(ibloc, istim).firstChoice = 2;
                        end

                    %if it's the second choice
                    elseif (responsetraining(ibloc, istim).secondChoice == 0) && (responsetraining(ibloc, istim).nbChoices == 2)
                        responsetraining(ibloc, istim).timeSecondChoice = answerTime;
                        if reverse
                            responsetraining(ibloc, istim).secondChoice = 1;
                        else
                            responsetraining(ibloc, istim).secondChoice = 2;
                        end
                        responsetraining(ibloc, istim).timeBetweenAnswers = answerTime - responsetraining(ibloc, istim).timeFirstChoice;
                        responsetraining(ibloc, istim).timeReleasePress = answerTime - responsetraining(ibloc, istim).timeRelease;
                    end

                    %save dot position
                    responsetraining(ibloc, istim).dot(2, 1) = dot(1);
                    responsetraining(ibloc, istim).dot(2, 2) = dot(2);

                    %...draw a dot towards right
                    Screen('DrawDots', video.h, dot, dotSize, [255 0 0 1]);

                    %update coord for dots and neutral line
                    dot = nextpoint(dot, target.right, dot(1)+drawSpeed);

                    %if the number of choice > 1, we can't go to the other way
                    if responsetraining(ibloc, istim).nbChoices > 1
                        leftAutorization = false;
                    end

                    responsetraining(ibloc, istim).resp = 2;

                % else if the 2 keys are down is the same time or if anykey is down...
                else
                    if ~hesitation
                        distance = dot(2)-target.left(2);
                        drawSpeed = (coeffm*distance) / (coeffs*time);
                    end

                    %save dot position
                    responsetraining(ibloc, istim).dot(3, 1) = dot(1);
                    responsetraining(ibloc, istim).dot(3, 2) = dot(2);

                    %... draw a neutral dot
                    Screen('DrawDots', video.h, dot, dotSize, [255 0 0 1]);
                    

                    %update coord for nexts dots and neutral line
                    dot(2) = dot(2)-drawSpeed;

                    %indicate the last choice is neutral
                    hesitation = true;

                    responsetraining(ibloc, istim).resp = 0;
                end
                t0 = Screen('Flip',video.h);
                if tpreptotal == 0
                    tpreptotal = t0-tprep;
                end
                if CheckKeyPress(keyquit)
                    aborted = true;
                    break;
                end      
            end
            %calcul scene
            tstimcheck(ibloc).repscreen(istim)=t0-tstim2-tpreptotal;
            
            if aborted
                break;
            end
            
            %enregistre la nature de la réponse
            responsetraining(ibloc, istim).iscor = (responsetraining(ibloc, istim).resp == 1 || responsetraining(ibloc, istim).resp == 2 );
            % si rep sur siege, affichage face pdt 300ms, sinon rappel des consignes
            if responsetraining(ibloc, istim).iscor
                
                if stimulustraining(ibloc, istim).gender == 1
                    %1st actor male
                    patchtex = Screen('MakeTexture',video.h,img,[],[],1);
                    patchrct = CenterRectOnPoint(Screen('Rect',patchtex),video.x/2-400,video.y/2); %376
                    Screen('DrawTexture',video.h,patchtex,[],patchrct);
                    
                    %2nd actor male
                    patchtex = Screen('MakeTexture',video.h,img2,[],[],1);
                    patchrct = CenterRectOnPoint(Screen('Rect',patchtex),video.x/2+400,video.y/2);
                    Screen('DrawTexture',video.h,patchtex,[],patchrct);
                else
                    %1st actor female
                    patchtex = Screen('MakeTexture',video.h,img,[],[],1);
                    patchrct = CenterRectOnPoint(Screen('Rect',patchtex),video.x/2-394,video.y/2); %370
                    Screen('DrawTexture',video.h,patchtex,[],patchrct);
                    
                    %2nd actor female
                    patchtex = Screen('MakeTexture',video.h,img2,[],[],1);
                    patchrct = CenterRectOnPoint(Screen('Rect',patchtex),video.x/2+394,video.y/2);
                    Screen('DrawTexture',video.h,patchtex,[],patchrct);
                end
                
                %cross
                patchtex = Screen('MakeTexture',video.h,cross,[],[],[]);
                patchrct = CenterRectOnPoint(Screen('Rect',patchtex),video.x/2,video.y/2-390);
                Screen('DrawTexture',video.h,patchtex,[],patchrct);
                
                %                    patchtex = Screen('MakeTexture',video.h,part,[],[],[]);
                patchtex = Screen('MakeTexture',video.h,part,[],[],1);
                if responsetraining(ibloc, istim).resp == 1
                    patchrct = CenterRectOnPoint(Screen('Rect',patchtex),target.left(1)-50, video.y-target.left(2)-170); % changer coordonées video.x/2-500,video.y/2-150
                elseif responsetraining(ibloc, istim).resp == 2
                    patchrct = CenterRectOnPoint(Screen('Rect',patchtex),target.right(1)+50, video.y-target.right(2)-170);
                end
                Screen('DrawTexture',video.h,patchtex,[],patchrct);
                Screen('Flip',video.h); %affichage scene+cross
            else
                labeltxt = strcat('ESSAI INCORRECT !');
                labelrec = CenterRectOnPoint(Screen('TextBounds',video.h,labeltxt),video.x/2,video.y/2-310);
                Screen('DrawText',video.h,labeltxt,labelrec(1),labelrec(2),1);
                
                labeltxt = strcat('Vous n''avez pas atteint de siège ou vous avez tenté de changer de direction une deuxième fois.');
                labelrec = CenterRectOnPoint(Screen('TextBounds',video.h,labeltxt),video.x/2,video.y/2);
                Screen('DrawText',video.h,labeltxt,labelrec(1),labelrec(2),1);
                
                labeltxt = strcat('Merci d''appuyer sur [espace] pour continuer');
                labelrec = CenterRectOnPoint(Screen('TextBounds',video.h,labeltxt),video.x/2,video.y/2+310);
                Screen('DrawText',video.h,labeltxt,labelrec(1),labelrec(2),1);

                Screen('DrawingFinished',video.h);
                t=Screen('Flip', video.h);
                WaitKeyPress(keywait);
            end
            
            %save answer by category
            cresponsetraining(ibloc).firstChoice(1,istim) = responsetraining(ibloc,istim).firstChoice;
            cresponsetraining(ibloc).timeFirstChoice(1,istim) = responsetraining(ibloc,istim).timeFirstChoice;
            cresponsetraining(ibloc).secondChoice(1,istim) = responsetraining(ibloc,istim).secondChoice;
            cresponsetraining(ibloc).timeSecondChoice(1,istim) = responsetraining(ibloc,istim).timeSecondChoice;
            cresponsetraining(ibloc).timeBetweenAnswers(1,istim) = responsetraining(ibloc,istim).timeBetweenAnswers;
            cresponsetraining(ibloc).timeGreyCross(1,istim) = responsetraining(ibloc,istim).timeGreyCross;
            cresponsetraining(ibloc).dot(:, :, istim) = responsetraining(ibloc,istim).dot(:,:);
            cresponsetraining(ibloc).nbHesitations(1,istim) = responsetraining(ibloc,istim).nbHesitations;
            cresponsetraining(ibloc).nbChoices(1,istim) = responsetraining(ibloc,istim).nbChoices;
            cresponsetraining(ibloc).timeRelease(1,istim) = responsetraining(ibloc,istim).timeRelease;
            cresponsetraining(ibloc).timeReleasePress(1,istim) = responsetraining(ibloc,istim).timeReleasePress;
            cresponsetraining(ibloc).iscor(1,istim) = responsetraining(ibloc,istim).iscor;
            cresponsetraining(ibloc).resp(1,istim) = responsetraining(ibloc,istim).resp;
            
            %load ecran gris
            patchtex = Screen('MakeTexture',video.h,img_greyscreen,[],[],1);
            patchrct = CenterRectOnPoint(Screen('Rect',patchtex),video.x/2,video.y/2);
            Screen('DrawTexture',video.h,patchtex,[],patchrct);
            t1=GetSecs;
            t=Screen('Flip',video.h,t1+0.300); %affichage ecran gris+cross
            
            
            Screen('Close');
        end
        
        %         if eyetrack...
        
        if ~aborted
            
            maccur = mean(cresponsetraining(ibloc).iscor == 1);
            mspeed = mean(cresponsetraining(ibloc).timeFirstChoice(cresponsetraining(ibloc).iscor == 1));
            
            %feedback on performance for the last bloc
            labeltxt = {};
            labelrec = [];
            labeltxt{1} = sprintf('Précision : %.0f %%',maccur*100);
            labelrec(1,:) = CenterRectOnPoint(Screen('TextBounds',video.h,labeltxt{1}),video.x/2,video.y/2-32);
            labeltxt{2} = sprintf('Rapidité : %.0f ms',mspeed*1000);
            labelrec(2,:) = CenterRectOnPoint(Screen('TextBounds',video.h,labeltxt{2}),video.x/2,video.y/2+32);
            labelrec(2,:) = AlignRect(labelrec(2,:),labelrec(1,:),'left');
            framerec = [min(labelrec(:,1))-round(32),min(labelrec(:,2))-round(32),max(labelrec(:,3))+round(32),max(labelrec(:,4))+round(32)];
            
            labeltxt{3} = sprintf('Appuyez sur [espace] pour lancer le bloc suivant');
            labelrec(3,:) = CenterRectOnPoint(Screen('TextBounds',video.h,labeltxt{3}),video.x/2,video.y/2+200);
            
            Screen('FrameRect',video.h,1,framerec,3);
            Screen('DrawText',video.h,labeltxt{1},labelrec(1,1),labelrec(1,2),1);
            Screen('DrawText',video.h,labeltxt{2},labelrec(2,1),labelrec(2,2),1);
            Screen('DrawText',video.h,labeltxt{3},labelrec(3,1),labelrec(3,2),1);
            Screen('DrawingFinished',video.h);
            
            Screen('Flip',video.h);
            WaitKeyPress(keywait);
            t = Screen('Flip',video.h);
            
        end
        
        if aborted
            break;
        end
        
    end
    
    Priority(0);
    Screen('CloseAll');
    FlushEvents;
    ListenChar(0);
    ShowCursor;
    
catch
    
    Priority(0);
    Screen('CloseAll');
    FlushEvents;
    ListenChar(0);
    ShowCursor;
    
    rethrow(lasterror);
    
    
end
end