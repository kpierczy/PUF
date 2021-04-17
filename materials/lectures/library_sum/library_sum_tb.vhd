entity LIBRARY_SUM_TB is				-- pusty sprzeg projektu symulacji
end LIBRARY_SUM_TB;

architecture behavioural of LIBRARY_SUM_TB is	-- cialo architektoniczne projektu

  signal A1 : bit_vector(3 downto 0);			-- deklaracja portu wejsciowego 'A1'
  signal A2 : bit_vector(3 downto 0);			-- deklaracja portu wejsciowego 'A2'
  signal Y  : bit_vector(3 downto 0);			-- deklaracja portu wyjsciowego 'YA'

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

  library_sum_inst: entity work.LIBRARY_SUM(cialo)	-- instancja projektu 'LIBRARY_SUM'
    port map (A1, A2, Y);				-- przypisanie portom sygnalow

end behavioural;					-- zakonczenie ciala architektonicznego
