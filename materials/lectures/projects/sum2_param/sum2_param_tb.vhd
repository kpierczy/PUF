entity SUM2_PARAM_TB is				-- sprzeg projektu symulacji
  generic (N : integer := 8);			-- deklaracja parametru 'N'
end SUM2_PARAM_TB;

architecture behavioural of SUM2_PARAM_TB is	-- cialo architektoniczne projektu

  signal A	:bit_vector(N-1 downto 0) := (others => '0'); -- symulowane wejscie A
  signal B	:bit_vector(N-1 downto 0) := (others => '0'); -- symulowane wejscie B
  signal S	:bit_vector(N-1 downto 0);	-- obserwowane wyjscie S
  signal P	:bit;				-- obserwowane wyjscie P

begin

  al: for i in 1 to N-1 generate		-- N-krotna petla powielania
    process is					-- proces bezwarunkowy
    begin					-- czesc wykonawcza procesu
      wait for (i+1)*10 ns;			-- odczekanie 'i+1'-krotne 10 ns
      A(i) <= not(A(i));			-- przypisanie sygna³owi 'A' wartosci
    end process;				-- zakonczenie procesu
  end generate;

  bl: for i in 0 to N-1 generate		-- N-krotna petla powielania
    process is					-- proces bezwarunkowy
    begin					-- czesc wykonawcza procesu
      wait for N*(i+1)*10 ns;			-- odczekanie 'N*(i+1)'-krotne 10 ns
      B(i) <= not(B(i));			-- przypisanie sygna³owi 'A' wartosci
    end process;				-- zakonczenie procesu
  end generate;

  SUM2_PARAM_inst: entity work.SUM2_PARAM(cialo) -- instancja projektu 'SUM2_PARAM'
    generic map (N => N)			-- mapowanie parametru
    port map (					-- mapowanie portow
      A => A,					-- przypisanie sygnalu 'A do portu 'A'
      B => B,					-- przypisanie sygnalu 'B do portu 'B'
      S => S,					-- przypisanie sygnalu 'S do portu 'S'
      P => P					-- przypisanie sygnalu 'P do portu 'P'
    );	
end behavioural;				-- zakonczenie ciala architektonicznego