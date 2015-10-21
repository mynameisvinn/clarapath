function [idx] = generate_patch(data_idx, multiplier)
% @date: 10/19/15
% @author: vincent tang

% function: generate patches for user id 8 and counter 1

% parameters: 
% @data_idx: datafile ID
% @multiplier: should be 2.5x... used to increase channel intensity

    % retreive image
    conn = database('limsdb','lims','mou53Brains!');
    curs = exec(conn,[]);
    sql = ['SELECT primary_file_system_location_lossy FROM data_file WHERE id = "' num2str(data_idx) '"'];
    curs = exec(conn,sql);
    curs = fetch(curs);
    imagefilename = curs.Data;
    path = strcat('Z:\Converted Image Data\', imagefilename);
    im_raw = imread(char(path));
    % im_8bit = uint8(im_raw);
    im_8bit = im_raw * 2^ 6;

    % grab coordinates
    sql = ['SELECT click_location_x_coordinate, click_location_y_coordinate FROM limsdb.data_file_click where (user_id = 9) and (counter_id = 1) and data_file_id = "' num2str(data_idx) '"'];
    curs = exec(conn,sql);
    curs = fetch(curs);
    predictions = cell2mat(curs.Data);
    
    % generate vacht patches from coordinates
    for idx = 1:length(predictions(:,1))

        a = predictions(idx,1);
        b = predictions(idx,2);
        patch_size = 200;

        
        patch = im_8bit( b-patch_size: b +patch_size, a - patch_size: a + patch_size,:);
        patch(:,:,1) = 0;
        patch(:,:,2) = patch(:,:,2) * multiplier;
        patch(:,:,3) = 0;
            
        
        % save patches in the appropriate raw specimen folder, if it exists
        try
            filename = strcat(int2str(data_idx), '/', int2str(data_idx), '_', int2str(a), '_', int2str(b),'.tif');
            imwrite(patch, filename, 'tif');
            
        % otherwise create new folder
        catch
            mkdir(int2str(data_idx));
            filename = strcat(int2str(data_idx), '/', int2str(data_idx), '_', int2str(a), '_', int2str(b),'.tif');
            imwrite(patch, filename, 'tif');
        
    end

end

