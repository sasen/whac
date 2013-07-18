function [] = DrawMirrored(window,onehalf,otherhalf,ScrRes,swap)
% function [] = DrawMirrored(window,onehalf,otherhalf,ScrRes)
% Tile two half-screens mirrored by 180-degrees.
%    window: destination (double-wide) window
%    onehalf: lefthand texture to draw (on a pointer to offscreen window)
%    otherhalf: flipped righthand texture to draw (on a pointer to offscreen window)
%    ScrRes: the screen resolution
%    swap: (bool default=0) 1 means draw flipped otherhalf on L, onehalf on R.
% Note: same thing in onehalf & otherhalf => mirrors the same half-screen to both sides
% Note: swap=1 avoids hand-collisions

if (nargin == 4)  % set default for swap
    swap = 0;
end

if (~swap)
    Screen('DrawTexture',window,onehalf,[], [0 0 ScrRes(1)/2 ScrRes(2)], 0);
    Screen('DrawTexture',window,otherhalf,[], [ScrRes(1)/2 0 ScrRes(1) ScrRes(2)], 180);
else
    % no hand collisions
    Screen('DrawTexture',window,onehalf,[],[ScrRes(1)/2 0 ScrRes(1) ScrRes(2)], 0);
    Screen('DrawTexture',window,otherhalf,[],[0 0 ScrRes(1)/2 ScrRes(2)], 180);
end