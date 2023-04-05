clc
clear

cfg_RenameVideoByModifiedDate=false;
cfg_RenameNoExifPhotoByModifiedDate=false;

photo_dir = uigetdir('.', 'Pick Photo Directory');
% photo_dir ='D:\3 所有照片\MATLAB_ImageVideoRename';
cd(photo_dir);
AllObject=dir();
AllFile=AllObject([AllObject.isdir]==0);
for iFile=1:length(AllFile)
    [filepath,input_name,ext] = fileparts(AllFile(iFile).name);
    if strcmpi(ext,'.jpg')
        info = imfinfo(AllFile(iFile).name);
        if isfield(info,'DateTime')
            photo_datetime = datetime(info.DateTime,'InputFormat','yyyy:MM:dd HH:mm:ss');
            photo_datetime_str=char(string(photo_datetime,'yyyyMMdd_HHmmss')); % char() change string 2 char to use [str1 str2]
            output_name=strcat('IMG_', photo_datetime_str);
            if strncmp(input_name,output_name,19) %if already renamed IMG_yyyyMMdd_HHmmss_i.jpg, pass
                warning('%s already renamed',strcat(input_name,ext));
                continue;
            else
                if ~exist(fullfile(photo_dir,strcat(output_name ,ext)),'file')
                    status=movefile(fullfile(photo_dir,strcat(input_name,ext)),fullfile(photo_dir,strcat(output_name ,ext)));
                    if ~status
                        warning('%s can not be renamed',strcat(input_name,ext));
                    end
                    % SONY
                    if exist(fullfile(photo_dir,strcat(output_name ,'.ARW')),'file')
                        status=movefile(fullfile(photo_dir,strcat(input_name,'.ARW')),fullfile(photo_dir,strcat(output_name,'.ARW')));
                        if ~status
                            warning('%s can not be renamed',strcat(input_name,'.ARW'));
                        end
                    end
                else
                    % default file exist
                    index=1;
                    while true
                        if ~exist(fullfile(photo_dir,[output_name '_' num2str(index) ext]),'file')
                            status=movefile(fullfile(photo_dir,strcat(input_name,ext)),fullfile(photo_dir,[output_name '_' num2str(index) ext]));
                            if ~status
                                warning('%s can not be renamed',strcat(input_name,ext));
                            end
                            % SONY
                            if exist(fullfile(photo_dir,[output_name '_' num2str(index) '.ARW']),'file')
                                status=movefile(fullfile(photo_dir,strcat(input_name,'.ARW')),fullfile(photo_dir,[output_name '_' num2str(index) '.ARW']));
                                if ~status
                                    warning('%s can not be renamed',strcat(input_name,'.ARW'));
                                end
                            end
                            break;
                        else
                            index=index+1;
                        end
                    end
                end
            end
        else
            warning('%s has no exif information',strcat(input_name,ext));
        end
    elseif strcmpi(ext,'.mp4')

    else
        continue;
    end
end
cd('D:\3 所有照片\MATLAB_ImageVideoRename');



