entity PROCESS_DFFE_TB is		-- pusty sprzeg projektu symulacji
end PROCESS_DFFE_TB;

architecture behavioural of PROCESS_DFFE_TB is -- cialo architektoniczne projektu
 
  signal R : bit;			-- symulowane wejscie kasuj¹ce 'R'
  signal C : bit; 			-- symulowane wejscie taktujace 'C'
  signal E : bit; 			-- symulowane wejscie zezwalajace 'E'
  signal D : bit;			-- symulowane wejscie danej 'D'
  signal Q : bit;	 		-- obserwowane wyjscie danej 'Q

begin					-- poczatek czesci wykonawczej architektury

  process is				-- proces bezwarunkowy
  begin					-- czesc wykonawcza procesu
    R <= '1'; wait for 20 ns;		-- przypisanie R='1' i odczekanie 20 ns
    R <= '0'; wait for 200 ns;		-- przypisanie R='0' i odczekanie 200 ns
  end process;				-- zakonczenie procesu

  process is				-- proces bezwarunkowy
  begin					-- czesc wykonawcza procesu
    C <= '0'; wait for 5 ns;		-- przypisanie C='0' i odczekanie 5 ns
    C <= '1'; wait for 5 ns;		-- przypisanie C='1' i odczekanie 5 ns
  end process;				-- zakonczenie procesu

  process is				-- proces bezwarunkowy
  begin					-- czesc wykonawcza procesu
    E <= '0'; wait for 10 ns;		-- przypisanie E='0' i odczekanie 10 ns
    E <= '1'; wait for 20 ns;		-- przypisanie E='1' i odczekanie 10 ns
  end process;				-- zakonczenie procesu

  process is				-- proces bezwarunkowy
  begin					-- czesc wykonawcza procesu
    D <= not(D); wait for 3 ns;		-- przypisanie negacji wartoœci D i odczekanie 3 ns
    D <= not(D); wait for 3 ns;		-- przypisanie negacji wartoœci D i odczekanie 3 ns
    D <= not(D); wait for 4 ns;		-- przypisanie negacji wartoœci D i odczekanie 4 ns
  end process;				-- zakonczenie procesu

  process_dffe_inst: entity work.PROCESS_DFFE(cialo) -- instancja projektu 'PROCESS_DFFE'
    port map (				-- mapowanie portow
      R => R,				-- przypisanie sygnalu 'R' do portu 'R'
      C => C,				-- przypisanie sygnalu 'C' do portu 'C'
      E => E,				-- przypisanie sygnalu 'E' do portu 'E'
      D => D,				-- przypisanie sygnalu 'D' do portu 'D'
      Q => Q				-- przypisanie sygnalu 'Q' do portu 'Q'
    );

end behavioural;			-- zakonczenie ciala architektonicznego
