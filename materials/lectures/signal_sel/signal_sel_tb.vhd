entity SIGNAL_SEL_TB is			-- pusty sprzeg projektu symulacji
end SIGNAL_SEL_TB;

architecture behavioural of SIGNAL_SEL_TB is -- cialo architektoniczne projektu

  signal S	:natural range 0 to 3;   -- symulowane wejscie A
  signal A	:bit_vector(3 downto 0); -- symulowane wejscie A
  signal B	:bit_vector(3 downto 0); -- symulowane wejscie B
  signal Y	:bit_vector(3 downto 0); -- obserwowane wyjscie

begin					-- poczatek czesci wykonawczej architektury

  process is				-- proces bezwarunkowy
  begin					-- czesc wykonawcza procesu
    A <=  "1100" ; B <= "1010";		-- przypisanie wartosci do sygnalow 'A' i 'B'
    S <= 0; wait for 10 ns;		-- przypisanie sygnalu S=0 i odczekanie 10 ns
    S <= 1; wait for 10 ns;		-- przypisanie sygnalu S=1 i odczekanie 10 ns
    S <= 2; wait for 10 ns;		-- przypisanie sygnalu S=2 i odczekanie 10 ns
    S <= 3; wait for 10 ns;		-- przypisanie sygnalu S=3 i odczekanie 10 ns
  end process;

  signal_sel_inst: entity work.SIGNAL_SEL(cialo) -- instancja projektu 'SIGNAL_SEL'
    port map (				-- mapowanie portow
      sel      => S,			-- przypisanie sygnalu 'S' do portu 'sel'
      argA     => A,			-- przypisanie sygnalu 'A' do portu 'argA'
      argB     => B,			-- przypisanie sygnalu 'B' do portu 'argB'
      rezultat => Y			-- przypisanie sygnalu 'Y' do portu 'rezultat'
    );

end behavioural;			-- zakonczenie ciala architektonicznego
