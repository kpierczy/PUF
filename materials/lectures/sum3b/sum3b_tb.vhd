entity SUM3B_TB is			-- pusty sprzeg projektu symulacji
end SUM3B_TB;

architecture behavioural of SUM3B_TB is	-- cialo architektoniczne projektu

  signal A	:bit;			-- symulowane wejscie A
  signal B	:bit;			-- symulowane wejscie B
  signal C	:bit;			-- symulowane wejscie D
  signal S	:bit;			-- obserwowane wyjscie S
  signal P	:bit;			-- obserwowane wyjscie P

begin

  process is				-- proces bezwarunkowy
  begin					-- czesc wykonawcza procesu
    A <= '0';				-- przypisanie sygna這wi 'A' wartosci '0'
    wait for 10 ns;			-- odczekanie 10 ns
    A <= '1';				-- przypisanie sygna這wi 'A' wartosci '1'
    wait for 10 ns;			-- odczekanie 10 ns
  end process;				-- zakonczenie procesu

  process is				-- proces bezwarunkowy
  begin					-- czesc wykonawcza procesu
    B <= '0';				-- przypisanie sygna這wi 'B' wartosci '0'
    wait for 20 ns;			-- odczekanie 20 ns
    B <= '1';				-- przypisanie sygna這wi 'B' wartosci '1'
    wait for 20 ns;			-- odczekanie 20 ns
  end process;				-- zakonczenie procesu

  process is				-- proces bezwarunkowy
  begin					-- czesc wykonawcza procesu
    C <= '0';				-- przypisanie sygna這wi 'C' wartosci '0'
    wait for 40 ns;			-- odczekanie 40 ns
    C <= '1';				-- przypisanie sygna這wi 'C' wartosci '1'
    wait for 40 ns;			-- odczekanie 40 ns
  end process;				-- zakonczenie procesu

  SUM3B_inst: entity work.SUM3B(cialo) -- instancja projektu 'SUM3B'
    port map (				-- mapowanie portow
      A => A,				-- przypisanie sygnalu 'A do portu 'A'
      B => B,				-- przypisanie sygnalu 'B do portu 'B'
      C => C,				-- przypisanie sygnalu 'D do portu 'C'
      S => S,				-- przypisanie sygnalu 'S do portu 'S'
      P => P				-- przypisanie sygnalu 'P do portu 'P'
    );
end behavioural;			-- zakonczenie ciala architektonicznego