function cell_ret = TTTH_v1_1_0_convert_struct_to_cell(st_in)
    cell_ret = {};
    for i=1:length(st_in)
        fns = fieldnames(st_in);
        for j=1:length(fns)
            cell_ret{i,j} = st_in(i).(fns{j});
        end
    end
end