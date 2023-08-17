clc
clear
script_dir = pwd;
photo_dir = uigetdir('.', 'Pick Photo Directory');
cd(photo_dir);
AllObject=dir();
AllFile=AllObject([AllObject.isdir]==0);
for iFile=1:length(AllFile)
    [filepath,input_name,ext] = fileparts(AllFile(iFile).name);
    if strcmpi(ext,'.jpg')
        info = imfinfo(AllFile(iFile).name);
        if isfield(info,'DigitalCamera') && isfield(info.DigitalCamera,'DateTimeDigitized')
            info.DateTime=info.DigitalCamera.DateTimeDigitized;
            %         if isfield(info,'DateTime')
            photo_datetime = datetime(info.DateTime(1:19),'InputFormat','yyyy:MM:dd HH:mm:ss');
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
                    if exist(fullfile(photo_dir,strcat(input_name ,'.ARW')),'file')
                        status=movefile(fullfile(photo_dir,strcat(input_name,'.ARW')),fullfile(photo_dir,strcat(output_name,'.ARW')));
                        if ~status
                            warning('%s can not be renamed',strcat(input_name,'.ARW'));
                        end
                    end
                    % Lumix
                    if exist(fullfile(photo_dir,strcat(input_name ,'.RW2')),'file')
                        status=movefile(fullfile(photo_dir,strcat(input_name,'.RW2')),fullfile(photo_dir,strcat(output_name,'.RW2')));
                        if ~status
                            warning('%s can not be renamed',strcat(input_name,'.RW2'));
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
                            if exist(fullfile(photo_dir,strcat(input_name ,'.ARW')),'file')
                                status=movefile(fullfile(photo_dir,strcat(input_name,'.ARW')),fullfile(photo_dir,[output_name '_' num2str(index) '.ARW']));
                                if ~status
                                    warning('%s can not be renamed',strcat(input_name,'.ARW'));
                                end
                            end
                            % Lumix
                            if exist(fullfile(photo_dir,strcat(input_name ,'.RW2')),'file')
                                status=movefile(fullfile(photo_dir,strcat(input_name,'.RW2')),fullfile(photo_dir,[output_name '_' num2str(index) '.RW2']));
                                if ~status
                                    warning('%s can not be renamed',strcat(input_name,'.RW2'));
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
        video_datetime_str=GetVideoDateTime(strcat(input_name,ext));
        if ~isempty(video_datetime_str)
            output_name=strcat('VID_', video_datetime_str);
            if strncmp(input_name,output_name,19-2) %if already renamed VID_yyyyMMdd_HHmm, pass
                warning('%s already renamed',strcat(input_name,ext));
                continue;
            else
                if ~exist(fullfile(photo_dir,strcat(output_name ,ext)),'file')
                    status=movefile(fullfile(photo_dir,strcat(input_name,ext)),fullfile(photo_dir,strcat(output_name ,ext)));
                    if ~status
                        warning('%s can not be renamed',strcat(input_name,ext));
                    end
                end
            end
        else
            warning('%s has no DateTime information',strcat(input_name,ext));
        end
    else
        continue;
    end
end
cd(script_dir);

function video_datetime_str=GetVideoDateTime(video_path)
video_datetime_str=[];
[s,msg] = system(sprintf('ffprobe.exe -show_format %s -print_format json',video_path));
if s~=0
    error('ffmpeginfo failed to run FFmpeg\n\n%s',msg);
end

I = regexp(msg,'Input #','start');
if isempty(I)
    warning('Specified file is not FFmpeg supported media file.');
end
left_brace=find(msg=='{');
right_brace=find(msg=='}');

json_content=msg(left_brace(1):right_brace(end));

info=jsondecode(json_content);

if isfield(info.format.tags,'creation_time')
    raw_DateTime=info.format.tags.creation_time; %'2022-06-09T01:42:56.000000Z'
    video_datetime = datetime(raw_DateTime(1:19),'TimeZone','UTC','InputFormat','yyyy-MM-dd''T''HH:mm:ss');
    video_datetime.TimeZone='Asia/Hong_Kong';
    duration=str2double(info.format.duration);
    video_datetime=video_datetime-seconds(duration);
    video_datetime_str=char(string(video_datetime,'yyyyMMdd_HHmmss')); % char() change string 2 char to use [str1 str2]
end
end



