function get_cogent_key_codes

config_display( 0, 1, [0 0 0], [1 1 1], 'Helvetica', 50, 4, 0);
config_keyboard (5,1,'nonexclusive'); % Set up key board
start_cogent


 disp('Press a key to see key code name in command window.')
    disp('Press escape to end.')

another_key = 1;

while another_key
   
    
    loop = 1;
    while loop
        readkeys;
        [k,t] = waitkeydown(inf);
        
        if ~isempty(k)
            loop = 0;
        end
    end
    fprintf('\n------------------------------------------------\n')
    fprintf(' You pressed key with cogent key code: %d \n', k)
    fprintf('------------------------------------------------\n')
    
    
    if k(1) == 52
        another_key = 0;
    else
    fprintf('------------------------------------------------\n')
    fprintf(['Press the next key to see key code name \n',...
        'in command window. Press escape to end.\n'])
    fprintf('------------------------------------------------\n')
    end
end


stop_cogent
close all
clear all


