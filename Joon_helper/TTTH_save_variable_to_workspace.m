function TTTH_save_variable_to_workspace(variable)

% Move variable from function workspace to base MATLAB workspace so
% user will have access to it after the program ends.

variable_name = inputname(1);
assignin('base', variable_name, variable);
end