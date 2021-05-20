entity PROCEDURE_OPTREG_TB is		-- pusty sprzeg projektu symulacji
end PROCEDURE_OPTREG_TB;

architecture behavioural of PROCEDURE_OPTREG_TB is -- cialo architektoniczne projektu
 
  signal R	: bit;			-- symulowane wejscie kasuj¹ce 'R'
  signal C	: bit; 			-- symulowane wejscie taktujace 'C'
  signal E	: bit; 			-- symulowane wejscie zezwalajace 'E'
  signal A	: bit_vector(3 downto 0); -- symulowane wejscie 'A'
  signal Y1, Y2 : natural range 0 to 2;	-- obserwowane wyjscia 'Y1' i 'Y2'

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
    A <= "0000"; wait for 10 ns;	-- ustawienie sygnalu 'A'=0 i odczekanie 10 ns
    A <= "0001"; wait for 10 ns;	-- ustawienie sygnalu 'A'=1 i odczekanie 10 ns
    A <= "0010"; wait for 10 ns;	-- ustawienie sygnalu 'A'=2 i odczekanie 10 ns
    A <= "0011"; wait for 10 ns;	-- ustawienie sygnalu 'A'=3 i odczekanie 10 ns
    A <= "0100"; wait for 10 ns;	-- ustawienie sygnalu 'A'=4 i odczekanie 10 ns
    A <= "0101"; wait for 10 ns;	-- ustawienie sygnalu 'A'=5 i odczekanie 10 ns
    A <= "0110"; wait for 10 ns;	-- ustawienie sygnalu 'A'=6 i odczekanie 10 ns
    A <= "0111"; wait for 10 ns;	-- ustawienie sygnalu 'A'=7 i odczekanie 10 ns
    A <= "1000"; wait for 10 ns;	-- ustawienie sygnalu 'A'=8 i odczekanie 10 ns
    A <= "1001"; wait for 10 ns;	-- ustawienie sygnalu 'A'=9 i odczekanie 10 ns
    A <= "1010"; wait for 10 ns;	-- ustawienie sygnalu 'A'=10 i odczekanie 10 ns
    A <= "1011"; wait for 10 ns;	-- ustawienie sygnalu 'A'=11 i odczekanie 10 ns
    A <= "1100"; wait for 10 ns;	-- ustawienie sygnalu 'A'=12 i odczekanie 10 ns
    A <= "1101"; wait for 10 ns;	-- ustawienie sygnalu 'A'=13 i odczekanie 10 ns
    A <= "1110"; wait for 10 ns;	-- ustawienie sygnalu 'A'=14 i odczekanie 10 ns
    A <= "1111"; wait for 10 ns;	-- ustawienie sygnalu 'A'=15 i odczekanie 10 ns
  end process;				-- zakonczenie procesu

  procedure_optreg_inst: entity work.PROCEDURE_OPTREG2_IMPL(cialo) -- instancja projektu 'PROCEDURE_OPTREG2_IMPL'
    port map (R, R, C, C, E, E, A, A, Y1, Y2);	-- mapowanie portow

end behavioural;			-- zakonczenie ciala architektonicznego
