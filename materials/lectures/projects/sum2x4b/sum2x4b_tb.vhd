entity SUM2X4B_TB is			-- pusty sprzeg projektu symulacji
end SUM2X4B_TB;

architecture behavioural of SUM2X4B_TB is	-- cialo architektoniczne projektu

  signal A	:bit_vector(3 downto 0);	-- symulowane wejscie A
  signal B	:bit_vector(3 downto 0);	-- symulowane wejscie B
  signal S	:bit_vector(3 downto 0);	-- obserwowane wyjscie S
  signal P	:bit;				-- obserwowane wyjscie P

begin

  process is					-- proces bezwarunkowy
  begin						-- czesc wykonawcza procesu
    A <= "0000";				-- przypisanie sygna這wi 'A' wartosci
    wait for 10 ns;				-- odczekanie 10 ns
    A <= "0011";				-- przypisanie sygna這wi 'A' wartosci
    wait for 10 ns;				-- odczekanie 10 ns
    A <= "1010";				-- przypisanie sygna這wi 'A' wartosci
    wait for 10 ns;				-- odczekanie 10 ns
    A <= "1110";				-- przypisanie sygna這wi 'A' wartosci
    wait for 10 ns;				-- odczekanie 10 ns
  end process;					-- zakonczenie procesu

  process is					-- proces bezwarunkowy
  begin						-- czesc wykonawcza procesu
    B <= "0000";				-- przypisanie sygna這wi 'B' wartosci
    wait for 20 ns;				-- odczekanie 10 ns
    B <= "0110";				-- przypisanie sygna這wi 'B' wartosci
    wait for 20 ns;				-- odczekanie 10 ns
    B <= "1100";				-- przypisanie sygna這wi 'B' wartosci
    wait for 20 ns;				-- odczekanie 10 ns
    B <= "1111";				-- przypisanie sygna這wi 'B' wartosci
    wait for 20 ns;				-- odczekanie 10 ns
  end process;					-- zakonczenie procesu

  SUM2X4B_inst: entity work.SUM2X4B(cialo)	-- instancja projektu 'SUM2X4B'
    port map (					-- mapowanie portow
      A => A,					-- przypisanie sygnalu 'A do portu 'A'
      B => B,					-- przypisanie sygnalu 'B do portu 'B'
      S => S,					-- przypisanie sygnalu 'S do portu 'S'
      P => P					-- przypisanie sygnalu 'P do portu 'P'
    );	
end behavioural;				-- zakonczenie ciala architektonicznego