

function [h]=DrawScale_Free(videot,crossX,RatingW,crossY,colText,text)

            text = strcat('Est-ce que vous referiez le même choix ?');
            [w, h] = RectSize(Screen('TextBounds', videot, text));
            Screen('DrawText', videot, text, crossX-w/2, crossY-h*3);
            text = 'pas du tout';
            [w, h] = RectSize(Screen('TextBounds', videot, text));
            Screen('DrawText', videot, text, crossX-round(RatingW/2)-w/2, crossY+0.5*h);
            text = 'tout à fait';
            [w, h] = RectSize(Screen('TextBounds', videot, text));
            Screen('DrawText', videot, text, crossX+round(RatingW/2)-w/2, crossY+0.5*h);
            Screen('DrawLine', videot, colText, crossX - round(RatingW/2), crossY,...
                crossX + round(RatingW/2), crossY, 10);

end