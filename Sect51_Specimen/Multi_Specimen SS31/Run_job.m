S = mfilename('fullpath');
f = filesep;
ind=strfind(S,f);
S1=S(1:ind(end)-1);
cd(S1)
%above sets the path
%delete('Speci.dat');
delete('Speci.odb');
delete('Speci.lck');
delete('Speci.prt');
delete('Speci.com');
delete('Speci.sim');
delete('Speci.dat');
delete('Speci.log');

pause(2) % can this pause stop the job from getting stuck?
system('abaqus job=Speci interactive' )
%system('abaqus job=beam cpus=3 interactive' )

pause(2)
while exist('Speci.lck','file')==2
    pause(0.1)
end

while exist('Speci.odb','file')==0
    pause(0.1)
end
