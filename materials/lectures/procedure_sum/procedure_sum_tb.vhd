entity PROCEDURE_SUM_TB is					-- pusty sprzeg projektu symulacji
end PROCEDURE_SUM_TB;

architecture behavioural of PROCEDURE_SUM_TB is		-- cialo architektoniczne projektu

  signal A1		:bit_vector(3 downto 0);	-- symulowane wejscie A1
  signal A2		:bit_vector(3 downto 0);	-- symulowane wejscie A1
  signal YA1, YA2, YA3	:bit_vector(3 downto 0);	-- obserwowane wyjscia YA1..3
  signal YB1, YB2, YB3	:bit_vector(2 downto 0);	-- obserwowane wyjscia YB1..3
  signal CA1, CA2, CA3	:bit;				-- obserwowane wyjscia YA1..3
  signal CB1, CB2, CB3	:bit;				-- obserwowane wyjscia YB1..3

begin							-- czesc wykonawcza ciala projektu

  process is						-- proces bezwarunkowy
  begin							-- czesc wykonawcza procesu
    A1 <= "0000"; A2 <= "0000"; wait for 10ns;		-- ustawienie sygnalow 'A1', 'A2' i odczekanie 10 ns	
    A1 <= "0001"; A2 <= "0011"; wait for 10ns;		-- ustawienie sygnalow 'A1', 'A2' i odczekanie 10 ns
    A1 <= "0010"; A2 <= "0111"; wait for 10ns;		-- ustawienie sygnalow 'A1', 'A2' i odczekanie 10 ns
    A1 <= "0110"; A2 <= "0100"; wait for 10ns;		-- ustawienie sygnalow 'A1', 'A2' i odczekanie 10 ns
    A1 <= "1000"; A2 <= "0110"; wait for 10ns;		-- ustawienie sygnalow 'A1', 'A2' i odczekanie 10 ns
    A1 <= "1010"; A2 <= "0110"; wait for 10ns;		-- ustawienie sygnalow 'A1', 'A2' i odczekanie 10 ns
    A1 <= "1111"; A2 <= "1111"; wait for 10ns;		-- ustawienie sygnalow 'A1', 'A2' i odczekanie 10 ns
  end process;						-- zakonczenie procesu

  procedure_sum1_inst: entity work.PROCEDURE_SUM1(cialo) -- instancja projektu 'PROCEDURE_SUM1'
    port map (A1 => A1, A2 => A2, YA => YA1, CA => CA1, YB => YB1, CB => CB1);	-- przypisanie portom sygnalow

  procedure_sum2_inst: entity work.PROCEDURE_SUM2(cialo) -- instancja projektu 'PROCEDURE_SUM2'
    port map (A1 => A1, A2 => A2, YA => YA2, CA => CA2, YB => YB2, CB => CB2);	-- przypisanie portom sygnalow

  procedure_sum3_inst: entity work.PROCEDURE_SUM3(cialo) -- instancja projektu 'PROCEDURE_SUM3'
    port map (A1 => A1, A2 => A2, YA => YA3, CA => CA3, YB => YB3, CB => CB3);	-- przypisanie portom sygnalow

end behavioural;					-- zakonczenie ciala architektonicznego
