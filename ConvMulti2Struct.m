function StructData = ConvMulti2Struct(MultiData,StructData,comp,fieldname)
% 4th level function to put components from a structured array into a
% multidimensional array

ncomptot = length(comp);
    
for ncomp = 1:ncomptot
    StructData.(fieldname).(comp{ncomp}) = MultiData(:,:,ncomp);
end

end