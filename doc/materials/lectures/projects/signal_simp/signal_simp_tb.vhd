entity SIGNAL_SIMP_TB is		-- pusty sprzeg projektu symulacji
end SIGNAL_SIMP_TB;

architecture behavioural of SIGNAL_SIMP_TB is -- cialo architektoniczne projektu

  signal A	:bit;			-- symulowane wejscie 'A'
  signal B	:bit;			-- symulowane wejscie 'B'
  signal Y	:bit;			-- obserwowane wyjscie 'Y'

begin					-- poczatek czesci wykonawczej architektury

  process is				-- proces bezwarunkowy
  begin					-- czesc wykonawcza procesu
    A <= '0';				-- przypisanie sygna這wi 'A' wartosci '0'
    wait for 10 ns;			-- odczekanie 10 ns
    A <= '1';				-- przypisanie sygna這wi 'A' wartosci '1'
    wait for 10 ns;			-- odczekanie 10 ns
  end process;				-- zakonczenie procesu  process is

  process is				-- proces bezwarunkowy
  begin					-- czesc wykonawcza procesu
    B <= '0';				-- przypisanie sygna這wi 'B' wartosci '0'
    wait for 20 ns;			-- odczekanie 20 ns
    B <= '1';				-- przypisanie sygna這wi 'B' wartosci '1'
    wait for 20 ns;			-- odczekanie 20 ns
  end process;				-- zakonczenie procesu

  signal_simp_inst: entity work.SIGNAL_SIMP(cialo) -- instancja projektu 'SIGNAL_SIMP'
    port map (				-- mapowanie portow
      argA     => A,			-- przypisanie sygnalu 'A' do portu 'argA'
      argB     => B,			-- przypisanie sygnalu 'B' do portu 'argB'
      rezultat => Y			-- przypisanie sygnalu 'Y' do portu 'rezultat'
    );

end behavioural;			-- zakonczenie ciala architektonicznego
