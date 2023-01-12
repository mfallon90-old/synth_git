function bin2text(numbers, file_name)

filename = strcat('../hdl/', file_name);
fid = fopen(filename,'w');

    for i = 1:numel(numbers)
        fprintf(fid,'%s\r\n',bin(numbers(i)));
    end
    
    fclose(fid); 
end