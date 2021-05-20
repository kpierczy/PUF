pkg load instrument-control;

H=serial_interf.open("com5",9600,"N");
if ~isa(H,"octave_serial")
    disp("blad otwarcia interfejsu szeregowego");
else
    if ~serial_interf.sync(H,true,10)
      disp("blad synchronizacji interfejsu szeregowego");
    else
        R = "";
        data = '1234abcefgh';
        for i=1:length(data)
            serial_interf.send(H,data(i));
            R = [R char(serial_interf.receive(H, 1))];
        end
        disp(["wyslano:  " data])
        disp(["odebrano: " R]);
    end
    serial_interf.close(H);
end
