function update_input(input,loadcase)
sigma_f = input(1); C1_f = input(2);
gamma1_f = input(3); Qinf_f = input(4); b_f= input(5);

fileID = fopen('input.dat','w');

fprintf(fileID, '*Plastic, hardening=COMBINED, datatype=PARAMETERS, number backstresses=1\n');
fprintf(fileID,'%s, %s, %s\n',num2str(sigma_f),num2str(C1_f),num2str(gamma1_f));
fprintf(fileID, '*Cyclic Hardening, parameters\n');
fprintf(fileID,'%s, %s, %s\n',num2str(sigma_f),num2str(Qinf_f),num2str(b_f));
fclose(fileID);

fileID = fopen('ampli.dat','w');
if loadcase=='SS1'
    fprintf(fileID,'*Amplitude, name=Amp-1,input=SS1.dat');
elseif loadcase=='SS2'
    fprintf(fileID,'*Amplitude, name=Amp-1,input=SS2.dat');
else
    fprintf(fileID,'*Amplitude, name=Amp-1,input=SS3.dat');
end
fclose(fileID);

fileID = fopen('loadstep.dat','w');
if loadcase=='SS1'
    fprintf(fileID,'0.01,22.72,1e-15,0.01');
elseif loadcase=='SS2'
    fprintf(fileID,'0.01,18.2,1e-15,0.01');
else
    fprintf(fileID,'0.01,6.2,1e-15,0.01');
end
fclose(fileID);

end