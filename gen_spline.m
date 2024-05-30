function x = gen_spline(ts, p)
% function x = gen_spline(p)
%
% This function generates a trajectory composed of 4 cubic splines
% Four cubic splines enables the creation of 2 submovements
% p is a vector of 17 parameters that can be changed
% The first four coeffients (1-4) are the time each spline takes
% The second four coefficients (5-8) are the initial slopes of each spline
% The third four coefficients (9-12) are the ending slopes for each spline
% The final five coefficients (13-17) are the positions at each time, starting with t0 (hence 5)
% Note that the spline positions are continuous, but slopes can be discontinuous [e.g., p(6) doesn't have to equal p(9)]

%ts = .001;                                                                   % Sampling rate - should be consistent throughout code
x1 = spline([0 p(1)],[p(3) p(7) p(8) p(5)],0:ts:p(1));                    % [time boundary conditions], [initial slope initial_pos final_pos final_slope], [time points you should calculate at]
x2 = spline([0 p(2)],[p(4) p(8) p(9) p(6)],0:ts:p(2));
% x3 = spline([0 p(3)],[p(7) p(15) p(16) p(11)],0:ts:p(3));
% x4 = spline([0 p(4)],[p(8) p(16) p(17) p(12)],0:ts:p(4));

%AGA- the spline function works by interpolating the curve between the
%known points, in this case where there are 2 more elements in the 2nd
%argument as compared to the first one, the first and the last element as
%taken as the slopes of the points at the initial and the final points of
%the spline respectively. The third argument of he function specifies the
%mesh size for the interpolation- so a smaller value makes the curve
%smoother.

x = [x1 x2(2:end)]; % First point of x2 is same as last point of x1, so when I concatenate, I leave off the first point of x2...   
%Note that the size of each x vector is final time/ts. So the size does not
%have to be equal of each of the xi variables that make up the x vector. 