
function [j, thePoints,nextTime] = filter_picture_fast_points(stimulus,img,img2,ibloc,istim,y,theta,video,j,cross,thePoints,ta,theX,theY,nextTime,sampleTime)
if stimulus(ibloc).gend(istim)==1
    coord = 415;
else
    coord = 415;
end

if y>750
    
    len =  .1*y-750*.1;
    psf=fspecial('motion',len,theta);
    [x,y,buttons] = GetMouse(0);
    td=GetSecs;
    
    if (x ~= theX || y ~= theY)
        
        if (GetSecs > nextTime)
            thePoints = [thePoints ; x y];
            nextTime = nextTime+sampleTime;
        end
        
        theX = x; theY = y;
    end
    tic
    imgB=imfilter(img,psf,'replicate');
    [x,y,buttons] = GetMouse(0);
    te=toc
    if (x ~= theX || y ~= theY)
        
        if (GetSecs > nextTime)
            thePoints = [thePoints ; x y];
            nextTime = nextTime+sampleTime;
        end
        
        theX = x; theY = y;
    end
    tic
    img2B=imfilter(img2,psf,'replicate');
    toc
    [x,y,buttons] = GetMouse(0);
    tf=GetSecs-te
    
    if (x ~= theX || y ~= theY)
        
        if (GetSecs > nextTime)
            thePoints = [thePoints ; x y];
            nextTime = nextTime+sampleTime;
        end
        
        theX = x; theY = y;
    end
    tic
    patchtex = Screen('MakeTexture',video.h,imgB,[],[],1);
    toc
    [x,y,buttons] = GetMouse(0);
    tg=GetSecs-tf
    
    if (x ~= theX || y ~= theY)
        
        if (GetSecs > nextTime)
            thePoints = [thePoints ; x y];
            nextTime = nextTime+sampleTime;
        end
        
        theX = x; theY = y;
    end
    tic
    patchrct = CenterRectOnPoint(Screen('Rect',patchtex),video.x/2-coord,video.y/2);
    toc
    [x,y,buttons] = GetMouse(0);
    th=GetSecs-tg
    
    if (x ~= theX || y ~= theY)
        
        if (GetSecs > nextTime)
            thePoints = [thePoints ; x y];
            nextTime = nextTime+sampleTime;
        end
        
        theX = x; theY = y;
    end
    tic
    Screen('DrawTexture',video.h,patchtex,[],patchrct);
    toc
    [x,y,buttons] = GetMouse(0);
    ti=GetSecs-th
    
    if (x ~= theX || y ~= theY)
        
        if (GetSecs > nextTime)
            thePoints = [thePoints ; x y];
            nextTime = nextTime+sampleTime;
        end
        
        theX = x; theY = y;
    end
    tic
    patchtex = Screen('MakeTexture',video.h,img2B,[],[],1);
    toc
    [x,y,buttons] = GetMouse(0);
    tj=GetSecs-ti
    
    if (x ~= theX || y ~= theY)
        
        if (GetSecs > nextTime)
            thePoints = [thePoints ; x y];
            nextTime = nextTime+sampleTime;
        end
        
        theX = x; theY = y;
    end
    tic
    patchrct = CenterRectOnPoint(Screen('Rect',patchtex),video.x/2+coord,video.y/2);%376
    toc
    [x,y,buttons] = GetMouse(0);
    tk=GetSecs
    
    if (x ~= theX || y ~= theY)
        
        if (GetSecs > nextTime)
            thePoints = [thePoints ; x y];
            nextTime = nextTime+sampleTime;
        end
        
        theX = x; theY = y;
    end
    tic
    Screen('DrawTexture',video.h,patchtex,[],patchrct);
    toc
    [x,y,buttons] = GetMouse(0);
    tl=GetSecs-tk
    
    if (x ~= theX || y ~= theY)
        
        if (GetSecs > nextTime)
            thePoints = [thePoints ; x y];
            nextTime = nextTime+sampleTime;
        end
        
        theX = x; theY = y;
    end
    tic
    patchtex = Screen('MakeTexture',video.h,cross,[],[],[]);
    [x,y,buttons] = GetMouse(0);
    toc
    tm=GetSecs-tl
    
    if (x ~= theX || y ~= theY)
        
        if (GetSecs > nextTime)
            thePoints = [thePoints ; x y];
            nextTime = nextTime+sampleTime;
        end
        
        theX = x; theY = y;
    end
    tic
    patchrct = CenterRectOnPoint(Screen('Rect',patchtex),video.x/2,video.y/2-390);
    toc
    [x,y,buttons] = GetMouse(0);
    tn=GetSecs-tm
    
    if (x ~= theX || y ~= theY)
        
        if (GetSecs > nextTime)
            thePoints = [thePoints ; x y];
            nextTime = nextTime+sampleTime;
        end
        
        theX = x; theY = y;
    end
    tic
    Screen('DrawTexture',video.h,patchtex,[],patchrct);
    toc
    [x,y,buttons] = GetMouse(0);
    to=GetSecs-tn
    
    if (x ~= theX || y ~= theY)
        
        if (GetSecs > nextTime)
            thePoints = [thePoints ; x y];
            nextTime = nextTime+sampleTime;
        end
        
        theX = x; theY = y;
    end
    tic
    Screen('FillRect', video.h, [0.1 0.1 0.1 0.6],  [940   810  990  870]);
    toc
    [x,y,buttons] = GetMouse(0);  
    tp=GetSecs-to
    
    if (x ~= theX || y ~= theY)
        
        if (GetSecs > nextTime)
            thePoints = [thePoints ; x y];
            nextTime = nextTime+sampleTime;
        end
        
        theX = x; theY = y;
    end
    tqr=GetSecs
    tic
    Screen('Flip',video.h);
    [x,y,buttons] = GetMouse(0);
    toc
    tq=GetSecs
    top=tqr-tq
    tq=GetSecs-tp
    
    if (x ~= theX || y ~= theY)
        
        if (GetSecs > nextTime)
            thePoints = [thePoints ; x y];
            nextTime = nextTime+sampleTime;
        end
        
        theX = x; theY = y;
    end
    
    
    
    
    
else
    
    len =  .01;
    psf=fspecial('motion',len,theta);
    [x,y,buttons] = GetMouse(0);
    td=GetSecs-ta
    
    if (x ~= theX || y ~= theY)
        
        if (GetSecs > nextTime)
            thePoints = [thePoints ; x y];
            nextTime = nextTime+sampleTime;
        end
        
        theX = x; theY = y;
    end
    imgB=imfilter(img,psf,'replicate');
    [x,y,buttons] = GetMouse(0);
    td=GetSecs-ta
    
    if (x ~= theX || y ~= theY)
        
        if (GetSecs > nextTime)
            thePoints = [thePoints ; x y];
            nextTime = nextTime+sampleTime;
        end
        
        theX = x; theY = y;
    end
    img2B=imfilter(img2,psf,'replicate');
    [x,y,buttons] = GetMouse(0);
    td=GetSecs-ta
    
    if (x ~= theX || y ~= theY)
        
        if (GetSecs > nextTime)
            thePoints = [thePoints ; x y];
            nextTime = nextTime+sampleTime;
        end
        
        theX = x; theY = y;
    end
    patchtex = Screen('MakeTexture',video.h,imgB,[],[],1);
    [x,y,buttons] = GetMouse(0);
    td=GetSecs-ta
    
    if (x ~= theX || y ~= theY)
        
        if (GetSecs > nextTime)
            thePoints = [thePoints ; x y];
            nextTime = nextTime+sampleTime;
        end
        
        theX = x; theY = y;
    end
    patchrct = CenterRectOnPoint(Screen('Rect',patchtex),video.x/2-coord,video.y/2);
    [x,y,buttons] = GetMouse(0);
    td=GetSecs-ta
    
    if (x ~= theX || y ~= theY)
        
        if (GetSecs > nextTime)
            thePoints = [thePoints ; x y];
            nextTime = nextTime+sampleTime;
        end
        
        theX = x; theY = y;
    end
    Screen('DrawTexture',video.h,patchtex,[],patchrct);
    [x,y,buttons] = GetMouse(0);
    td=GetSecs-ta
    
    if (x ~= theX || y ~= theY)
        
        if (GetSecs > nextTime)
            thePoints = [thePoints ; x y];
            nextTime = nextTime+sampleTime;
        end
        
        theX = x; theY = y;
    end
    patchtex = Screen('MakeTexture',video.h,img2B,[],[],1);
    [x,y,buttons] = GetMouse(0);
    td=GetSecs-ta
    
    if (x ~= theX || y ~= theY)
        
        if (GetSecs > nextTime)
            thePoints = [thePoints ; x y];
            nextTime = nextTime+sampleTime;
        end
        
        theX = x; theY = y;
    end
    patchrct = CenterRectOnPoint(Screen('Rect',patchtex),video.x/2+coord,video.y/2);%376
    [x,y,buttons] = GetMouse(0);
    td=GetSecs-ta
    
    if (x ~= theX || y ~= theY)
        
        if (GetSecs > nextTime)
            thePoints = [thePoints ; x y];
            nextTime = nextTime+sampleTime;
        end
        
        theX = x; theY = y;
    end
    Screen('DrawTexture',video.h,patchtex,[],patchrct);
    [x,y,buttons] = GetMouse(0);
    td=GetSecs-ta
    
    if (x ~= theX || y ~= theY)
        
        if (GetSecs > nextTime)
            thePoints = [thePoints ; x y];
            nextTime = nextTime+sampleTime;
        end
        
        theX = x; theY = y;
    end
    patchtex = Screen('MakeTexture',video.h,cross,[],[],[]);
    [x,y,buttons] = GetMouse(0);
    td=GetSecs-ta
    
    if (x ~= theX || y ~= theY)
        
        if (GetSecs > nextTime)
            thePoints = [thePoints ; x y];
            nextTime = nextTime+sampleTime;
        end
        
        theX = x; theY = y;
    end
    patchrct = CenterRectOnPoint(Screen('Rect',patchtex),video.x/2,video.y/2-390);
    [x,y,buttons] = GetMouse(0);
    td=GetSecs-ta
    
    if (x ~= theX || y ~= theY)
        
        if (GetSecs > nextTime)
            thePoints = [thePoints ; x y];
            nextTime = nextTime+sampleTime;
        end
        
        theX = x; theY = y;
    end
    Screen('DrawTexture',video.h,patchtex,[],patchrct);
    [x,y,buttons] = GetMouse(0);
    td=GetSecs-ta
    
    if (x ~= theX || y ~= theY)
        
        if (GetSecs > nextTime)
            thePoints = [thePoints ; x y];
            nextTime = nextTime+sampleTime;
        end
        
        theX = x; theY = y;
    end
    Screen('FillRect', video.h, [0.1 0.1 0.1 0.6],  [940   810  990  870]);
    [x,y,buttons] = GetMouse(0);
    td=GetSecs-ta
    
    if (x ~= theX || y ~= theY)
        
        if (GetSecs > nextTime)
            thePoints = [thePoints ; x y];
            nextTime = nextTime+sampleTime;
        end
        
        theX = x; theY = y;
    end
    Screen('Flip',video.h);
    [x,y,buttons] = GetMouse(0);
    td=GetSecs-ta
    
    if (x ~= theX || y ~= theY)
        
        if (GetSecs > nextTime)
            thePoints = [thePoints ; x y];
            nextTime = nextTime+sampleTime;
        end
        
        theX = x; theY = y;
    end
    j=1;
    
    
end

end


