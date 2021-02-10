function send_to_port(data_out)
% -----------------------------------------------------------------------
% Format:
% data_in=io64(ioObj,address); % now, let's read that value back into MATLAB
% io64(ioObj,address,0);   %output command
%
% -----------------------------------------------------------------------
data_out = 2;

% addpath D:\IOIO\Matlab_Port
% cd D:\IOIO\Matlab_Port

%create an instance of the io64 object
ioObj = io64;

%initialize the interface to the inpoutx64 system driver
status = io64(ioObj);
%if status = 0, you are now ready to write and read to a hardware port
%let's try sending the value=1 to the parallel printer's output port (LPT1)

address = hex2dec('378');          %standard LPT1 output port address

io64(ioObj,address,data_out);   %output command
data_in=io64(ioObj,address);
io64(ioObj,address,0);


if data_in ~= data_out
    disp('Input trigger does not correspond to outpu trigger!')
end

