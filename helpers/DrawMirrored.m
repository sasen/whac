function [] = DrawMirrored(window,onehalf,otherhalf,ScrRes)
% function [] = DrawMirrored(window,onehalf,otherhalf,ScrRes)
% Tile two half-screens mirrored by 180-degrees.
%    window: destination (double-wide) window
%    onehalf: first texture to draw (on a pointer to offscreen window)
%    otherhalf: second texture to draw (on a pointer to offscreen window)
%    ScrRes: the screen resolution
% Note: same thing in onehalf & otherhalf => mirrors the same half-screen to both sides

Screen('DrawTexture',window,onehalf,[], [0 0 ScrRes(1)/2 ScrRes(2)], 0);
Screen('DrawTexture',window,otherhalf,[], [ScrRes(1)/2 0 ScrRes(1) ScrRes(2)], 180);
