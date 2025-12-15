function Trans = ConvXYZ2Beam(Raw,transMatrix,state)
% general transformation algorithm can be used with any raw data in columns
% with corresponding transformation matrix.
% state = 1 for xyz to beam; 2 for beam to xyz
% adapted from TransMAT2 (from Jay Lacey) Jan 31, 2013

% if transforming into beam
if state == 1 
    Trans = Raw/transMatrix;
% else transforming into xyz
elseif state == 2
    Trans = Raw*transMatrix;
end

end