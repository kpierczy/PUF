entity PROCESS_VAR_TB is		-- pusty sprzeg projektu symulacji
end PROCESS_VAR_TB;

architecture behavioural of PROCESS_VAR_TB is -- cialo architektoniczne projektu

  signal A	:natural range 0 to 7;	-- symulowane wejscie A
  signal Y1	:natural range 0 to 7;	-- obserwowane wyjscie Y1
  signal Y2	:natural range 0 to 7;	-- obserwowane wyjscie Y1

begin					-- poczatek czesci wykonawczej architektury

  process is				-- proces bezwarunkowy
  begin					-- czesc wykonawcza procesu
    wait for 10 ns; A <= (A+6) mod 8; 	-- odczekanie 10 ns i zwiekszenie A o 1 modulo 8
  end process;				-- zakonczenie procesu

  process_var_inst: entity work.PROCESS_VAR(cialo) -- instancja projektu 'PROCESS_VAR2'
    port map (				-- mapowanie portow
      A  => A,				-- przypisanie sygnalu 'A' do portu 'A'
      Y1 => Y1,				-- przypisanie sygnalu 'Y1' do portu 'Y1'
      Y2 => Y2				-- przypisanie sygnalu 'Y2' do portu 'Y2'
    );

end behavioural;			-- zakonczenie ciala architektonicznego	
