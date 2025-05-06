function ret = TTTH_v2_2_1_excel_cell_pos_format(pos, option)
    % option: 1: convert number format to character format. ex) [2, 3] -> 'C2'
    % option: 2: opposite way. ex) 'C2' -> [2, 3]
    if option==1
        ret= [num2xlcol(pos(2)) num2str(pos(1))];
    elseif option==2
        num_tf = [];
        for i=1:length(pos)
            num_tf(end+1) = str2double(pos(i));
        end
        idx = find(~isnan(num_tf));
        col_str = pos(1:idx(1)-1);
        col = xlcol2num(col_str);
        row = str2num(pos(idx(1):end));
        ret=[row col];
    end
        
end

function xlcol_addr=num2xlcol(col_num)
% col_num - positive integer greater than zero
    n=1;
    while col_num>26*(26^n-1)/25
        n=n+1;
    end
    base_26=zeros(1,n);
    tmp_var=-1+col_num-26*(26^(n-1)-1)/25;
    for k=1:n
        divisor=26^(n-k);
        remainder=mod(tmp_var,divisor);
        base_26(k)=65+(tmp_var-remainder)/divisor;
        tmp_var=remainder;
    end
    xlcol_addr=char(base_26); % Character vector of xlcol address
end
function xlcol_num=xlcol2num(xlcol_addr)
% xlcol_addr - upper case character
    if ischar(xlcol_addr) && ~any(~isstrprop(xlcol_addr,"upper"))
        xlcol_num=0;
        n=length(xlcol_addr);
        for k=1:n
            xlcol_num=xlcol_num+(double(xlcol_addr(k)-64))*26^(n-k);
        end
    else
        error('not a valid character')
    end
end
