entity FUNCTION_OVERSUM_TB is				-- pusty sprzeg projektu symulacji
end FUNCTION_OVERSUM_TB;

architecture behavioural of FUNCTION_OVERSUM_TB is	-- cialo architektoniczne projektu

  signal A1 : bit_vector(4 downto 0);			-- deklaracja portu wejsciowego 'A1'
  signal A2 : bit_vector(3 downto 0);			-- deklaracja portu wejsciowego 'A2'
  signal A3 : bit_vector(2 downto 0);			-- deklaracja portu wejsciowego 'A3'
  signal Y2 : bit_vector(4 downto 0);			-- deklaracja portu wyjsciowego 'Y2'
  signal Y3 : bit_vector(5 downto 0);			-- deklaracja portu wyjsciowego 'Y3'

begin							-- czesc wykonawcza ciala projektu

  process is						-- proces bezwarunkowy
  begin							-- czesc wykonawcza procesu
    A1 <= "00000"; A2 <= "0000"; A3 <= "000"; wait for 10ns; -- ustawienie sygnalow 'A1', 'A2', 'A3' i odczekanie 10 ns	
    A1 <= "10001"; A2 <= "1011"; A3 <= "011"; wait for 10ns; -- ustawienie sygnalow 'A1', 'A2', 'A3' i odczekanie 10 ns
    A1 <= "00010"; A2 <= "0011"; A3 <= "101"; wait for 10ns; -- ustawienie sygnalow 'A1', 'A2', 'A3' i odczekanie 10 ns
    A1 <= "10110"; A2 <= "1000"; A3 <= "100"; wait for 10ns; -- ustawienie sygnalow 'A1', 'A2', 'A3' i odczekanie 10 ns
    A1 <= "01000"; A2 <= "1010"; A3 <= "110"; wait for 10ns; -- ustawienie sygnalow 'A1', 'A2', 'A3' i odczekanie 10 ns
    A1 <= "01010"; A2 <= "0010"; A3 <= "001"; wait for 10ns; -- ustawienie sygnalow 'A1', 'A2', 'A3' i odczekanie 10 ns
    A1 <= "11111"; A2 <= "1111"; A3 <= "111"; wait for 10ns; -- ustawienie sygnalow 'A1', 'A2', 'A3' i odczekanie 10 ns
  end process;						-- zakonczenie procesu

  function_oversum_inst: entity work.FUNCTION_OVERSUM(cialo) -- instancja projektu 'FUNCTION_OVERSUM'
    port map (A1, A2, A3, Y2, Y3);			-- przypisanie portom sygnalow

end behavioural;					-- zakonczenie ciala architektonicznego
